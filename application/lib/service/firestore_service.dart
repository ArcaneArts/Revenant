import 'dart:convert';

import 'package:application/util/sugar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fast_log/fast_log.dart';
import 'package:json_compress/json_compress.dart';
import 'package:serviced/serviced.dart';
import 'package:throttled/throttled.dart';

extension XFirestoreDocument on DocumentReference<Map<String, dynamic>> {
  Future<DocumentSnapshot<Map<String, dynamic>>> getMonitored(
          [GetOptions? options]) =>
      svc<FirestoreService>().getDocument(this);

  Future<void> deleteMonitored({
    Map<String, dynamic>? dataKnown,
    int? estimatedKeys,
  }) {
    int del = 0;

    if (dataKnown != null) {
      del += services().get<FirestoreService>().count(dataKnown);
    } else if (estimatedKeys != null) {
      del += estimatedKeys;
    }

    services().get<FirestoreService>().deleted(path, del);

    return delete();
  }

  Future<void> setMonitored(Map<String, dynamic> data, [SetOptions? options]) =>
      services().get<FirestoreService>().setDocument(
          documentReference: this, data: data, setOptions: options);

  Future<void> updateMonitored(Map<String, dynamic> data) =>
      services().get<FirestoreService>().updateDocument(this, data);

  Stream<DocumentSnapshot<Map<String, dynamic>>> snapshotsMonitored(
          {bool? includeMetadataChanges}) =>
      services().get<FirestoreService>().streamDocument(this,
          includeMetadataChanges: includeMetadataChanges ?? false);
}

extension XFirestoreCollection on CollectionReference<Map<String, dynamic>> {
  Future<DocumentReference<Map<String, dynamic>>> addMonitored(
          Map<String, dynamic> data) =>
      services().get<FirestoreService>().addDocument(this, data);

  Future<QuerySnapshot<Map<String, dynamic>>> getMonitored(
          [GetOptions? options]) =>
      services().get<FirestoreService>().getCollection(this);

  Stream<QuerySnapshot<Map<String, dynamic>>> snapshotsMonitored(
          {bool? includeMetadataChanges}) =>
      services().get<FirestoreService>().streamCollection(this,
          includeMetadataChanges: includeMetadataChanges ?? false);
}

extension XFirestoreQuery on Query<Map<String, dynamic>> {
  Future<QuerySnapshot<Map<String, dynamic>>> getMonitored(
          [GetOptions? options]) =>
      services().get<FirestoreService>().getCollection(this);

  Stream<QuerySnapshot<Map<String, dynamic>>> snapshotsMonitored(
          {bool? includeMetadataChanges}) =>
      services().get<FirestoreService>().streamCollection(this,
          includeMetadataChanges: includeMetadataChanges ?? false);
}

class FirestoreMonitoring {
  int readCount = 0;
  int writeCount = 0;
  int deleteCount = 0;
  Map<String, int> reads = {};
  Map<String, int> writes = {};
  Map<String, int> deletes = {};

  FirestoreMonitoring();

  Map<String, dynamic> toJson() => compressJson({
        'readCount': readCount,
        'writeCount': writeCount,
        'deleteCount': deleteCount,
        'reads': reads,
        'writes': writes,
        'deletes': deletes,
      }, forceEncode: true);

  factory FirestoreMonitoring.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> decompressed = decompressJson(json);
    return FirestoreMonitoring()
      ..readCount = decompressed['readCount'] ?? 0
      ..writeCount = decompressed['writeCount'] ?? 0
      ..deleteCount = decompressed['deleteCount'] ?? 0
      ..reads = decompressed['reads'] ?? {}
      ..writes = decompressed['writes'] ?? {}
      ..deletes = decompressed['deletes'] ?? {};
  }
}

class FirestoreService extends StatelessService {
  FirestoreMonitoring? monitoring;
  bool boxMissing = false;

  void update() {
    if (monitoring != null && box != null) {
      box!.put("firestoremonitor", jsonEncode(monitoring!.toJson()));
    }
  }

  FirestoreMonitoring getMonitoring() {
    if (monitoring == null) {
      verbose("Initializing Firebase Monitoring");
      if (box != null) {
        verbose("Using service box to load monitoring data");
        try {
          monitoring = FirestoreMonitoring.fromJson(
              jsonDecode(box!.get("firestoremonitor", defaultValue: "{}")));
          success("Loaded Firestore Monitoring Data");
        } catch (e) {
          monitoring = FirestoreMonitoring();
          warn("Failed to read monitoring data, starting fresh");
        }
      } else {
        boxMissing = true;
        monitoring = FirestoreMonitoring();
        warn("Service box is missing, starting fresh with a memory only copy");
      }
    } else if (boxMissing) {
      if (box != null) {
        warn("Box is still missing, re-attempting to load from it.");
        boxMissing = false;
        verbose("Service box found (finally)");
        try {
          monitoring = FirestoreMonitoring.fromJson(
              jsonDecode(box!.get("firestoremonitor", defaultValue: "{}")));
          success("Loaded Firestore Monitoring Data (late)");
        } catch (e) {
          monitoring = FirestoreMonitoring();
          warn("Failed to read monitoring data, starting fresh (late)");
        }
      }
    }

    if (monitoring == null) {
      warn("Monitoring is still null! Emergency memory only copy!");
      monitoring = FirestoreMonitoring();
    }

    throttle("update-firestore-monitoring", update,
        cooldown: const Duration(seconds: 5), leaky: true);
    return monitoring!;
  }

  Map<String, dynamic> countWrite(String at, Map<String, dynamic> data) {
    int c = count(data);
    getMonitoring().writeCount++;
    getMonitoring().writes[at] = (getMonitoring().writes[at] ?? 0) + c;
    return data;
  }

  Map<String, dynamic> countRead(String at, Map<String, dynamic> data) {
    int c = count(data);
    getMonitoring().readCount++;
    getMonitoring().reads[at] = (getMonitoring().reads[at] ?? 0) + c;
    return data;
  }

  Map<String, dynamic> countUpdate(String at, Map<String, dynamic> data) {
    int r = 0;
    int w = 0;
    int d = 0;
    for (String i in data.keys) {
      if (data[i] is Map<String, dynamic>) {
        w += count(data[i] as Map<String, dynamic>);
      } else if (data[i] is List<dynamic>) {
        w += (data[i] as List<dynamic>).length;
      } else if (data[i] is String) {
        w += (data[i] as String).length;
      } else if (data[i] is FieldValue) {
        if (data[i] == FieldValue.delete()) {
          d++;
        } else {
          // We cant actually check further...
          w++;
        }
      } else {
        w++;
      }

      if (r > 0) {
        getMonitoring().readCount++;
        getMonitoring().reads[at] = (getMonitoring().reads[at] ?? 0) + r;
      }

      if (w > 0) {
        getMonitoring().writeCount++;
        getMonitoring().writes[at] = (getMonitoring().writes[at] ?? 0) + w;
      }

      if (d > 0) {
        getMonitoring().deleteCount++;
        getMonitoring().deletes[at] = (getMonitoring().deletes[at] ?? 0) + d;
      }
    }

    return data;
  }

  int count(Map<String, dynamic> data) {
    int counted = 0;

    for (String i in data.keys) {
      if (data[i] is Map<String, dynamic>) {
        counted += count(data[i] as Map<String, dynamic>);
      } else if (data[i] is List<dynamic>) {
        counted += (data[i] as List<dynamic>).length;
      } else if (data[i] is String) {
        counted += (data[i] as String).length;
      } else {
        counted++;
      }
    }

    return counted;
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getCollection(
          Query<Map<String, dynamic>> query,
          {GetOptions? getOptions}) =>
      query.get(getOptions).then((value) {
        for (DocumentSnapshot<Map<String, dynamic>> i in value.docs) {
          countRead(i.reference.path, i.data() ?? {});
        }

        return value;
      });

  Future<DocumentSnapshot<Map<String, dynamic>>> getDocument(
          DocumentReference<Map<String, dynamic>> documentReference,
          {GetOptions? getOptions}) =>
      documentReference.get(getOptions).then((value) {
        countRead(value.reference.path, value.data() ?? {});
        return value;
      });

  Stream<QuerySnapshot<Map<String, dynamic>>> streamCollection(
          Query<Map<String, dynamic>> query,
          {bool includeMetadataChanges = false}) =>
      query
          .snapshots(includeMetadataChanges: includeMetadataChanges)
          .map((value) {
        for (DocumentSnapshot<Map<String, dynamic>> i in value.docs) {
          countRead(i.reference.path, i.data() ?? {});
        }

        return value;
      });

  Stream<DocumentSnapshot<Map<String, dynamic>>> streamDocument(
          DocumentReference<Map<String, dynamic>> documentReference,
          {bool includeMetadataChanges = false}) =>
      documentReference
          .snapshots(includeMetadataChanges: includeMetadataChanges)
          .map((value) {
        countRead(value.reference.path, value.data() ?? {});
        return value;
      });

  Future<void> setDocument(
          {required DocumentReference<Map<String, dynamic>> documentReference,
          required Map<String, dynamic> data,
          SetOptions? setOptions}) =>
      documentReference.set(data, setOptions).then((value) {
        countWrite(documentReference.path, data);
        return value;
      });

  Future<DocumentReference<Map<String, dynamic>>> addDocument(
          CollectionReference<Map<String, dynamic>> collectionReference,
          Map<String, dynamic> data) =>
      collectionReference.add(data).then((value) {
        countWrite(value.path, data);
        return value;
      });

  Future<void> updateDocument(
          DocumentReference<Map<String, dynamic>> documentReference,
          Map<String, dynamic> data) =>
      documentReference.update(data).then((value) {
        countUpdate(documentReference.path, data);
        return value;
      });

  void deleted(String path, int del) {
    getMonitoring().deleteCount++;
    getMonitoring().deletes[path] = (getMonitoring().deletes[path] ?? 0) + del;
  }
}

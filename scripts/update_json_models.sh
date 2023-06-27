cd "$(dirname "$0")"
cd ../application
echo "$(dirname "$0")"
flutter pub get
dart pub global activate flutter_gen
flutter pub run build_runner build --delete-conflicting-outputs
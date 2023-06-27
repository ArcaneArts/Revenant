cd "$(dirname "$0")"
cd ../application
echo "$(dirname "$0")"
flutter pub get
flutter pub run flutter_oss_licenses:generate.dart --output lib/util/generated/oss_licenses.gen.dart
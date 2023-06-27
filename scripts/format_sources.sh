cd "$(dirname "$0")"
cd ../application
echo "$(dirname "$0")"
flutter pub get
dart format .
dart pub global activate auto_const
dart pub global run auto_const
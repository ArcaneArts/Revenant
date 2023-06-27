cd "$(dirname "$0")"
cd ../application
echo "$(dirname "$0")"
flutter pub get
flutter pub run flutter_native_splash:create
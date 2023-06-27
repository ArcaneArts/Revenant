cd "$(dirname "$0")"
cd ../application
echo "$(dirname "$0")"
flutter pub get
dart pub global activate flutter_gen
flutter pub run flutter_oss_licenses:generate.dart --output lib/util/generated/oss_licenses.gen.dart
flutter pub run flutter_launcher_icons:main
flutter pub global activate icon_font_generator
flutter pub run icon_font_generator --from=assets/icons --out-font=assets/font/iicons.ttf --out-flutter=lib/util/generated/icons.gen.dart --class-name=IIcons --normalize --naming-strategy=snake
flutter pub run build_runner build --delete-conflicting-outputs
flutter pub run flutter_native_splash:create
dart format .
dart pub global activate auto_const
dart pub global run auto_const

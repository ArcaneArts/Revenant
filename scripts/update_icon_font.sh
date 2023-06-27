cd "$(dirname "$0")"
cd ../application
echo "$(dirname "$0")"
flutter pub get
flutter pub global activate icon_generator
flutter pub run icon_generator --from=assets/icons --out-font=assets/font/iicons.ttf --out-flutter=lib/util/generated/icons.gen.dart --class-name=IIcons --normalize --naming-strategy=snake
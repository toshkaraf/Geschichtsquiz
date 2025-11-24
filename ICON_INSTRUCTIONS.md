# Инструкция по добавлению иконки приложения

## Для Android

1. Поместите вашу иконку (изображение, которое вы залили) в корень проекта как `icon.png` (рекомендуемый размер: 1024x1024 пикселей)

2. Установите пакет для генерации иконок:
```bash
flutter pub add --dev flutter_launcher_icons
```

3. Добавьте конфигурацию в `pubspec.yaml`:
```yaml
dev_dependencies:
  flutter_launcher_icons: ^0.13.1

flutter_launcher_icons:
  android: true
  ios: true
  image_path: "icon.png"
  adaptive_icon_background: "#D4A574"  # Цвет фона из вашей иконки (коричневый)
  adaptive_icon_foreground: "icon.png"
```

4. Запустите генерацию иконок:
```bash
flutter pub get
flutter pub run flutter_launcher_icons
```

## Альтернативный способ (ручной)

Если вы хотите добавить иконку вручную:

### Android
Замените файлы в `android/app/src/main/res/mipmap-*/ic_launcher.png` на вашу иконку в соответствующих размерах:
- mipmap-mdpi: 48x48
- mipmap-hdpi: 72x72
- mipmap-xhdpi: 96x96
- mipmap-xxhdpi: 144x144
- mipmap-xxxhdpi: 192x192

### Web
Замените файлы в `web/icons/`:
- Icon-192.png (192x192)
- Icon-512.png (512x512)
- Icon-maskable-192.png (192x192)
- Icon-maskable-512.png (512x512)

### iOS
Замените файлы в `ios/Runner/Assets.xcassets/AppIcon.appiconset/` согласно Contents.json

### Windows
Замените `windows/runner/resources/app_icon.ico` на вашу иконку в формате .ico


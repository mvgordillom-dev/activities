# Activities

A complete Flutter task management application designed for mobile and web.

## Features

- Clean architecture split into models, services, providers, screens, and widgets.
- Responsive layout optimized for both mobile and larger web viewports.
- Tasks grouped by day.
- Full task details shown in every card.
- Create-task dialog with validation.
- Completed tasks disappear immediately from the active list.

## Structure

```text
lib/
  core/theme/
  features/tasks/
    models/
    providers/
    services/
    ui/screens/
    ui/widgets/
```

## Getting started

1. Install Flutter.
2. Run `flutter pub get`.
3. Start the app with `flutter run -d chrome` for web or `flutter run` for mobile.

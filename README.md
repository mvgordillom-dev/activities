# Activities

A complete Flutter task management application designed for mobile and web.

## Features

- Clean architecture split into models, services, providers, screens, and widgets.
- Responsive layout optimized for both mobile and larger web viewports.
- Tasks grouped by day.
- Full task details shown in every card.
- Create-task dialog with validation and optional project classification.
- Completed tasks disappear immediately from the active list while remaining available for reports.
- Project management screen to create and review projects.
- Monthly reports grouped by project, including Others for unclassified tasks.

## Structure

```text
lib/
  core/navigation/
  core/theme/
  features/tasks/
    models/
    providers/
    services/
    ui/screens/
    ui/widgets/
  features/projects/
    models/
    providers/
    services/
    ui/screens/
  features/reports/
    models/
    ui/screens/
```

## Getting started

1. Install Flutter.
2. If platform folders are missing locally, run `flutter create .` once.
3. Run `flutter pub get`.
4. Start the app with `flutter run -d chrome` for web or `flutter run` for mobile.

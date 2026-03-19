# Activities

A complete Flutter task management application designed for mobile and web.

## Features

- Clean architecture split into models, services, providers, screens, and reusable widgets.
- Responsive layout optimized for both mobile and larger web viewports.
- Main task board with active tasks grouped by day.
- Dedicated add-task screen with the full task data model, optional project assignment, and validation.
- Project management with project creation, automatic `Others` classification, and quick task totals.
- Monthly reports grouped by project, including total, completed, pending, and completion rate metrics.
- Completed tasks disappear from the active board while remaining available in historical monthly reports.

## Structure

```text
lib/
  core/
    navigation/
    theme/
    widgets/
  features/
    projects/
      models/
      providers/
      services/
      ui/screens/
      ui/widgets/
    reports/
      models/
      services/
      ui/screens/
      ui/widgets/
    tasks/
      models/
      providers/
      services/
      ui/screens/
      ui/widgets/
```

## Getting started

1. Install Flutter.
2. If platform folders are missing locally, run `flutter create .` once.
3. Run `flutter pub get`.
4. Start the app with `flutter run -d chrome` for web or `flutter run` for mobile.

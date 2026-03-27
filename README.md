# Activities

A complete Flutter task management application designed for mobile and web.

## Features

- Clean architecture split into models, services, providers, screens, and reusable widgets.
- Responsive layout optimized for both mobile and larger web viewports.
- Main task board with active daily work logs grouped by date.
- Dedicated add-entry screen with per-day logged hours, optional project assignment, and validation.
- Project management with project creation, automatic `Others` classification, project hour totals, and a Jira-style Kanban board.
- Monthly reports grouped by project, including daily-entry counts, tracked days, total logged hours, and Excel export.
- Done entries disappear from the active board while remaining available in historical monthly reports and project boards.

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

## ASP.NET Core backend (SignalR)

A minimal .NET backend is available in `backend/Activities.Backend` with:
- `TaskItem` model aligned to the Flutter task fields.
- In-memory task service.
- `TasksController` endpoints for listing and creating tasks.
- `TaskHub` SignalR hub (`/hubs/tasks`) that broadcasts `taskCreated` whenever a task is added.


### Visual Studio 2022 (Windows)

If you are looking for `Activities.backend.exe`, it is generated **after you build** the backend project.

1. Open `backend/Activities.Backend.sln` in Visual Studio 2022.
2. Build the solution (`Build > Build Solution`).
3. Find the executable at:
   - `backend/Activities.Backend/bin/Debug/net8.0/Activities.backend.exe` (Debug)
   - `backend/Activities.Backend/bin/Release/net8.0/Activities.backend.exe` (Release)

If the `.exe` is missing, make sure the **Activities.Backend** project is the startup project and that the build succeeded.

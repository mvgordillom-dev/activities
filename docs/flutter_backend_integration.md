# Flutter + ASP.NET Core Web API integration guide

This guide explains how to connect your Flutter frontend to your local ASP.NET Core backend for actions like creating tasks, projects, etc.

## 1) API design that works well with Flutter

Use predictable REST endpoints:

- `GET /api/tasks` → list tasks
- `POST /api/tasks` → create a task
- `GET /api/projects` → list projects
- `POST /api/projects` → create a project

General JSON shape suggestions:
- Use camelCase JSON fields.
- Return `201 Created` for POST.
- Return validation errors as `400` with details.

## 2) CORS setup in ASP.NET Core

If Flutter Web runs at a different origin (for example `http://localhost:3000`), backend must allow it.

```csharp
var allowedOrigins = builder.Configuration
    .GetSection("FrontendOrigins")
    .Get<string[]>() ?? new[] { "http://localhost:3000" };

builder.Services.AddCors(options =>
{
    options.AddPolicy("FrontendCors", policy =>
    {
        policy.WithOrigins(allowedOrigins)
              .AllowAnyHeader()
              .AllowAnyMethod()
              .AllowCredentials();
    });
});

// Later in middleware pipeline
app.UseCors("FrontendCors");
```

`appsettings.json`:

```json
{
  "FrontendOrigins": [
    "http://localhost:3000",
    "http://localhost:5000",
    "http://localhost:8080"
  ]
}
```

## 3) Authentication options

For local development, no auth is fine initially.

For production, recommended approach:

- Use JWT bearer tokens.
- Flutter stores token securely (`flutter_secure_storage`).
- Send token in `Authorization: Bearer <token>` header.
- Backend validates token with `AddAuthentication().AddJwtBearer(...)`.

When auth is enabled, protected endpoints should use `[Authorize]`.

## 4) Example ASP.NET Core controller (simple)

```csharp
using Microsoft.AspNetCore.Mvc;

namespace Activities.Backend.Controllers;

[ApiController]
[Route("api/[controller]")]
public class ProjectsController : ControllerBase
{
    private static readonly List<ProjectDto> _projects = new();

    [HttpGet]
    public ActionResult<IEnumerable<ProjectDto>> GetAll() => Ok(_projects);

    [HttpPost]
    public ActionResult<ProjectDto> Create([FromBody] CreateProjectRequest request)
    {
        if (string.IsNullOrWhiteSpace(request.Name))
            return BadRequest(new { message = "Project name is required" });

        var project = new ProjectDto
        {
            Id = Guid.NewGuid().ToString("N"),
            Name = request.Name,
            Description = request.Description
        };

        _projects.Add(project);
        return CreatedAtAction(nameof(GetAll), new { id = project.Id }, project);
    }
}

public class CreateProjectRequest
{
    public string? Name { get; set; }
    public string? Description { get; set; }
}

public class ProjectDto
{
    public string Id { get; set; } = default!;
    public string Name { get; set; } = default!;
    public string? Description { get; set; }
}
```

## 5) Flutter HTTP request examples

Add dependency:

```yaml
dependencies:
  http: ^1.2.2
```

### Create project (`POST /api/projects`)

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  ApiClient(this.baseUrl, {this.token});

  final String baseUrl;
  final String? token;

  Future<Map<String, dynamic>> createProject({
    required String name,
    String? description,
  }) async {
    final uri = Uri.parse('$baseUrl/api/projects');

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'name': name,
        'description': description,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Create project failed: ${response.statusCode} ${response.body}');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}
```

### Get tasks (`GET /api/tasks`)

```dart
Future<List<dynamic>> getTasks(String baseUrl, {String? token}) async {
  final response = await http.get(
    Uri.parse('$baseUrl/api/tasks'),
    headers: {
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode != 200) {
    throw Exception('Get tasks failed: ${response.statusCode} ${response.body}');
  }

  return jsonDecode(response.body) as List<dynamic>;
}
```

## 6) Local run checklist

1. Start backend (Visual Studio / `dotnet run`).
2. Verify backend health (`GET /health`).
3. Use base URL in Flutter:
   - Web: `https://localhost:7049` (or `http://localhost:5049`)
   - Android emulator: `http://10.0.2.2:<port>` for local machine backend
   - iOS simulator: `http://localhost:<port>`
4. Confirm `FrontendOrigins` includes your Flutter web origin.
5. If using HTTPS in local dev, trust dev cert (`dotnet dev-certs https --trust`).

## 7) Recommended Flutter structure

- `features/tasks/models/*`
- `features/tasks/services/task_api_service.dart` (raw HTTP + JSON)
- `features/tasks/repositories/task_repository.dart` (business mapping)
- `features/tasks/providers/task_provider.dart` (state management)

Keep API handling inside service/repository, not directly in UI widgets.

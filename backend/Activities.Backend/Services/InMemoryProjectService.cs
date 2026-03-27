using Activities.Backend.Models;
using System.Collections.Concurrent;

namespace Activities.Backend.Services;

public sealed class InMemoryProjectService : IProjectService
{
    private readonly ConcurrentDictionary<string, ProjectItem> _projects = new();

    public IReadOnlyCollection<ProjectItem> GetAll() =>
        _projects.Values
            .OrderBy(project => project.Name)
            .ToArray();

    public ProjectItem Add(CreateProjectRequest request)
    {
        ArgumentNullException.ThrowIfNull(request);

        if (string.IsNullOrWhiteSpace(request.Name))
        {
            throw new ArgumentException("Project name is required.", nameof(request));
        }

        var project = new ProjectItem
        {
            Id = Guid.NewGuid().ToString("N"),
            Name = request.Name,
            Description = request.Description ?? string.Empty
        };

        _projects[project.Id] = project;
        return project;
    }
}

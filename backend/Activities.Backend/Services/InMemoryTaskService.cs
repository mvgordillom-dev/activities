using Activities.Backend.Models;
using System.Collections.Concurrent;

namespace Activities.Backend.Services;

public sealed class InMemoryTaskService : ITaskService
{
    private readonly ConcurrentDictionary<string, TaskItem> _tasks = new();

    public IReadOnlyCollection<TaskItem> GetAll() =>
        _tasks.Values
            .OrderBy(task => task.Date)
            .ThenBy(task => task.Name)
            .ToArray();

    public TaskItem Add(CreateTaskRequest request)
    {
        ArgumentNullException.ThrowIfNull(request);

        if (string.IsNullOrWhiteSpace(request.Name))
        {
            throw new ArgumentException("Task name is required.", nameof(request));
        }

        if (string.IsNullOrWhiteSpace(request.Description))
        {
            throw new ArgumentException("Task description is required.", nameof(request));
        }

        if (string.IsNullOrWhiteSpace(request.Responsible))
        {
            throw new ArgumentException("Task responsible is required.", nameof(request));
        }

        var task = new TaskItem
        {
            Id = Guid.NewGuid().ToString("N"),
            Name = request.Name,
            Type = request.Type,
            Description = request.Description,
            Date = request.Date,
            Responsible = request.Responsible,
            Hours = request.Hours,
            Status = request.Status,
            ProjectId = request.ProjectId,
            StartedOn = request.StartedOn,
            CompletedOn = request.CompletedOn
        };

        _tasks[task.Id] = task;
        return task;
    }
}

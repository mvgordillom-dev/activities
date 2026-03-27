namespace Activities.Backend.Models;

public enum TaskType
{
    Urgent,
    Normal,
    NoPriority
}

public enum TaskStatus
{
    Todo,
    InProgress,
    Done
}

public sealed class TaskItem
{
    public required string Id { get; init; }
    public required string Name { get; init; }
    public TaskType Type { get; init; }
    public required string Description { get; init; }
    public DateTime Date { get; init; }
    public required string Responsible { get; init; }
    public double Hours { get; init; }
    public TaskStatus Status { get; init; }
    public string? ProjectId { get; init; }
    public DateTime? StartedOn { get; init; }
    public DateTime? CompletedOn { get; init; }
}

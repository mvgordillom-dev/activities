namespace Activities.Backend.Models;

public sealed class CreateTaskRequest
{
    public string? Name { get; init; }
    public TaskType Type { get; init; }
    public string? Description { get; init; }
    public DateTime Date { get; init; }
    public string? Responsible { get; init; }
    public double Hours { get; init; }
    public TaskStatus Status { get; init; }
    public string? ProjectId { get; init; }
    public DateTime? StartedOn { get; init; }
    public DateTime? CompletedOn { get; init; }
}

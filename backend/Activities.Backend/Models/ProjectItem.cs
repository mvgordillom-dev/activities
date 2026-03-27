namespace Activities.Backend.Models;

public sealed class ProjectItem
{
    public required string Id { get; init; }
    public required string Name { get; init; }
    public string Description { get; init; } = string.Empty;
}

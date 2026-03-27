namespace Activities.Backend.Models;

public sealed class CreateProjectRequest
{
    public string? Name { get; init; }
    public string? Description { get; init; }
}

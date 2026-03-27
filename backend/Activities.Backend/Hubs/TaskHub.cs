using Microsoft.AspNetCore.SignalR;

namespace Activities.Backend.Hubs;

public sealed class TaskHub : Hub
{
    public const string HubRoute = "/hubs/tasks";
    public const string TaskCreatedEvent = "taskCreated";
}

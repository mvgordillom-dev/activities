using Activities.Backend.Hubs;
using Activities.Backend.Models;
using Activities.Backend.Services;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.SignalR;

namespace Activities.Backend.Controllers;

[ApiController]
[Route("api/[controller]")]
public sealed class TasksController : ControllerBase
{
    private readonly ITaskService _taskService;
    private readonly IHubContext<TaskHub> _hubContext;

    public TasksController(ITaskService taskService, IHubContext<TaskHub> hubContext)
    {
        _taskService = taskService;
        _hubContext = hubContext;
    }

    [HttpGet]
    [ProducesResponseType(typeof(IReadOnlyCollection<TaskItem>), StatusCodes.Status200OK)]
    public ActionResult<IReadOnlyCollection<TaskItem>> GetAll()
    {
        var tasks = _taskService.GetAll();
        return Ok(tasks);
    }

    [HttpPost]
    [ProducesResponseType(typeof(TaskItem), StatusCodes.Status201Created)]
    [ProducesResponseType(typeof(ProblemDetails), StatusCodes.Status400BadRequest)]
    public async Task<ActionResult<TaskItem>> Add([FromBody] CreateTaskRequest request, CancellationToken cancellationToken)
    {
        try
        {
            var task = _taskService.Add(request);
            await _hubContext.Clients.All.SendAsync(TaskHub.TaskCreatedEvent, task, cancellationToken);

            return CreatedAtAction(nameof(GetAll), new { id = task.Id }, task);
        }
        catch (ArgumentException exception)
        {
            return ValidationProblem(detail: exception.Message);
        }
    }
}

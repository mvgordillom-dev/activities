using Activities.Backend.Models;
using Activities.Backend.Services;
using Microsoft.AspNetCore.Mvc;

namespace Activities.Backend.Controllers;

[ApiController]
[Route("api/[controller]")]
public sealed class ProjectsController : ControllerBase
{
    private readonly IProjectService _projectService;

    public ProjectsController(IProjectService projectService)
    {
        _projectService = projectService;
    }

    [HttpGet]
    [ProducesResponseType(typeof(IReadOnlyCollection<ProjectItem>), StatusCodes.Status200OK)]
    public ActionResult<IReadOnlyCollection<ProjectItem>> GetAll()
    {
        var projects = _projectService.GetAll();
        return Ok(projects);
    }

    [HttpPost]
    [ProducesResponseType(typeof(ProjectItem), StatusCodes.Status201Created)]
    [ProducesResponseType(typeof(ProblemDetails), StatusCodes.Status400BadRequest)]
    public ActionResult<ProjectItem> Add([FromBody] CreateProjectRequest request)
    {
        try
        {
            var project = _projectService.Add(request);
            return CreatedAtAction(nameof(GetAll), new { id = project.Id }, project);
        }
        catch (ArgumentException exception)
        {
            return ValidationProblem(detail: exception.Message);
        }
    }
}

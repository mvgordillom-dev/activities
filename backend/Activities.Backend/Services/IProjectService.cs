using Activities.Backend.Models;

namespace Activities.Backend.Services;

public interface IProjectService
{
    IReadOnlyCollection<ProjectItem> GetAll();
    ProjectItem Add(CreateProjectRequest request);
}

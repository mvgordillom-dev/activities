using Activities.Backend.Models;

namespace Activities.Backend.Services;

public interface ITaskService
{
    IReadOnlyCollection<TaskItem> GetAll();
    TaskItem Add(CreateTaskRequest request);
}

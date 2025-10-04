using TodoApp.Models;
using TodoApp.Services;

namespace TodoApp.Extensions;

public static class TodoEndpoints
{
    public static void MapTodoEndpoints(this WebApplication app)
    {
        // Health check endpoint
        app.MapGet("/health", () => Results.Ok(new { status = "healthy", timestamp = DateTime.UtcNow }))
           .WithName("HealthCheck")
           .WithTags("Health");

        // GET /todos - Get all todos
        app.MapGet("/todos", async (TodoService todoService) =>
        {
            var todos = await todoService.GetAllAsync();
            return Results.Ok(todos);
        })
        .WithName("GetAllTodos")
        .WithTags("Todos");

        // GET /todos/{id} - Get todo by ID
        app.MapGet("/todos/{id}", async (string id, TodoService todoService) =>
        {
            var todo = await todoService.GetByIdAsync(id);
            return todo is not null ? Results.Ok(todo) : Results.NotFound();
        })
        .WithName("GetTodoById")
        .WithTags("Todos");

        // POST /todos - Create new todo
        app.MapPost("/todos", async (TodoItem todo, TodoService todoService) =>
        {
            var createdTodo = await todoService.CreateAsync(todo);
            return Results.Created($"/todos/{createdTodo.Id}", createdTodo);
        })
        .WithName("CreateTodo")
        .WithTags("Todos");

        // PUT /todos/{id} - Update todo
        app.MapPut("/todos/{id}", async (string id, TodoItem updatedTodo, TodoService todoService) =>
        {
            updatedTodo.Id = id; // Ensure the ID matches
            var success = await todoService.UpdateAsync(id, updatedTodo);
            return success ? Results.Ok(updatedTodo) : Results.NotFound();
        })
        .WithName("UpdateTodo")
        .WithTags("Todos");

        // DELETE /todos/{id} - Delete todo
        app.MapDelete("/todos/{id}", async (string id, TodoService todoService) =>
        {
            var success = await todoService.DeleteAsync(id);
            return success ? Results.NoContent() : Results.NotFound();
        })
        .WithName("DeleteTodo")
        .WithTags("Todos");

        // PATCH /todos/{id}/toggle - Toggle completion status
        app.MapPatch("/todos/{id}/toggle", async (string id, TodoService todoService) =>
        {
            var success = await todoService.ToggleCompletionAsync(id);
            if (!success) return Results.NotFound();

            var updatedTodo = await todoService.GetByIdAsync(id);
            return Results.Ok(updatedTodo);
        })
        .WithName("ToggleTodoCompletion")
        .WithTags("Todos");

        // GET /todos/completed - Get completed todos
        app.MapGet("/todos/completed", async (TodoService todoService) =>
        {
            var completedTodos = await todoService.GetByCompletionStatusAsync(true);
            return Results.Ok(completedTodos);
        })
        .WithName("GetCompletedTodos")
        .WithTags("Todos");

        // GET /todos/pending - Get pending todos
        app.MapGet("/todos/pending", async (TodoService todoService) =>
        {
            var pendingTodos = await todoService.GetByCompletionStatusAsync(false);
            return Results.Ok(pendingTodos);
        })
        .WithName("GetPendingTodos")
        .WithTags("Todos");
    }
}
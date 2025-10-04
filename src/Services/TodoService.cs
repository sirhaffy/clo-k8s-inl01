using MongoDB.Driver;
using TodoApp.Models;

namespace TodoApp.Services;

public class TodoService
{
    private readonly IMongoCollection<TodoItem> _todosCollection;

    public TodoService(IConfiguration configuration)
    {
        // Get MongoDB connection string from environment variables (K8s secrets) or configuration
        var connectionString = Environment.GetEnvironmentVariable("MONGODB_URI")
            ?? configuration.GetConnectionString("MongoDB")
            ?? "mongodb://localhost:27017"; // Fallback for local development

        var databaseName = Environment.GetEnvironmentVariable("MONGODB_DATABASE")
            ?? configuration["DatabaseName"]
            ?? "TodoApp";

        var collectionName = Environment.GetEnvironmentVariable("MONGODB_COLLECTION")
            ?? configuration["CollectionName"]
            ?? "Todos";

        // Create MongoDB client and get database/collection references
        var mongoClient = new MongoClient(connectionString);
        var mongoDatabase = mongoClient.GetDatabase(databaseName);
        _todosCollection = mongoDatabase.GetCollection<TodoItem>(collectionName);
    }

    // Get all todos
    public async Task<List<TodoItem>> GetAllAsync()
    {
        return await _todosCollection.Find(_ => true).ToListAsync();
    }

    // Get todo by ID
    public async Task<TodoItem?> GetByIdAsync(string id)
    {
        return await _todosCollection.Find(x => x.Id == id).FirstOrDefaultAsync();
    }

    // Create new todo
    public async Task<TodoItem> CreateAsync(TodoItem todo)
    {
        todo.CreatedAt = DateTime.UtcNow;
        todo.UpdatedAt = DateTime.UtcNow;

        await _todosCollection.InsertOneAsync(todo);
        return todo;
    }

    // Update existing todo
    public async Task<bool> UpdateAsync(string id, TodoItem updatedTodo)
    {
        updatedTodo.UpdatedAt = DateTime.UtcNow;

        var result = await _todosCollection.ReplaceOneAsync(
            x => x.Id == id,
            updatedTodo
        );

        return result.ModifiedCount > 0;
    }

    // Delete todo
    public async Task<bool> DeleteAsync(string id)
    {
        var result = await _todosCollection.DeleteOneAsync(x => x.Id == id);
        return result.DeletedCount > 0;
    }

    // Toggle todo completion status
    public async Task<bool> ToggleCompletionAsync(string id)
    {
        var todo = await GetByIdAsync(id);
        if (todo == null) return false;

        var update = Builders<TodoItem>.Update
            .Set(x => x.IsCompleted, !todo.IsCompleted)
            .Set(x => x.UpdatedAt, DateTime.UtcNow);

        var result = await _todosCollection.UpdateOneAsync(x => x.Id == id, update);
        return result.ModifiedCount > 0;
    }

    // Get todos by completion status
    public async Task<List<TodoItem>> GetByCompletionStatusAsync(bool isCompleted)
    {
        return await _todosCollection
            .Find(x => x.IsCompleted == isCompleted)
            .ToListAsync();
    }
}
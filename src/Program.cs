using TodoApp.Services;
using TodoApp.Extensions;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container
builder.Services.AddSingleton<TodoService>();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Add CORS for frontend (if needed)
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyMethod()
              .AllowAnyHeader();
    });
});

var app = builder.Build();

// Configure the HTTP request pipeline
app.UseSwagger();
app.UseSwaggerUI();

// Serve static files (HTML, CSS, JS) - ORDER MATTERS!
app.UseDefaultFiles(); // Must come BEFORE UseStaticFiles
app.UseStaticFiles();

app.UseCors("AllowAll");
app.UseHttpsRedirection();

// Map all Todo endpoints
app.MapTodoEndpoints();

app.Run();
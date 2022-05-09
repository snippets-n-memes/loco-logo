using System;
using System.IO;
using Microsoft.Extensions.FileProviders;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

app.UseSwagger();
app.UseSwaggerUI();

app.UseHttpsRedirection();

app.MapGet("/boxboat", () => ascii("boxboat")); 
app.MapGet("/blinky", () => ascii("blinky")); 
app.MapGet("/dwight", () => ascii("dwight")); 
app.MapGet("/tnt", () => ascii("tnt")); 
app.MapGet("/mtv", () => ascii("mtv")); 
app.MapGet("/azure", () => ascii("azure")); 
app.MapGet("/octocat", () => ascii("octocat")); 
app.MapGet("/ibm", () => ascii("ibm")); 
app.MapGet("/docker", () => ascii("docker")); 
app.MapGet("/k8s", () => ascii("k8s")); 
app.MapGet("/helm", () => ascii("helm")); 
app.MapGet("/tux", () => ascii("tux"));

app.Run();

string ascii(string file) {
    string text = "";
    try {
        using (var sr = new StreamReader($"ascii/{file}")) {
            text = sr.ReadToEnd();
        }
    } catch (IOException e) {
        Console.WriteLine(e.Message);
    }

    return text;
}
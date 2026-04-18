using Microsoft.AspNetCore.DataProtection;
using System.IO;
var builder = WebApplication.CreateBuilder(args);
builder.Services.AddControllersWithViews();
builder.Services.AddDataProtection()
    .PersistKeysToFileSystem(new DirectoryInfo("/tmp/data-protection-keys"));
builder.Services.AddHttpClient("MlApi", client =>
{
    var mlApiUrl = builder.Configuration["MlApi:BaseUrl"] ?? "http://localhost:5000";
    client.BaseAddress = new Uri(mlApiUrl);
    client.Timeout = TimeSpan.FromSeconds(30);
});
var app = builder.Build();
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Home/Error");
    app.UseHsts();
}
app.UseHttpsRedirection();
app.UseStaticFiles();
app.UseRouting();
app.UseAuthorization();
app.MapControllerRoute(
    name: "default",
    pattern: "{controller=Home}/{action=Index}/{id?}");
app.MapGet("/health", () => Results.Ok(new
{
    status = "healthy",
    timestamp = DateTime.UtcNow,
    version = "1.0.0"
}));
app.Run();
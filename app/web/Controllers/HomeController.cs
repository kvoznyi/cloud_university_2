using Microsoft.AspNetCore.Mvc;
using WorkoutPlanner.Models;
namespace WorkoutPlanner.Controllers;
public class HomeController : Controller
{
    private readonly ILogger<HomeController> _logger;
    public HomeController(ILogger<HomeController> logger)
    {
        _logger = logger;
    }
    public IActionResult Index()
    {
        return View(new WorkoutRequest());
    }
    [HttpPost]
    public async Task<IActionResult> Result(
        [FromForm] WorkoutRequest request,
        [FromServices] IHttpClientFactory httpClientFactory)
    {
        try
        {
            var client = httpClientFactory.CreateClient("MlApi");
            var payload = new
            {
                age = request.Age,
                weight = request.Weight,
                height = request.Height,
                goal = request.Goal,
                fitness_level = request.FitnessLevel,
                sensor_data = request.SensorData
            };
            var response = await client.PostAsJsonAsync("/predict", payload);
            if (response.IsSuccessStatusCode)
            {
                var result = await response.Content.ReadFromJsonAsync<WorkoutResponse>();
                return View(result ?? GetFallbackResponse(request));
            }
            _logger.LogWarning("ML API returned {StatusCode}", response.StatusCode);
            return View(GetFallbackResponse(request));
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to call ML API, using fallback response");
            return View(GetFallbackResponse(request));
        }
    }
    public IActionResult Error()
    {
        return View(new ErrorViewModel
        {
            RequestId = HttpContext.TraceIdentifier
        });
    }
    private static WorkoutResponse GetFallbackResponse(WorkoutRequest request)
    {
        var (exercises, duration, intensity) = request.Goal switch
        {
            "weight_loss" => (
                new[] { "Running", "Cycling", "Jump Rope", "Burpees", "Mountain Climbers" },
                45, "High"),
            "muscle_gain" => (
                new[] { "Bench Press", "Squats", "Deadlifts", "Pull-ups", "Overhead Press" },
                60, "High"),
            "flexibility" => (
                new[] { "Yoga", "Stretching", "Pilates", "Foam Rolling", "Dynamic Stretches" },
                30, "Low"),
            "endurance" => (
                new[] { "Long-distance Running", "Swimming", "Cycling", "Rowing", "Hiking" },
                50, "Medium"),
            _ => (
                new[] { "Walking", "Light Jogging", "Bodyweight Squats", "Push-ups", "Plank" },
                40, "Medium")
        };
        return new WorkoutResponse
        {
            RecognizedActivity = "General Fitness Assessment",
            Recommendation = $"Based on your profile ({request.Age}y, {request.Weight}kg, goal: {request.Goal}), " +
                             $"we recommend a {intensity.ToLower()}-intensity workout.",
            Confidence = 0.85,
            SuggestedExercises = exercises,
            EstimatedDurationMinutes = duration,
            IntensityLevel = intensity
        };
    }
}
using Microsoft.AspNetCore.Mvc;
using WorkoutPlanner.Models;
namespace WorkoutPlanner.Controllers;
[ApiController]
[Route("api/[controller]")]
public class PredictionController : ControllerBase
{
    private readonly IHttpClientFactory _httpClientFactory;
    private readonly ILogger<PredictionController> _logger;
    public PredictionController(
        IHttpClientFactory httpClientFactory,
        ILogger<PredictionController> logger)
    {
        _httpClientFactory = httpClientFactory;
        _logger = logger;
    }
    [HttpPost]
    public async Task<ActionResult<WorkoutResponse>> Predict([FromBody] WorkoutRequest request)
    {
        try
        {
            var client = _httpClientFactory.CreateClient("MlApi");
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
                return Ok(result);
            }
            _logger.LogWarning("ML API returned {StatusCode}", response.StatusCode);
            return StatusCode((int)response.StatusCode, new { error = "ML service error" });
        }
        catch (HttpRequestException ex)
        {
            _logger.LogError(ex, "ML API is unreachable");
            return ServiceUnavailable("ML service is currently unavailable");
        }
    }
    [HttpGet("activities")]
    public ActionResult<string[]> GetActivities()
    {
        var activities = new[]
        {
            "Sitting", "Standing", "Lying on Back", "Lying on Right Side",
            "Ascending Stairs", "Descending Stairs", "Standing in Elevator",
            "Moving in Elevator", "Walking in Parking Lot", "Walking on Treadmill (4km/h flat)",
            "Walking on Treadmill (4km/h 15° incline)", "Running on Treadmill (8km/h)",
            "Exercising on Stepper", "Exercising on Cross Trainer",
            "Cycling on Exercise Bike (Horizontal)", "Cycling on Exercise Bike (Vertical)",
            "Rowing", "Jumping", "Playing Basketball"
        };
        return Ok(activities);
    }
    private ObjectResult ServiceUnavailable(string message) =>
        StatusCode(503, new { error = message });
}
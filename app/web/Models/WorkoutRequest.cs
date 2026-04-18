namespace WorkoutPlanner.Models;
public class WorkoutRequest
{
    public int Age { get; set; } = 25;
    public double Weight { get; set; } = 70.0;
    public double Height { get; set; } = 175.0;
    public string Goal { get; set; } = "general_fitness";
    public string FitnessLevel { get; set; } = "intermediate";
    public double[]? SensorData { get; set; }
}
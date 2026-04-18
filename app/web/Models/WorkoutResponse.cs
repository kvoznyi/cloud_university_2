namespace WorkoutPlanner.Models;
public class WorkoutResponse
{
    public string RecognizedActivity { get; set; } = string.Empty;
    public string Recommendation { get; set; } = string.Empty;
    public double Confidence { get; set; }
    public string[] SuggestedExercises { get; set; } = [];
    public int EstimatedDurationMinutes { get; set; }
    public string IntensityLevel { get; set; } = string.Empty;
}
using UnityEngine;

/// <summary>
/// Architectural era for buildings
/// </summary>
public enum BuildingEra
{
    AncientRome,
    Renaissance
}

/// <summary>
/// Type of science challenge associated with building
/// </summary>
public enum ChallengeType
{
    Mathematics,    // Golden ratio, proportions, calculations
    Geometry,       // Arches, symmetry, shapes
    Physics,        // Structural loads, forces, stability
    Chemistry,      // Mortar mixing, pigments, materials
    MaterialScience,// Stone vs wood, durability
    Engineering,    // Foundations, load-bearing
    Optics,         // Light, windows
    Acoustics       // Sound, cathedral design
}

/// <summary>
/// ScriptableObject defining a building's properties
/// Create in Unity: Right-click > Create > Renaissance Academy > Building Data
/// </summary>
[CreateAssetMenu(fileName = "NewBuilding", menuName = "Renaissance Academy/Building Data")]
public class BuildingData : ScriptableObject
{
    [Header("Basic Info")]
    [SerializeField] private string buildingName;
    [SerializeField] private BuildingEra era;
    [SerializeField] [TextArea(2, 4)] private string description;

    [Header("Sprites")]
    [SerializeField] private Sprite blueprintSprite;    // Gray/outline version
    [SerializeField] private Sprite watercolorSprite;   // Full color version
    [SerializeField] private Sprite iconSprite;         // For UI menus

    [Header("Prefab")]
    [SerializeField] private GameObject buildingPrefab;

    [Header("Costs")]
    [SerializeField] private int goldCost = 100;
    [SerializeField] private int stoneCost = 10;
    [SerializeField] private int woodCost = 5;

    [Header("Challenge")]
    [SerializeField] private ChallengeType primaryChallenge;
    [SerializeField] private ChallengeData[] challenges;

    [Header("Educational Content")]
    [SerializeField] [TextArea(3, 6)] private string historicalFact;
    [SerializeField] [TextArea(2, 4)] private string scienceConnection;

    // Public accessors
    public string BuildingName => buildingName;
    public BuildingEra Era => era;
    public string Description => description;

    public Sprite BlueprintSprite => blueprintSprite;
    public Sprite WatercolorSprite => watercolorSprite;
    public Sprite IconSprite => iconSprite;
    public GameObject BuildingPrefab => buildingPrefab;

    public int GoldCost => goldCost;
    public int StoneCost => stoneCost;
    public int WoodCost => woodCost;

    public ChallengeType PrimaryChallenge => primaryChallenge;
    public ChallengeData[] Challenges => challenges;

    public string HistoricalFact => historicalFact;
    public string ScienceConnection => scienceConnection;

    /// <summary>
    /// Check if player can afford this building
    /// </summary>
    public bool CanAfford()
    {
        if (ResourceManager.Instance == null) return false;
        return ResourceManager.Instance.CanAfford(goldCost, stoneCost, woodCost);
    }

    /// <summary>
    /// Get formatted cost string for UI
    /// </summary>
    public string GetCostString()
    {
        return $"💰{goldCost}  🪨{stoneCost}  🪵{woodCost}";
    }

    /// <summary>
    /// Get era display name
    /// </summary>
    public string GetEraDisplayName()
    {
        return era == BuildingEra.AncientRome ? "Ancient Rome" : "Renaissance";
    }
}

/// <summary>
/// Individual challenge data (can be embedded or separate ScriptableObject)
/// </summary>
[System.Serializable]
public class ChallengeData
{
    [Header("Challenge Info")]
    public string challengeTitle;
    public ChallengeType challengeType;
    [TextArea(3, 6)] public string problemStatement;

    [Header("Answer")]
    public string correctAnswer;
    public float tolerance = 0.01f;  // For numerical answers

    [Header("Hints")]
    [TextArea(2, 3)] public string hint1;
    [TextArea(2, 3)] public string hint2;
    [TextArea(2, 3)] public string hint3;

    [Header("Educational")]
    [TextArea(2, 4)] public string explanation;
    public string formula;

    /// <summary>
    /// Check if the given answer is correct
    /// </summary>
    public bool CheckAnswer(string playerAnswer)
    {
        if (string.IsNullOrEmpty(playerAnswer)) return false;

        // Try numerical comparison first
        if (float.TryParse(playerAnswer, out float numAnswer) &&
            float.TryParse(correctAnswer, out float correctNum))
        {
            return Mathf.Abs(numAnswer - correctNum) <= tolerance;
        }

        // String comparison (case-insensitive)
        return playerAnswer.Trim().ToLower() == correctAnswer.Trim().ToLower();
    }
}

using UnityEngine;

/// <summary>
/// Renaissance Architect Academy - Official Color Palette
/// Based on Leonardo da Vinci notebook aesthetic
///
/// Visual Style Guide References:
/// - Atmospheric Perspective: Blue/Gray fade for distance
/// - Golden Hour Warmth: Warm, inviting environment
/// - Natural Vegetation softens hard lines
/// - Goal: "Psychologically Safe" space where mistakes are just sketches to be erased
/// </summary>
public static class GameColors
{
    // Primary Palette
    public static readonly Color Parchment = HexToColor("#F5E6D3");
    public static readonly Color SepiaInk = HexToColor("#4A4035");
    public static readonly Color RenaissanceBlue = HexToColor("#5B8FA3");
    public static readonly Color Terracotta = HexToColor("#D4876B");
    public static readonly Color Ochre = HexToColor("#C9A86A");
    public static readonly Color SageGreen = HexToColor("#7A9B76");

    // UI Variants
    public static readonly Color ParchmentDark = HexToColor("#E8D5BC");
    public static readonly Color ParchmentLight = HexToColor("#FDF8F0");
    public static readonly Color SepiaLight = HexToColor("#6B5D4D");
    public static readonly Color GoldAccent = HexToColor("#D4A84B");

    // Blueprint colors (The Sketch stage - rough blue ink outlines)
    public static readonly Color BlueprintLine = HexToColor("#3A5F7A");
    public static readonly Color BlueprintFill = HexToColor("#E8F0F5");

    // The Logic stage (measurements, grid)
    public static readonly Color MeasurementLine = HexToColor("#4A403580"); // Sepia semi-transparent
    public static readonly Color GridLine = HexToColor("#5B8FA340");        // Blue semi-transparent

    // State colors
    public static readonly Color SuccessGreen = HexToColor("#5A8A5A");
    public static readonly Color ErrorRed = HexToColor("#A85454");
    public static readonly Color WarningOchre = HexToColor("#B8923A");
    public static readonly Color ErrorCrack = HexToColor("#B32626");        // Red cracks for structural errors

    // Atmospheric Perspective (distance fading)
    public static readonly Color AtmosphericNear = HexToColor("#FFFFFF");
    public static readonly Color AtmosphericMid = HexToColor("#D8E4EC");    // Blue/gray fade
    public static readonly Color AtmosphericFar = HexToColor("#A8B8C8");

    // Golden Hour / Light Effects
    public static readonly Color GoldenHourWarm = HexToColor("#FFE4B5");
    public static readonly Color GoldenLightRay = HexToColor("#FFD98099");  // Golden watercolor beams
    public static readonly Color ShadowWash = HexToColor("#33334040");      // Grayscale shadow studies

    // Science Visualization Colors
    public static readonly Color ForceArrow = HexToColor("#994040");        // Physics load arrows
    public static readonly Color PigmentBlue = HexToColor("#4A7BA8");       // Chemistry watercolor
    public static readonly Color PigmentYellow = HexToColor("#D4B84A");
    public static readonly Color PigmentGreen = HexToColor("#6A9B6A");

    // Seal Colors (Wax Seal Rewards)
    public static readonly Color SealBronze = HexToColor("#CD7F32");
    public static readonly Color SealSilver = HexToColor("#C0C0CC");
    public static readonly Color SealGold = HexToColor("#DAA520");
    public static readonly Color SealIridescent = HexToColor("#E6E6FF");

    // Decorative Elements (from style guide corners)
    public static readonly Color GearBronze = HexToColor("#8B7355");
    public static readonly Color WaxSealRed = HexToColor("#8B2323");
    public static readonly Color FlourishGold = HexToColor("#C9A227");

    private static Color HexToColor(string hex)
    {
        if (ColorUtility.TryParseHtmlString(hex, out Color color))
        {
            return color;
        }
        return Color.magenta; // Error color
    }

    /// <summary>
    /// Get atmospheric perspective color based on distance (0 = near, 1 = far)
    /// </summary>
    public static Color GetAtmosphericColor(float distance)
    {
        distance = Mathf.Clamp01(distance);
        if (distance < 0.5f)
        {
            return Color.Lerp(AtmosphericNear, AtmosphericMid, distance * 2f);
        }
        return Color.Lerp(AtmosphericMid, AtmosphericFar, (distance - 0.5f) * 2f);
    }

    /// <summary>
    /// Get golden hour tint based on time of day (0 = noon, 1 = golden hour)
    /// </summary>
    public static Color GetGoldenHourTint(float intensity)
    {
        return Color.Lerp(Color.white, GoldenHourWarm, Mathf.Clamp01(intensity));
    }
}

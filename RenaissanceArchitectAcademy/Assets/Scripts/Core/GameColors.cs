using UnityEngine;

/// <summary>
/// Renaissance Architect Academy - Official Color Palette
/// Based on Leonardo da Vinci notebook aesthetic
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

    // Blueprint colors (for unbuilt/challenge states)
    public static readonly Color BlueprintLine = HexToColor("#3A5F7A");
    public static readonly Color BlueprintFill = HexToColor("#E8F0F5");

    // State colors
    public static readonly Color SuccessGreen = HexToColor("#5A8A5A");
    public static readonly Color ErrorRed = HexToColor("#A85454");
    public static readonly Color WarningOchre = HexToColor("#B8923A");

    private static Color HexToColor(string hex)
    {
        if (ColorUtility.TryParseHtmlString(hex, out Color color))
        {
            return color;
        }
        return Color.magenta; // Error color
    }
}

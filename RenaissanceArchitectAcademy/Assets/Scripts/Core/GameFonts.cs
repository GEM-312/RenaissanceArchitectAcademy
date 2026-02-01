using UnityEngine;
using TMPro;

/// <summary>
/// Renaissance Architect Academy - Typography Guide
///
/// Font Hierarchy:
/// 1. CINZEL - Headings (Roman stone inscription style)
/// 2. EB GARAMOND - Body text (Early print clarity)
/// 3. CURSIVE SCRIPT - Annotations/mentor notes (Personal hand of the master)
///
/// Download these Google Fonts for Unity:
/// - Cinzel: https://fonts.google.com/specimen/Cinzel
/// - EB Garamond: https://fonts.google.com/specimen/EB+Garamond
/// - For cursive: Dancing Script or Pacifico
/// </summary>
public static class GameFonts
{
    // Font asset references (assign in FontManager)
    public static TMP_FontAsset HeadingFont { get; set; }      // Cinzel
    public static TMP_FontAsset BodyFont { get; set; }         // EB Garamond
    public static TMP_FontAsset AnnotationFont { get; set; }   // Cursive Script

    // Font size guidelines
    public static class Sizes
    {
        // Main Title (Renaissance Architect Academy)
        public const float TitleLarge = 72f;
        public const float TitleMedium = 48f;

        // Headings (Menu items, Section headers)
        public const float HeadingLarge = 36f;
        public const float HeadingMedium = 28f;
        public const float HeadingSmall = 24f;

        // Body text (Descriptions, Instructions)
        public const float BodyLarge = 20f;
        public const float BodyMedium = 18f;
        public const float BodySmall = 16f;

        // Annotations (Hints, Notes)
        public const float AnnotationLarge = 18f;
        public const float AnnotationMedium = 16f;
        public const float AnnotationSmall = 14f;

        // UI Elements (Buttons, Labels)
        public const float ButtonText = 22f;
        public const float LabelText = 16f;
        public const float TooltipText = 14f;
    }

    // Character spacing for different contexts
    public static class Spacing
    {
        public const float TitleSpacing = 8f;      // Wide spacing for grand titles
        public const float HeadingSpacing = 4f;    // Moderate spacing
        public const float BodySpacing = 0f;       // Normal spacing
        public const float AnnotationSpacing = 1f; // Slight spacing for elegance
    }
}

/// <summary>
/// Manages font loading and application
/// Attach to a GameObject in the scene
/// </summary>
public class FontManager : MonoBehaviour
{
    public static FontManager Instance { get; private set; }

    [Header("Font Assets (Import from Google Fonts)")]
    [SerializeField] private TMP_FontAsset cinzelFont;
    [SerializeField] private TMP_FontAsset ebGaramondFont;
    [SerializeField] private TMP_FontAsset cursiveFont;

    [Header("Fallback Font")]
    [SerializeField] private TMP_FontAsset fallbackFont;

    private void Awake()
    {
        if (Instance == null)
        {
            Instance = this;
            DontDestroyOnLoad(gameObject);
            InitializeFonts();
        }
        else
        {
            Destroy(gameObject);
        }
    }

    private void InitializeFonts()
    {
        // Assign fonts to static references
        GameFonts.HeadingFont = cinzelFont != null ? cinzelFont : fallbackFont;
        GameFonts.BodyFont = ebGaramondFont != null ? ebGaramondFont : fallbackFont;
        GameFonts.AnnotationFont = cursiveFont != null ? cursiveFont : fallbackFont;

        Debug.Log("[FontManager] Fonts initialized");

        if (cinzelFont == null)
            Debug.LogWarning("[FontManager] Cinzel font not assigned - using fallback");
        if (ebGaramondFont == null)
            Debug.LogWarning("[FontManager] EB Garamond font not assigned - using fallback");
        if (cursiveFont == null)
            Debug.LogWarning("[FontManager] Cursive font not assigned - using fallback");
    }

    /// <summary>
    /// Apply heading style to a TextMeshPro component
    /// </summary>
    public static void ApplyHeadingStyle(TMP_Text textComponent, float size = -1)
    {
        if (textComponent == null) return;

        textComponent.font = GameFonts.HeadingFont;
        textComponent.fontSize = size > 0 ? size : GameFonts.Sizes.HeadingMedium;
        textComponent.color = GameColors.SepiaInk;
        textComponent.characterSpacing = GameFonts.Spacing.HeadingSpacing;
        textComponent.fontStyle = FontStyles.Normal;
    }

    /// <summary>
    /// Apply body text style
    /// </summary>
    public static void ApplyBodyStyle(TMP_Text textComponent, float size = -1)
    {
        if (textComponent == null) return;

        textComponent.font = GameFonts.BodyFont;
        textComponent.fontSize = size > 0 ? size : GameFonts.Sizes.BodyMedium;
        textComponent.color = GameColors.SepiaInk;
        textComponent.characterSpacing = GameFonts.Spacing.BodySpacing;
        textComponent.fontStyle = FontStyles.Normal;
    }

    /// <summary>
    /// Apply annotation/hint style (cursive)
    /// </summary>
    public static void ApplyAnnotationStyle(TMP_Text textComponent, float size = -1)
    {
        if (textComponent == null) return;

        textComponent.font = GameFonts.AnnotationFont;
        textComponent.fontSize = size > 0 ? size : GameFonts.Sizes.AnnotationMedium;
        textComponent.color = GameColors.SepiaLight;
        textComponent.characterSpacing = GameFonts.Spacing.AnnotationSpacing;
        textComponent.fontStyle = FontStyles.Italic;
    }

    /// <summary>
    /// Apply title style (large Cinzel)
    /// </summary>
    public static void ApplyTitleStyle(TMP_Text textComponent, float size = -1)
    {
        if (textComponent == null) return;

        textComponent.font = GameFonts.HeadingFont;
        textComponent.fontSize = size > 0 ? size : GameFonts.Sizes.TitleLarge;
        textComponent.color = GameColors.SepiaInk;
        textComponent.characterSpacing = GameFonts.Spacing.TitleSpacing;
        textComponent.fontStyle = FontStyles.Normal;
    }

    /// <summary>
    /// Apply button text style
    /// </summary>
    public static void ApplyButtonStyle(TMP_Text textComponent)
    {
        if (textComponent == null) return;

        textComponent.font = GameFonts.HeadingFont;
        textComponent.fontSize = GameFonts.Sizes.ButtonText;
        textComponent.color = GameColors.ParchmentLight;
        textComponent.characterSpacing = GameFonts.Spacing.HeadingSpacing;
        textComponent.fontStyle = FontStyles.Normal;
    }
}

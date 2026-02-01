#if UNITY_EDITOR
using UnityEngine;
using UnityEditor;
using TMPro;

/// <summary>
/// Regenerates TMP font assets with correct settings to fix shadow/outline issues
/// Run via: Tools > Renaissance Academy > Fix Font Shadows
/// </summary>
public class FontRegenerator : EditorWindow
{
    [MenuItem("Tools/Renaissance Academy/Fix Font Shadows")]
    public static void FixFontShadows()
    {
        // Fix EBGaramond
        FixFontMaterial("Assets/Fonts/EB_Garamond/static/EBGaramond-Regular SDF.asset");

        // Fix PetitFormalScript
        FixFontMaterial("Assets/Fonts/Petit_Formal_Script/PetitFormalScript-Regular SDF.asset");

        // Fix Cinzel
        FixFontMaterial("Assets/Fonts/Cinzel/static/Cinzel-Bold SDF.asset");

        // Fix Playwrite fonts
        FixFontMaterial("Assets/Fonts/Playwrite_GB_J_Guides/PlaywriteGBJGuides-Italic SDF.asset");
        FixFontMaterial("Assets/Fonts/Playwrite_GB_J_Guides/PlaywriteGBJGuides-Regular SDF.asset");

        AssetDatabase.SaveAssets();
        AssetDatabase.Refresh();

        Debug.Log("[Renaissance Academy] All font shadows fixed! Please re-select your text objects.");
        EditorUtility.DisplayDialog("Fonts Fixed", "All font materials have been fixed.\n\nPlease re-assign fonts to your text objects or reload the scene.", "OK");
    }

    private static void FixFontMaterial(string path)
    {
        TMP_FontAsset font = AssetDatabase.LoadAssetAtPath<TMP_FontAsset>(path);
        if (font == null)
        {
            Debug.LogWarning($"Font not found: {path}");
            return;
        }

        Material mat = font.material;
        if (mat == null)
        {
            Debug.LogWarning($"Material not found for: {path}");
            return;
        }

        // Reset all shadow/outline properties
        mat.SetFloat("_OutlineWidth", 0f);
        mat.SetFloat("_OutlineSoftness", 0f);
        mat.SetFloat("_UnderlayOffsetX", 0f);
        mat.SetFloat("_UnderlayOffsetY", 0f);
        mat.SetFloat("_UnderlayDilate", 0f);
        mat.SetFloat("_UnderlaySoftness", 0f);
        mat.SetFloat("_GlowOffset", 0f);
        mat.SetFloat("_GlowOuter", 0f);
        mat.SetFloat("_GlowInner", 0f);
        mat.SetFloat("_GlowPower", 0f);
        mat.SetFloat("_WeightNormal", 0f);
        mat.SetFloat("_FaceDilate", 0f);

        // Increase gradient scale for better quality
        mat.SetFloat("_GradientScale", 10f);

        // Disable keywords that might enable effects
        mat.DisableKeyword("UNDERLAY_ON");
        mat.DisableKeyword("UNDERLAY_INNER");
        mat.DisableKeyword("OUTLINE_ON");
        mat.DisableKeyword("GLOW_ON");

        EditorUtility.SetDirty(mat);
        EditorUtility.SetDirty(font);

        Debug.Log($"Fixed: {path}");
    }
}
#endif

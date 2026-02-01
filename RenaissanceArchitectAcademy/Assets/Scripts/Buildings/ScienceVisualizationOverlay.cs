using UnityEngine;
using UnityEngine.UI;
using TMPro;
using System.Collections;
using System.Collections.Generic;

/// <summary>
/// Visualizing the Sciences: Physics, Math, Chemistry, Optics & Astronomy
///
/// Physics Treatment:
/// - Load distribution illustrated with gradient shading
/// - Forces shown as sketched arrows
/// - Structural errors appear as "Red Cracks"
///
/// Math Treatment:
/// - Rulers and grid alignments visible on blueprint layer
/// - Geometric shapes (Golden Ratio spirals) overlaid on facades
/// - Handwritten equations in margins
///
/// Chemistry:
/// - Pigment mixing shown through real watercolor blending
/// - Material properties shown via texture swatches
///
/// Optics & Astronomy:
/// - Sun paths traced in dotted lines
/// - Light rays rendered as golden watercolor beams
/// - Shadow studies using grayscale washes
/// </summary>
public class ScienceVisualizationOverlay : MonoBehaviour
{
    public static ScienceVisualizationOverlay Instance { get; private set; }

    [Header("Physics Visualization")]
    [SerializeField] private GameObject forceArrowPrefab;
    [SerializeField] private GameObject loadGradientPrefab;
    [SerializeField] private GameObject crackEffectPrefab;
    [SerializeField] private Color forceArrowColor = new Color(0.6f, 0.2f, 0.2f);
    [SerializeField] private Color errorCrackColor = new Color(0.7f, 0.15f, 0.15f);

    [Header("Math Visualization")]
    [SerializeField] private GameObject rulerPrefab;
    [SerializeField] private GameObject gridOverlayPrefab;
    [SerializeField] private GameObject goldenSpiralPrefab;
    [SerializeField] private GameObject equationLabelPrefab;
    [SerializeField] private Color measurementLineColor = new Color(0.29f, 0.25f, 0.21f, 0.7f);

    [Header("Chemistry Visualization")]
    [SerializeField] private GameObject colorSwatchPrefab;
    [SerializeField] private GameObject watercolorBlendPrefab;

    [Header("Optics Visualization")]
    [SerializeField] private GameObject lightRayPrefab;
    [SerializeField] private GameObject sunPathPrefab;
    [SerializeField] private GameObject shadowWashPrefab;
    [SerializeField] private Color goldenLightColor = new Color(1f, 0.85f, 0.5f, 0.6f);

    [Header("Annotation Style")]
    [SerializeField] private TMP_FontAsset handwritingFont;
    [SerializeField] private Color annotationColor = new Color(0.29f, 0.25f, 0.21f, 0.8f);

    private List<GameObject> activeOverlays = new List<GameObject>();

    private void Awake()
    {
        if (Instance == null)
        {
            Instance = this;
        }
        else
        {
            Destroy(gameObject);
        }
    }

    /// <summary>
    /// Show physics visualization for a building
    /// </summary>
    public void ShowPhysicsOverlay(Transform buildingTransform, PhysicsVisualizationData data)
    {
        ClearOverlays();

        if (data == null) return;

        // Create force arrows showing load distribution
        foreach (var force in data.forces)
        {
            CreateForceArrow(buildingTransform, force.position, force.direction, force.magnitude);
        }

        // Show load gradient on roof
        if (data.showLoadGradient && loadGradientPrefab != null)
        {
            GameObject gradient = Instantiate(loadGradientPrefab, buildingTransform);
            gradient.transform.localPosition = data.loadGradientPosition;
            activeOverlays.Add(gradient);
        }

        // Add measurement labels
        foreach (var measurement in data.measurements)
        {
            CreateMeasurementLabel(buildingTransform, measurement.position, measurement.text);
        }

        Debug.Log("[ScienceVisualization] Physics overlay displayed");
    }

    /// <summary>
    /// Show math visualization for a building
    /// </summary>
    public void ShowMathOverlay(Transform buildingTransform, MathVisualizationData data)
    {
        ClearOverlays();

        if (data == null) return;

        // Show grid alignment
        if (data.showGrid && gridOverlayPrefab != null)
        {
            GameObject grid = Instantiate(gridOverlayPrefab, buildingTransform);
            activeOverlays.Add(grid);
        }

        // Show golden ratio spiral
        if (data.showGoldenRatio && goldenSpiralPrefab != null)
        {
            GameObject spiral = Instantiate(goldenSpiralPrefab, buildingTransform);
            spiral.transform.localPosition = data.goldenSpiralPosition;
            spiral.transform.localScale = Vector3.one * data.goldenSpiralScale;
            activeOverlays.Add(spiral);
        }

        // Add ruler measurements
        foreach (var ruler in data.rulers)
        {
            CreateRuler(buildingTransform, ruler.startPosition, ruler.endPosition, ruler.label);
        }

        // Add handwritten equations
        foreach (var equation in data.equations)
        {
            CreateEquationLabel(buildingTransform, equation.position, equation.text, equation.rotation);
        }

        Debug.Log("[ScienceVisualization] Math overlay displayed");
    }

    /// <summary>
    /// Show optics/light visualization
    /// </summary>
    public void ShowOpticsOverlay(Transform buildingTransform, OpticsVisualizationData data)
    {
        ClearOverlays();

        if (data == null) return;

        // Show sun path (dotted arc)
        if (data.showSunPath && sunPathPrefab != null)
        {
            GameObject sunPath = Instantiate(sunPathPrefab, buildingTransform);
            sunPath.transform.localPosition = data.sunPathCenter;
            activeOverlays.Add(sunPath);
        }

        // Create light rays (golden watercolor beams)
        foreach (var ray in data.lightRays)
        {
            CreateLightRay(buildingTransform, ray.origin, ray.direction, ray.length);
        }

        // Show shadow wash areas
        foreach (var shadow in data.shadowAreas)
        {
            CreateShadowWash(buildingTransform, shadow.position, shadow.size, shadow.intensity);
        }

        Debug.Log("[ScienceVisualization] Optics overlay displayed");
    }

    /// <summary>
    /// Show error visualization (red cracks for structural problems)
    /// </summary>
    public void ShowErrorVisualization(Transform buildingTransform, Vector3 errorPosition, string errorMessage)
    {
        if (crackEffectPrefab != null)
        {
            GameObject crack = Instantiate(crackEffectPrefab, buildingTransform);
            crack.transform.localPosition = errorPosition;
            activeOverlays.Add(crack);

            // Add error annotation
            CreateAnnotation(buildingTransform, errorPosition + Vector3.up * 0.5f, errorMessage, errorCrackColor);
        }

        Debug.Log($"[ScienceVisualization] Error shown: {errorMessage}");
    }

    private void CreateForceArrow(Transform parent, Vector3 position, Vector3 direction, float magnitude)
    {
        if (forceArrowPrefab == null) return;

        GameObject arrow = Instantiate(forceArrowPrefab, parent);
        arrow.transform.localPosition = position;
        arrow.transform.localRotation = Quaternion.LookRotation(Vector3.forward, direction);
        arrow.transform.localScale = Vector3.one * (0.5f + magnitude * 0.1f);

        // Set color
        var renderer = arrow.GetComponent<SpriteRenderer>();
        if (renderer != null)
        {
            renderer.color = forceArrowColor;
        }

        activeOverlays.Add(arrow);
    }

    private void CreateMeasurementLabel(Transform parent, Vector3 position, string text)
    {
        CreateAnnotation(parent, position, text, measurementLineColor);
    }

    private void CreateRuler(Transform parent, Vector3 start, Vector3 end, string label)
    {
        if (rulerPrefab == null) return;

        GameObject ruler = Instantiate(rulerPrefab, parent);

        // Position at midpoint
        ruler.transform.localPosition = (start + end) / 2f;

        // Rotate to align with measurement direction
        Vector3 direction = (end - start).normalized;
        float angle = Mathf.Atan2(direction.y, direction.x) * Mathf.Rad2Deg;
        ruler.transform.localRotation = Quaternion.Euler(0, 0, angle);

        // Scale to match distance
        float distance = Vector3.Distance(start, end);
        ruler.transform.localScale = new Vector3(distance, 1f, 1f);

        // Set label
        var labelText = ruler.GetComponentInChildren<TextMeshPro>();
        if (labelText != null)
        {
            labelText.text = label;
        }

        activeOverlays.Add(ruler);
    }

    private void CreateEquationLabel(Transform parent, Vector3 position, string equation, float rotation)
    {
        if (equationLabelPrefab == null)
        {
            CreateAnnotation(parent, position, equation, annotationColor, rotation);
            return;
        }

        GameObject label = Instantiate(equationLabelPrefab, parent);
        label.transform.localPosition = position;
        label.transform.localRotation = Quaternion.Euler(0, 0, rotation);

        var text = label.GetComponent<TextMeshPro>();
        if (text != null)
        {
            text.text = equation;
            text.font = handwritingFont;
            text.color = annotationColor;
        }

        activeOverlays.Add(label);
    }

    private void CreateLightRay(Transform parent, Vector3 origin, Vector3 direction, float length)
    {
        if (lightRayPrefab == null) return;

        GameObject ray = Instantiate(lightRayPrefab, parent);
        ray.transform.localPosition = origin;

        // Rotate to face direction
        float angle = Mathf.Atan2(direction.y, direction.x) * Mathf.Rad2Deg;
        ray.transform.localRotation = Quaternion.Euler(0, 0, angle);

        // Scale for length
        ray.transform.localScale = new Vector3(length, 1f, 1f);

        // Set golden color
        var renderer = ray.GetComponent<SpriteRenderer>();
        if (renderer != null)
        {
            renderer.color = goldenLightColor;
        }

        activeOverlays.Add(ray);
    }

    private void CreateShadowWash(Transform parent, Vector3 position, Vector2 size, float intensity)
    {
        if (shadowWashPrefab == null) return;

        GameObject shadow = Instantiate(shadowWashPrefab, parent);
        shadow.transform.localPosition = position;
        shadow.transform.localScale = new Vector3(size.x, size.y, 1f);

        var renderer = shadow.GetComponent<SpriteRenderer>();
        if (renderer != null)
        {
            renderer.color = new Color(0.2f, 0.2f, 0.25f, intensity);
        }

        activeOverlays.Add(shadow);
    }

    private void CreateAnnotation(Transform parent, Vector3 position, string text, Color color, float rotation = 0f)
    {
        GameObject annotationObj = new GameObject("Annotation");
        annotationObj.transform.SetParent(parent);
        annotationObj.transform.localPosition = position;
        annotationObj.transform.localRotation = Quaternion.Euler(0, 0, rotation);

        TextMeshPro tmp = annotationObj.AddComponent<TextMeshPro>();
        tmp.text = text;
        tmp.fontSize = 2f;
        tmp.color = color;
        tmp.alignment = TextAlignmentOptions.Center;
        tmp.font = handwritingFont;

        activeOverlays.Add(annotationObj);
    }

    /// <summary>
    /// Clear all active overlays
    /// </summary>
    public void ClearOverlays()
    {
        foreach (var overlay in activeOverlays)
        {
            if (overlay != null)
            {
                Destroy(overlay);
            }
        }
        activeOverlays.Clear();
    }

    /// <summary>
    /// Animate overlay appearance
    /// </summary>
    public void FadeInOverlays(float duration = 0.5f)
    {
        StartCoroutine(FadeOverlaysCoroutine(0f, 1f, duration));
    }

    public void FadeOutOverlays(float duration = 0.5f)
    {
        StartCoroutine(FadeOverlaysCoroutine(1f, 0f, duration));
    }

    private IEnumerator FadeOverlaysCoroutine(float from, float to, float duration)
    {
        float elapsed = 0f;

        while (elapsed < duration)
        {
            elapsed += Time.deltaTime;
            float t = elapsed / duration;
            float alpha = Mathf.Lerp(from, to, t);

            foreach (var overlay in activeOverlays)
            {
                if (overlay == null) continue;

                var renderers = overlay.GetComponentsInChildren<SpriteRenderer>();
                foreach (var r in renderers)
                {
                    Color c = r.color;
                    c.a = alpha * c.a;
                    r.color = c;
                }

                var texts = overlay.GetComponentsInChildren<TextMeshPro>();
                foreach (var txt in texts)
                {
                    Color c = txt.color;
                    c.a = alpha;
                    txt.color = c;
                }
            }

            yield return null;
        }
    }
}

// Data structures for science visualizations

[System.Serializable]
public class PhysicsVisualizationData
{
    public List<ForceData> forces = new List<ForceData>();
    public bool showLoadGradient = true;
    public Vector3 loadGradientPosition;
    public List<MeasurementData> measurements = new List<MeasurementData>();
}

[System.Serializable]
public class ForceData
{
    public Vector3 position;
    public Vector3 direction;
    public float magnitude;
}

[System.Serializable]
public class MeasurementData
{
    public Vector3 position;
    public string text;
}

[System.Serializable]
public class MathVisualizationData
{
    public bool showGrid = true;
    public bool showGoldenRatio = true;
    public Vector3 goldenSpiralPosition;
    public float goldenSpiralScale = 1f;
    public List<RulerData> rulers = new List<RulerData>();
    public List<EquationData> equations = new List<EquationData>();
}

[System.Serializable]
public class RulerData
{
    public Vector3 startPosition;
    public Vector3 endPosition;
    public string label;
}

[System.Serializable]
public class EquationData
{
    public Vector3 position;
    public string text;
    public float rotation;
}

[System.Serializable]
public class OpticsVisualizationData
{
    public bool showSunPath = true;
    public Vector3 sunPathCenter;
    public List<LightRayData> lightRays = new List<LightRayData>();
    public List<ShadowData> shadowAreas = new List<ShadowData>();
}

[System.Serializable]
public class LightRayData
{
    public Vector3 origin;
    public Vector3 direction;
    public float length;
}

[System.Serializable]
public class ShadowData
{
    public Vector3 position;
    public Vector2 size;
    public float intensity;
}

using UnityEngine;
using UnityEngine.UI;
using System.Collections;

/// <summary>
/// "The Living Notebook" - 3-Stage Building Animation System
///
/// Stage 1: THE SKETCH - Blueprint lines draw themselves rapidly (blue ink outlines)
/// Stage 2: THE LOGIC - Measurements and grid lines fade in
/// Stage 3: THE RENDER - Watercolor bleeds and spreads to fill the shapes
///
/// Transitions utilize page curls. Buttons squish like wax when pressed.
/// </summary>
public class BuildingAnimator : MonoBehaviour
{
    public static BuildingAnimator Instance { get; private set; }

    [Header("Animation Stages")]
    [SerializeField] private float sketchDuration = 1.5f;
    [SerializeField] private float logicDuration = 1.0f;
    [SerializeField] private float renderDuration = 2.5f;

    [Header("Sketch Stage Settings")]
    [SerializeField] private Color blueprintLineColor = new Color(0.23f, 0.37f, 0.48f, 1f); // #3A5F7A
    [SerializeField] private float lineDrawSpeed = 3f;
    [SerializeField] private AnimationCurve sketchCurve = AnimationCurve.EaseInOut(0, 0, 1, 1);

    [Header("Logic Stage Settings")]
    [SerializeField] private Color measurementColor = new Color(0.29f, 0.25f, 0.21f, 0.7f); // Sepia semi-transparent
    [SerializeField] private float gridFadeSpeed = 2f;

    [Header("Render Stage Settings")]
    [SerializeField] private Color watercolorBleedColor = new Color(0.91f, 0.84f, 0.69f, 0.5f); // Ochre wash
    [SerializeField] private float bloomSpreadSpeed = 1.5f;
    [SerializeField] private float colorSaturationSpeed = 2f;

    [Header("Audio (Optional)")]
    [SerializeField] private AudioClip sketchSound;
    [SerializeField] private AudioClip measurementSound;
    [SerializeField] private AudioClip watercolorSound;

    public enum AnimationStage
    {
        None,
        Sketch,
        Logic,
        Render,
        Complete
    }

    public AnimationStage CurrentStage { get; private set; } = AnimationStage.None;

    public event System.Action<AnimationStage> OnStageChanged;
    public event System.Action OnAnimationComplete;

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
    /// Start the full 3-stage building animation
    /// </summary>
    public void PlayBuildingAnimation(GameObject buildingObject, System.Action onComplete = null)
    {
        StartCoroutine(BuildingAnimationSequence(buildingObject, onComplete));
    }

    private IEnumerator BuildingAnimationSequence(GameObject buildingObject, System.Action onComplete)
    {
        if (buildingObject == null) yield break;

        SpriteRenderer renderer = buildingObject.GetComponent<SpriteRenderer>();
        if (renderer == null)
        {
            renderer = buildingObject.GetComponentInChildren<SpriteRenderer>();
        }

        if (renderer == null)
        {
            Debug.LogWarning("[BuildingAnimator] No SpriteRenderer found on building object");
            yield break;
        }

        // Get the building data component if exists
        BuildingVisuals visuals = buildingObject.GetComponent<BuildingVisuals>();

        // ========== STAGE 1: THE SKETCH ==========
        CurrentStage = AnimationStage.Sketch;
        OnStageChanged?.Invoke(CurrentStage);
        Debug.Log("[BuildingAnimator] Stage 1: THE SKETCH - Blueprint lines drawing...");

        yield return StartCoroutine(PlaySketchStage(renderer, visuals));

        // ========== STAGE 2: THE LOGIC ==========
        CurrentStage = AnimationStage.Logic;
        OnStageChanged?.Invoke(CurrentStage);
        Debug.Log("[BuildingAnimator] Stage 2: THE LOGIC - Measurements fading in...");

        yield return StartCoroutine(PlayLogicStage(renderer, visuals));

        // ========== STAGE 3: THE RENDER ==========
        CurrentStage = AnimationStage.Render;
        OnStageChanged?.Invoke(CurrentStage);
        Debug.Log("[BuildingAnimator] Stage 3: THE RENDER - Watercolor bloom...");

        yield return StartCoroutine(PlayRenderStage(renderer, visuals));

        // ========== COMPLETE ==========
        CurrentStage = AnimationStage.Complete;
        OnStageChanged?.Invoke(CurrentStage);
        OnAnimationComplete?.Invoke();

        Debug.Log("[BuildingAnimator] Animation complete!");
        onComplete?.Invoke();
    }

    private IEnumerator PlaySketchStage(SpriteRenderer renderer, BuildingVisuals visuals)
    {
        float elapsed = 0f;

        // Start with sketch/blueprint sprite if available
        if (visuals != null && visuals.SketchSprite != null)
        {
            renderer.sprite = visuals.SketchSprite;
        }

        // Set blueprint color (desaturated blue)
        renderer.color = new Color(blueprintLineColor.r, blueprintLineColor.g, blueprintLineColor.b, 0f);

        // Play sketch sound
        if (sketchSound != null)
        {
            AudioSource.PlayClipAtPoint(sketchSound, renderer.transform.position);
        }

        // Animate lines "drawing themselves"
        while (elapsed < sketchDuration)
        {
            elapsed += Time.deltaTime;
            float t = sketchCurve.Evaluate(elapsed / sketchDuration);

            // Fade in the sketch
            Color currentColor = blueprintLineColor;
            currentColor.a = t;
            renderer.color = currentColor;

            // Optional: Scale effect to simulate lines appearing
            float scaleEffect = 0.95f + (t * 0.05f);
            renderer.transform.localScale = Vector3.one * scaleEffect;

            yield return null;
        }

        // Ensure final sketch state
        renderer.color = blueprintLineColor;
        renderer.transform.localScale = Vector3.one;
    }

    private IEnumerator PlayLogicStage(SpriteRenderer renderer, BuildingVisuals visuals)
    {
        float elapsed = 0f;

        // Switch to logic/blueprint sprite if available
        if (visuals != null && visuals.LogicSprite != null)
        {
            renderer.sprite = visuals.LogicSprite;
        }

        // Play measurement sound
        if (measurementSound != null)
        {
            AudioSource.PlayClipAtPoint(measurementSound, renderer.transform.position);
        }

        // Show measurement overlays
        if (visuals != null)
        {
            visuals.ShowMeasurements(true);
        }

        // Subtle fade effect
        Color startColor = renderer.color;
        Color endColor = new Color(measurementColor.r, measurementColor.g, measurementColor.b, 1f);

        while (elapsed < logicDuration)
        {
            elapsed += Time.deltaTime;
            float t = elapsed / logicDuration;

            renderer.color = Color.Lerp(startColor, endColor, t);

            yield return null;
        }

        renderer.color = endColor;
    }

    private IEnumerator PlayRenderStage(SpriteRenderer renderer, BuildingVisuals visuals)
    {
        float elapsed = 0f;

        // Switch to final watercolor sprite
        if (visuals != null && visuals.RenderSprite != null)
        {
            renderer.sprite = visuals.RenderSprite;
        }

        // Play watercolor sound
        if (watercolorSound != null)
        {
            AudioSource.PlayClipAtPoint(watercolorSound, renderer.transform.position);
        }

        // Hide measurements (they're "absorbed" into the final render)
        if (visuals != null)
        {
            visuals.ShowMeasurements(false);
        }

        // Watercolor bloom effect
        Color startColor = renderer.color;
        Color endColor = Color.white; // Full color reveal

        // Add slight random bloom offset for organic feel
        Vector3 originalScale = renderer.transform.localScale;

        while (elapsed < renderDuration)
        {
            elapsed += Time.deltaTime;
            float t = elapsed / renderDuration;

            // Ease-out for natural watercolor spread
            float easedT = 1f - Mathf.Pow(1f - t, 3f);

            // Color transition (bloom effect)
            renderer.color = Color.Lerp(startColor, endColor, easedT);

            // Subtle "bleed" scale effect
            float bloomPulse = 1f + Mathf.Sin(t * Mathf.PI) * 0.03f;
            renderer.transform.localScale = originalScale * bloomPulse;

            yield return null;
        }

        // Final state
        renderer.color = Color.white;
        renderer.transform.localScale = originalScale;
    }

    /// <summary>
    /// Quick animation for UI elements (wax seal button press)
    /// </summary>
    public void PlayWaxButtonPress(RectTransform button, System.Action onComplete = null)
    {
        StartCoroutine(WaxButtonPressCoroutine(button, onComplete));
    }

    private IEnumerator WaxButtonPressCoroutine(RectTransform button, System.Action onComplete)
    {
        Vector3 originalScale = button.localScale;
        float duration = 0.15f;

        // Squish down
        float elapsed = 0f;
        while (elapsed < duration)
        {
            elapsed += Time.deltaTime;
            float t = elapsed / duration;
            button.localScale = Vector3.Lerp(originalScale, originalScale * 0.85f, t);
            yield return null;
        }

        // Bounce back
        elapsed = 0f;
        while (elapsed < duration)
        {
            elapsed += Time.deltaTime;
            float t = elapsed / duration;
            // Overshoot bounce
            float bounce = 1f + Mathf.Sin(t * Mathf.PI) * 0.1f;
            button.localScale = Vector3.Lerp(originalScale * 0.85f, originalScale * bounce, t);
            yield return null;
        }

        button.localScale = originalScale;
        onComplete?.Invoke();
    }

    /// <summary>
    /// Page curl transition effect
    /// </summary>
    public void PlayPageCurl(CanvasGroup fromPage, CanvasGroup toPage, System.Action onComplete = null)
    {
        StartCoroutine(PageCurlCoroutine(fromPage, toPage, onComplete));
    }

    private IEnumerator PageCurlCoroutine(CanvasGroup fromPage, CanvasGroup toPage, System.Action onComplete)
    {
        float duration = 0.5f;
        float elapsed = 0f;

        if (toPage != null)
        {
            toPage.alpha = 0f;
            toPage.gameObject.SetActive(true);
        }

        while (elapsed < duration)
        {
            elapsed += Time.deltaTime;
            float t = elapsed / duration;

            if (fromPage != null)
            {
                fromPage.alpha = 1f - t;
                // Simulate page curl with slight rotation
                fromPage.transform.localRotation = Quaternion.Euler(0, t * 30f, 0);
            }

            if (toPage != null)
            {
                toPage.alpha = t;
            }

            yield return null;
        }

        if (fromPage != null)
        {
            fromPage.gameObject.SetActive(false);
            fromPage.transform.localRotation = Quaternion.identity;
        }

        if (toPage != null)
        {
            toPage.alpha = 1f;
        }

        onComplete?.Invoke();
    }
}

/// <summary>
/// Attach to building prefabs to hold sprite references for animation stages
/// </summary>
public class BuildingVisuals : MonoBehaviour
{
    [Header("Animation Stage Sprites")]
    [SerializeField] private Sprite sketchSprite;      // Blue ink outline
    [SerializeField] private Sprite logicSprite;       // With measurements/grid
    [SerializeField] private Sprite renderSprite;      // Final watercolor

    [Header("Measurement Overlay")]
    [SerializeField] private GameObject measurementOverlay;

    public Sprite SketchSprite => sketchSprite;
    public Sprite LogicSprite => logicSprite;
    public Sprite RenderSprite => renderSprite;

    public void ShowMeasurements(bool show)
    {
        if (measurementOverlay != null)
        {
            measurementOverlay.SetActive(show);
        }
    }
}

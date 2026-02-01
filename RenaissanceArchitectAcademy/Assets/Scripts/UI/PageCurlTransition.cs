using UnityEngine;
using UnityEngine.UI;
using System.Collections;

/// <summary>
/// Page curl transition effect for UI panels
/// "Transitions utilize page curls" - Visual Style Guide
/// </summary>
public class PageCurlTransition : MonoBehaviour
{
    public static PageCurlTransition Instance { get; private set; }

    [Header("Transition Settings")]
    [SerializeField] private float transitionDuration = 0.6f;
    [SerializeField] private AnimationCurve curlCurve = AnimationCurve.EaseInOut(0, 0, 1, 1);

    [Header("Visual")]
    [SerializeField] private float maxRotation = 45f;
    [SerializeField] private float shadowIntensity = 0.3f;
    [SerializeField] private Image shadowOverlay;

    [Header("Audio")]
    [SerializeField] private AudioClip pageTurnSound;

    private bool isTransitioning = false;

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
    /// Transition from one panel to another with page curl effect
    /// </summary>
    public void TransitionPanels(CanvasGroup fromPanel, CanvasGroup toPanel, System.Action onComplete = null)
    {
        if (isTransitioning) return;
        StartCoroutine(PageCurlCoroutine(fromPanel, toPanel, onComplete));
    }

    /// <summary>
    /// Curl out a single panel (hide)
    /// </summary>
    public void CurlOut(CanvasGroup panel, System.Action onComplete = null)
    {
        if (isTransitioning) return;
        StartCoroutine(CurlOutCoroutine(panel, onComplete));
    }

    /// <summary>
    /// Curl in a single panel (show)
    /// </summary>
    public void CurlIn(CanvasGroup panel, System.Action onComplete = null)
    {
        if (isTransitioning) return;
        StartCoroutine(CurlInCoroutine(panel, onComplete));
    }

    private IEnumerator PageCurlCoroutine(CanvasGroup fromPanel, CanvasGroup toPanel, System.Action onComplete)
    {
        isTransitioning = true;

        // Play sound
        if (pageTurnSound != null)
        {
            AudioSource.PlayClipAtPoint(pageTurnSound, Camera.main.transform.position);
        }

        // Setup to panel (invisible, behind)
        if (toPanel != null)
        {
            toPanel.gameObject.SetActive(true);
            toPanel.alpha = 0f;
            toPanel.transform.localRotation = Quaternion.identity;
        }

        float elapsed = 0f;
        float halfDuration = transitionDuration / 2f;

        // First half: curl out the "from" panel
        while (elapsed < halfDuration)
        {
            elapsed += Time.deltaTime;
            float t = curlCurve.Evaluate(elapsed / halfDuration);

            if (fromPanel != null)
            {
                // Fade out
                fromPanel.alpha = 1f - t;

                // Rotate for curl effect
                float rotY = t * maxRotation;
                fromPanel.transform.localRotation = Quaternion.Euler(0, rotY, 0);

                // Scale slightly for 3D effect
                float scale = 1f - (t * 0.05f);
                fromPanel.transform.localScale = new Vector3(scale, 1f, 1f);
            }

            // Show shadow
            if (shadowOverlay != null)
            {
                shadowOverlay.color = new Color(0, 0, 0, t * shadowIntensity);
            }

            yield return null;
        }

        // Hide from panel
        if (fromPanel != null)
        {
            fromPanel.gameObject.SetActive(false);
            fromPanel.transform.localRotation = Quaternion.identity;
            fromPanel.transform.localScale = Vector3.one;
            fromPanel.alpha = 1f;
        }

        // Second half: curl in the "to" panel
        elapsed = 0f;
        if (toPanel != null)
        {
            toPanel.transform.localRotation = Quaternion.Euler(0, -maxRotation, 0);
            toPanel.transform.localScale = new Vector3(0.95f, 1f, 1f);
        }

        while (elapsed < halfDuration)
        {
            elapsed += Time.deltaTime;
            float t = curlCurve.Evaluate(elapsed / halfDuration);

            if (toPanel != null)
            {
                // Fade in
                toPanel.alpha = t;

                // Rotate back to normal
                float rotY = -maxRotation * (1f - t);
                toPanel.transform.localRotation = Quaternion.Euler(0, rotY, 0);

                // Scale back to normal
                float scale = 0.95f + (t * 0.05f);
                toPanel.transform.localScale = new Vector3(scale, 1f, 1f);
            }

            // Fade out shadow
            if (shadowOverlay != null)
            {
                shadowOverlay.color = new Color(0, 0, 0, (1f - t) * shadowIntensity);
            }

            yield return null;
        }

        // Final state
        if (toPanel != null)
        {
            toPanel.alpha = 1f;
            toPanel.transform.localRotation = Quaternion.identity;
            toPanel.transform.localScale = Vector3.one;
        }

        if (shadowOverlay != null)
        {
            shadowOverlay.color = new Color(0, 0, 0, 0);
        }

        isTransitioning = false;
        onComplete?.Invoke();
    }

    private IEnumerator CurlOutCoroutine(CanvasGroup panel, System.Action onComplete)
    {
        isTransitioning = true;

        if (pageTurnSound != null)
        {
            AudioSource.PlayClipAtPoint(pageTurnSound, Camera.main.transform.position);
        }

        float elapsed = 0f;

        while (elapsed < transitionDuration)
        {
            elapsed += Time.deltaTime;
            float t = curlCurve.Evaluate(elapsed / transitionDuration);

            if (panel != null)
            {
                panel.alpha = 1f - t;
                panel.transform.localRotation = Quaternion.Euler(0, t * maxRotation, 0);
                panel.transform.localScale = new Vector3(1f - (t * 0.1f), 1f, 1f);
            }

            yield return null;
        }

        if (panel != null)
        {
            panel.gameObject.SetActive(false);
            panel.transform.localRotation = Quaternion.identity;
            panel.transform.localScale = Vector3.one;
            panel.alpha = 1f;
        }

        isTransitioning = false;
        onComplete?.Invoke();
    }

    private IEnumerator CurlInCoroutine(CanvasGroup panel, System.Action onComplete)
    {
        isTransitioning = true;

        if (pageTurnSound != null)
        {
            AudioSource.PlayClipAtPoint(pageTurnSound, Camera.main.transform.position);
        }

        if (panel != null)
        {
            panel.gameObject.SetActive(true);
            panel.alpha = 0f;
            panel.transform.localRotation = Quaternion.Euler(0, -maxRotation, 0);
            panel.transform.localScale = new Vector3(0.9f, 1f, 1f);
        }

        float elapsed = 0f;

        while (elapsed < transitionDuration)
        {
            elapsed += Time.deltaTime;
            float t = curlCurve.Evaluate(elapsed / transitionDuration);

            if (panel != null)
            {
                panel.alpha = t;
                panel.transform.localRotation = Quaternion.Euler(0, -maxRotation * (1f - t), 0);
                panel.transform.localScale = new Vector3(0.9f + (t * 0.1f), 1f, 1f);
            }

            yield return null;
        }

        if (panel != null)
        {
            panel.alpha = 1f;
            panel.transform.localRotation = Quaternion.identity;
            panel.transform.localScale = Vector3.one;
        }

        isTransitioning = false;
        onComplete?.Invoke();
    }

    /// <summary>
    /// Quick transition without page curl (for faster UI)
    /// </summary>
    public void QuickTransition(CanvasGroup fromPanel, CanvasGroup toPanel, float duration = 0.2f)
    {
        StartCoroutine(QuickTransitionCoroutine(fromPanel, toPanel, duration));
    }

    private IEnumerator QuickTransitionCoroutine(CanvasGroup fromPanel, CanvasGroup toPanel, float duration)
    {
        if (toPanel != null)
        {
            toPanel.gameObject.SetActive(true);
            toPanel.alpha = 0f;
        }

        float elapsed = 0f;

        while (elapsed < duration)
        {
            elapsed += Time.deltaTime;
            float t = elapsed / duration;

            if (fromPanel != null) fromPanel.alpha = 1f - t;
            if (toPanel != null) toPanel.alpha = t;

            yield return null;
        }

        if (fromPanel != null)
        {
            fromPanel.gameObject.SetActive(false);
            fromPanel.alpha = 1f;
        }

        if (toPanel != null)
        {
            toPanel.alpha = 1f;
        }
    }
}

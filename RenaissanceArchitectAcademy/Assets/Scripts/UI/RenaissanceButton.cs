using UnityEngine;
using UnityEngine.UI;
using UnityEngine.EventSystems;
using TMPro;
using System.Collections;

/// <summary>
/// Custom button with Renaissance/Wax Seal press animation
/// "Buttons squish like wax when pressed" - Visual Style Guide
/// </summary>
[RequireComponent(typeof(Image))]
public class RenaissanceButton : MonoBehaviour, IPointerDownHandler, IPointerUpHandler, IPointerEnterHandler, IPointerExitHandler
{
    [Header("Button Style")]
    [SerializeField] private ButtonStyle style = ButtonStyle.Standard;
    [SerializeField] private Color normalColor = GameColors.Terracotta;
    [SerializeField] private Color hoverColor;
    [SerializeField] private Color pressedColor;

    [Header("Wax Press Animation")]
    [SerializeField] private float pressScale = 0.9f;
    [SerializeField] private float pressSpeed = 0.1f;
    [SerializeField] private float bounceOvershoot = 1.1f;

    [Header("Ink Drip Effect (Optional)")]
    [SerializeField] private bool enableInkDrip = false;
    [SerializeField] private GameObject inkDripPrefab;

    [Header("Audio")]
    [SerializeField] private AudioClip clickSound;
    [SerializeField] private AudioClip hoverSound;

    public enum ButtonStyle
    {
        Standard,       // Terracotta
        Secondary,      // Ochre
        Accent,         // Renaissance Blue
        Success,        // Sage Green
        Neutral,        // Sepia
        WaxSeal         // Special circular wax seal style
    }

    private Image buttonImage;
    private Button button;
    private RectTransform rectTransform;
    private Vector3 originalScale;
    private bool isPressed = false;
    private bool isHovered = false;

    private void Awake()
    {
        buttonImage = GetComponent<Image>();
        button = GetComponent<Button>();
        rectTransform = GetComponent<RectTransform>();
        originalScale = rectTransform.localScale;

        ApplyStyle();
    }

    private void ApplyStyle()
    {
        switch (style)
        {
            case ButtonStyle.Standard:
                normalColor = GameColors.Terracotta;
                break;
            case ButtonStyle.Secondary:
                normalColor = GameColors.Ochre;
                break;
            case ButtonStyle.Accent:
                normalColor = GameColors.RenaissanceBlue;
                break;
            case ButtonStyle.Success:
                normalColor = GameColors.SageGreen;
                break;
            case ButtonStyle.Neutral:
                normalColor = GameColors.SepiaLight;
                break;
            case ButtonStyle.WaxSeal:
                normalColor = GameColors.WaxSealRed;
                break;
        }

        hoverColor = Color.Lerp(normalColor, Color.white, 0.15f);
        pressedColor = Color.Lerp(normalColor, Color.black, 0.2f);

        if (buttonImage != null)
        {
            buttonImage.color = normalColor;
        }

        // Style the text
        var text = GetComponentInChildren<TextMeshProUGUI>();
        if (text != null)
        {
            text.color = GameColors.ParchmentLight;
        }
    }

    public void OnPointerDown(PointerEventData eventData)
    {
        if (button != null && !button.interactable) return;

        isPressed = true;
        StopAllCoroutines();
        StartCoroutine(WaxPressAnimation(true));

        if (clickSound != null)
        {
            AudioSource.PlayClipAtPoint(clickSound, Camera.main.transform.position, 0.5f);
        }
    }

    public void OnPointerUp(PointerEventData eventData)
    {
        if (!isPressed) return;

        isPressed = false;
        StopAllCoroutines();
        StartCoroutine(WaxPressAnimation(false));

        // Ink drip effect on release
        if (enableInkDrip && inkDripPrefab != null)
        {
            var drip = Instantiate(inkDripPrefab, transform.position, Quaternion.identity, transform.parent);
            Destroy(drip, 2f);
        }
    }

    public void OnPointerEnter(PointerEventData eventData)
    {
        if (button != null && !button.interactable) return;

        isHovered = true;
        buttonImage.color = hoverColor;

        // Subtle scale up on hover
        StopAllCoroutines();
        StartCoroutine(ScaleTo(originalScale * 1.02f, 0.1f));

        if (hoverSound != null)
        {
            AudioSource.PlayClipAtPoint(hoverSound, Camera.main.transform.position, 0.3f);
        }
    }

    public void OnPointerExit(PointerEventData eventData)
    {
        isHovered = false;

        if (!isPressed)
        {
            buttonImage.color = normalColor;
            StopAllCoroutines();
            StartCoroutine(ScaleTo(originalScale, 0.1f));
        }
    }

    private IEnumerator WaxPressAnimation(bool pressing)
    {
        float duration = pressSpeed;
        float elapsed = 0f;

        Vector3 startScale = rectTransform.localScale;
        Vector3 targetScale = pressing ? originalScale * pressScale : originalScale;
        Color startColor = buttonImage.color;
        Color targetColor = pressing ? pressedColor : (isHovered ? hoverColor : normalColor);

        while (elapsed < duration)
        {
            elapsed += Time.deltaTime;
            float t = elapsed / duration;

            // Ease out for more natural feel
            float easedT = 1f - Mathf.Pow(1f - t, 3f);

            rectTransform.localScale = Vector3.Lerp(startScale, targetScale, easedT);
            buttonImage.color = Color.Lerp(startColor, targetColor, easedT);

            yield return null;
        }

        rectTransform.localScale = targetScale;
        buttonImage.color = targetColor;

        // Bounce back effect when releasing
        if (!pressing)
        {
            yield return StartCoroutine(BounceBack());
        }
    }

    private IEnumerator BounceBack()
    {
        float duration = 0.15f;
        float elapsed = 0f;

        Vector3 startScale = rectTransform.localScale;
        Vector3 overshootScale = originalScale * bounceOvershoot;

        // Overshoot
        while (elapsed < duration * 0.5f)
        {
            elapsed += Time.deltaTime;
            float t = elapsed / (duration * 0.5f);
            rectTransform.localScale = Vector3.Lerp(startScale, overshootScale, t);
            yield return null;
        }

        // Settle back
        elapsed = 0f;
        while (elapsed < duration * 0.5f)
        {
            elapsed += Time.deltaTime;
            float t = elapsed / (duration * 0.5f);
            rectTransform.localScale = Vector3.Lerp(overshootScale, originalScale, t);
            yield return null;
        }

        rectTransform.localScale = originalScale;
    }

    private IEnumerator ScaleTo(Vector3 target, float duration)
    {
        Vector3 start = rectTransform.localScale;
        float elapsed = 0f;

        while (elapsed < duration)
        {
            elapsed += Time.deltaTime;
            rectTransform.localScale = Vector3.Lerp(start, target, elapsed / duration);
            yield return null;
        }

        rectTransform.localScale = target;
    }

    /// <summary>
    /// Set button style at runtime
    /// </summary>
    public void SetStyle(ButtonStyle newStyle)
    {
        style = newStyle;
        ApplyStyle();
    }

    /// <summary>
    /// Set custom color
    /// </summary>
    public void SetColor(Color color)
    {
        normalColor = color;
        hoverColor = Color.Lerp(color, Color.white, 0.15f);
        pressedColor = Color.Lerp(color, Color.black, 0.2f);

        if (!isHovered && !isPressed)
        {
            buttonImage.color = normalColor;
        }
    }
}

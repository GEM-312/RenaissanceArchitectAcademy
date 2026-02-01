using UnityEngine;
using UnityEngine.UI;
using TMPro;
using System.Collections;

/// <summary>
/// Controls the Main Menu scene with Renaissance aesthetic
/// "Learn Like Leonardo. Build Like Brunelleschi."
/// </summary>
public class MainMenuController : MonoBehaviour
{
    [Header("Title Elements")]
    [SerializeField] private TextMeshProUGUI titleText;
    [SerializeField] private TextMeshProUGUI subtitleText;
    [SerializeField] private TextMeshProUGUI taglineText;

    [Header("Menu Buttons")]
    [SerializeField] private Button playButton;
    [SerializeField] private Button settingsButton;
    [SerializeField] private Button creditsButton;
    [SerializeField] private Button quitButton;

    [Header("Decorative Elements")]
    [SerializeField] private Image backgroundImage;
    [SerializeField] private Image duomoImage;
    [SerializeField] private CanvasGroup fadeGroup;

    [Header("Animation Settings")]
    [SerializeField] private float fadeInDuration = 1.5f;
    [SerializeField] private float titleAnimDelay = 0.5f;
    [SerializeField] private float buttonAnimDelay = 0.2f;

    private void Start()
    {
        SetupColors();
        SetupText();
        StartCoroutine(PlayIntroAnimation());
    }

    private void SetupColors()
    {
        // Apply Renaissance color palette to UI elements
        if (backgroundImage != null)
        {
            backgroundImage.color = GameColors.Parchment;
        }

        // Style buttons with sepia tones
        StyleButton(playButton, "Play", GameColors.Terracotta);
        StyleButton(settingsButton, "Settings", GameColors.Ochre);
        StyleButton(creditsButton, "Credits", GameColors.SageGreen);
        StyleButton(quitButton, "Quit", GameColors.SepiaLight);
    }

    private void StyleButton(Button button, string text, Color color)
    {
        if (button == null) return;

        var image = button.GetComponent<Image>();
        if (image != null)
        {
            image.color = color;
        }

        var buttonText = button.GetComponentInChildren<TextMeshProUGUI>();
        if (buttonText != null)
        {
            buttonText.text = text;
            buttonText.color = GameColors.ParchmentLight;
        }

        // Setup button colors
        var colors = button.colors;
        colors.normalColor = color;
        colors.highlightedColor = Color.Lerp(color, Color.white, 0.2f);
        colors.pressedColor = Color.Lerp(color, Color.black, 0.2f);
        colors.selectedColor = color;
        button.colors = colors;
    }

    private void SetupText()
    {
        if (titleText != null)
        {
            titleText.text = "Renaissance Architect Academy";
            titleText.color = GameColors.SepiaInk;
        }

        if (subtitleText != null)
        {
            subtitleText.text = "Learn Like Leonardo. Build Like Brunelleschi.";
            subtitleText.color = GameColors.SepiaLight;
        }

        if (taglineText != null)
        {
            taglineText.text = "A fusion of Art, History, and 13+ STEM Sciences.";
            taglineText.color = GameColors.RenaissanceBlue;
        }
    }

    private IEnumerator PlayIntroAnimation()
    {
        // Start faded out
        if (fadeGroup != null)
        {
            fadeGroup.alpha = 0f;
        }

        // Hide buttons initially
        SetButtonsAlpha(0f);

        yield return new WaitForSeconds(0.3f);

        // Fade in background
        float elapsed = 0f;
        while (elapsed < fadeInDuration)
        {
            elapsed += Time.deltaTime;
            float t = elapsed / fadeInDuration;

            if (fadeGroup != null)
            {
                fadeGroup.alpha = Mathf.SmoothStep(0f, 1f, t);
            }

            yield return null;
        }

        // Ensure fully visible
        if (fadeGroup != null)
        {
            fadeGroup.alpha = 1f;
        }

        yield return new WaitForSeconds(titleAnimDelay);

        // Animate buttons appearing one by one
        yield return AnimateButton(playButton);
        yield return new WaitForSeconds(buttonAnimDelay);
        yield return AnimateButton(settingsButton);
        yield return new WaitForSeconds(buttonAnimDelay);
        yield return AnimateButton(creditsButton);
        yield return new WaitForSeconds(buttonAnimDelay);
        yield return AnimateButton(quitButton);
    }

    private void SetButtonsAlpha(float alpha)
    {
        SetButtonAlpha(playButton, alpha);
        SetButtonAlpha(settingsButton, alpha);
        SetButtonAlpha(creditsButton, alpha);
        SetButtonAlpha(quitButton, alpha);
    }

    private void SetButtonAlpha(Button button, float alpha)
    {
        if (button == null) return;

        var canvasGroup = button.GetComponent<CanvasGroup>();
        if (canvasGroup == null)
        {
            canvasGroup = button.gameObject.AddComponent<CanvasGroup>();
        }
        canvasGroup.alpha = alpha;
    }

    private IEnumerator AnimateButton(Button button)
    {
        if (button == null) yield break;

        var canvasGroup = button.GetComponent<CanvasGroup>();
        if (canvasGroup == null)
        {
            canvasGroup = button.gameObject.AddComponent<CanvasGroup>();
        }

        float duration = 0.4f;
        float elapsed = 0f;

        Vector3 startScale = Vector3.one * 0.8f;
        Vector3 endScale = Vector3.one;

        button.transform.localScale = startScale;

        while (elapsed < duration)
        {
            elapsed += Time.deltaTime;
            float t = elapsed / duration;
            float smoothT = Mathf.SmoothStep(0f, 1f, t);

            canvasGroup.alpha = smoothT;
            button.transform.localScale = Vector3.Lerp(startScale, endScale, smoothT);

            yield return null;
        }

        canvasGroup.alpha = 1f;
        button.transform.localScale = endScale;
    }

    // Button click handlers (connect these in Inspector)
    public void OnPlayClicked()
    {
        StartCoroutine(TransitionToGame());
    }

    private IEnumerator TransitionToGame()
    {
        // Fade out
        float duration = 0.5f;
        float elapsed = 0f;

        while (elapsed < duration)
        {
            elapsed += Time.deltaTime;
            if (fadeGroup != null)
            {
                fadeGroup.alpha = 1f - (elapsed / duration);
            }
            yield return null;
        }

        GameManager.Instance?.StartNewGame();
    }

    public void OnSettingsClicked()
    {
        UIManager.Instance?.ShowSettings();
    }

    public void OnCreditsClicked()
    {
        UIManager.Instance?.ShowCredits();
    }

    public void OnQuitClicked()
    {
        GameManager.Instance?.QuitGame();
    }
}

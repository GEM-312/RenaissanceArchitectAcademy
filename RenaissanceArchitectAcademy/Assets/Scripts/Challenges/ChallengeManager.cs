using UnityEngine;
using UnityEngine.UI;
using TMPro;
using System.Collections;

/// <summary>
/// Manages science challenges when player builds
/// Displays problem, validates answer, triggers bloom animation on success
/// </summary>
public class ChallengeManager : MonoBehaviour
{
    public static ChallengeManager Instance { get; private set; }

    [Header("UI References")]
    [SerializeField] private GameObject challengePanel;
    [SerializeField] private TextMeshProUGUI challengeTitleText;
    [SerializeField] private TextMeshProUGUI challengeTypeText;
    [SerializeField] private TextMeshProUGUI problemText;
    [SerializeField] private TextMeshProUGUI formulaText;
    [SerializeField] private TMP_InputField answerInput;
    [SerializeField] private Button submitButton;
    [SerializeField] private Button hintButton;
    [SerializeField] private TextMeshProUGUI hintText;
    [SerializeField] private TextMeshProUGUI feedbackText;

    [Header("Result Panel")]
    [SerializeField] private GameObject resultPanel;
    [SerializeField] private TextMeshProUGUI resultTitleText;
    [SerializeField] private TextMeshProUGUI explanationText;
    [SerializeField] private Button continueButton;

    [Header("Icons (Hand-drawn style)")]
    [SerializeField] private Image challengeIcon;
    [SerializeField] private Sprite geometryIcon;      // Compass
    [SerializeField] private Sprite hintsIcon;         // Feather/quill
    [SerializeField] private Sprite astronomyIcon;     // Stars/constellation
    [SerializeField] private Sprite mathIcon;
    [SerializeField] private Sprite physicsIcon;
    [SerializeField] private Sprite chemistryIcon;

    [Header("Settings")]
    [SerializeField] private int maxHints = 3;
    [SerializeField] private float wrongAnswerShakeDuration = 0.5f;

    private BuildingPlot currentPlot;
    private BuildingData currentBuilding;
    private ChallengeData currentChallenge;
    private int hintsUsed = 0;
    private int attemptCount = 0;

    public event System.Action<bool> OnChallengeCompleted;

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

    private void Start()
    {
        // Setup button listeners
        if (submitButton != null)
            submitButton.onClick.AddListener(SubmitAnswer);

        if (hintButton != null)
            hintButton.onClick.AddListener(ShowNextHint);

        if (continueButton != null)
            continueButton.onClick.AddListener(OnContinueClicked);

        // Setup input field
        if (answerInput != null)
        {
            answerInput.onSubmit.AddListener((text) => SubmitAnswer());
        }

        // Hide initially
        if (challengePanel != null) challengePanel.SetActive(false);
        if (resultPanel != null) resultPanel.SetActive(false);
    }

    /// <summary>
    /// Start a challenge for building placement
    /// </summary>
    public void StartChallenge(BuildingPlot plot, BuildingData building)
    {
        currentPlot = plot;
        currentBuilding = building;
        hintsUsed = 0;
        attemptCount = 0;

        // Get a random challenge for this building
        if (building.Challenges != null && building.Challenges.Length > 0)
        {
            currentChallenge = building.Challenges[Random.Range(0, building.Challenges.Length)];
        }
        else
        {
            // Create default challenge if none defined
            currentChallenge = CreateDefaultChallenge(building);
        }

        // Set game state
        GameManager.Instance?.SetState(GameManager.GameState.Challenge);

        // Display challenge
        DisplayChallenge();
    }

    private void DisplayChallenge()
    {
        if (challengePanel != null) challengePanel.SetActive(true);
        if (resultPanel != null) resultPanel.SetActive(false);

        // Set challenge icon based on type
        SetChallengeIcon(currentChallenge.challengeType);

        // Title
        if (challengeTitleText != null)
        {
            challengeTitleText.text = currentChallenge.challengeTitle;
            FontManager.ApplyHeadingStyle(challengeTitleText, GameFonts.Sizes.HeadingMedium);
        }

        // Challenge type label
        if (challengeTypeText != null)
        {
            challengeTypeText.text = GetChallengeTypeName(currentChallenge.challengeType);
            FontManager.ApplyAnnotationStyle(challengeTypeText);
        }

        // Problem statement
        if (problemText != null)
        {
            problemText.text = currentChallenge.problemStatement;
            FontManager.ApplyBodyStyle(problemText);
        }

        // Formula (if any)
        if (formulaText != null)
        {
            if (!string.IsNullOrEmpty(currentChallenge.formula))
            {
                formulaText.text = currentChallenge.formula;
                formulaText.gameObject.SetActive(true);
                FontManager.ApplyAnnotationStyle(formulaText);
            }
            else
            {
                formulaText.gameObject.SetActive(false);
            }
        }

        // Clear input and feedback
        if (answerInput != null)
        {
            answerInput.text = "";
            answerInput.Select();
            answerInput.ActivateInputField();
        }

        if (feedbackText != null)
        {
            feedbackText.text = "";
        }

        if (hintText != null)
        {
            hintText.text = "";
        }

        Debug.Log($"[ChallengeManager] Displaying challenge: {currentChallenge.challengeTitle}");
    }

    private void SetChallengeIcon(ChallengeType type)
    {
        if (challengeIcon == null) return;

        Sprite icon = type switch
        {
            ChallengeType.Geometry => geometryIcon,
            ChallengeType.Mathematics => mathIcon,
            ChallengeType.Physics => physicsIcon,
            ChallengeType.Chemistry => chemistryIcon,
            _ => mathIcon
        };

        if (icon != null)
        {
            challengeIcon.sprite = icon;
        }
    }

    private string GetChallengeTypeName(ChallengeType type)
    {
        return type switch
        {
            ChallengeType.Mathematics => "Mathematics",
            ChallengeType.Geometry => "Geometry",
            ChallengeType.Physics => "Physics",
            ChallengeType.Chemistry => "Chemistry",
            ChallengeType.MaterialScience => "Material Science",
            ChallengeType.Engineering => "Engineering",
            ChallengeType.Optics => "Optics",
            ChallengeType.Acoustics => "Acoustics",
            _ => "Science"
        };
    }

    private void SubmitAnswer()
    {
        if (answerInput == null) return;

        string answer = answerInput.text.Trim();
        attemptCount++;

        if (string.IsNullOrEmpty(answer))
        {
            ShowFeedback("Please enter an answer.", false);
            return;
        }

        bool isCorrect = currentChallenge.CheckAnswer(answer);

        if (isCorrect)
        {
            OnCorrectAnswer();
        }
        else
        {
            OnWrongAnswer();
        }
    }

    private void OnCorrectAnswer()
    {
        Debug.Log("[ChallengeManager] Correct answer!");
        ShowFeedback("Correct! Excellent work!", true);

        // Show result panel after short delay
        StartCoroutine(ShowResultAfterDelay(true, 1f));
    }

    private void OnWrongAnswer()
    {
        Debug.Log("[ChallengeManager] Wrong answer");
        ShowFeedback("Not quite. Try again!", false);

        // Shake the input field
        StartCoroutine(ShakeInput());

        // Clear input for retry
        if (answerInput != null)
        {
            answerInput.text = "";
            answerInput.Select();
        }
    }

    private void ShowFeedback(string message, bool success)
    {
        if (feedbackText != null)
        {
            feedbackText.text = message;
            feedbackText.color = success ? GameColors.SuccessGreen : GameColors.ErrorRed;
        }
    }

    private IEnumerator ShakeInput()
    {
        if (answerInput == null) yield break;

        RectTransform rect = answerInput.GetComponent<RectTransform>();
        Vector3 originalPos = rect.localPosition;

        float elapsed = 0f;
        while (elapsed < wrongAnswerShakeDuration)
        {
            float x = Random.Range(-5f, 5f);
            rect.localPosition = originalPos + new Vector3(x, 0, 0);
            elapsed += Time.deltaTime;
            yield return null;
        }

        rect.localPosition = originalPos;
    }

    private void ShowNextHint()
    {
        if (hintsUsed >= maxHints)
        {
            if (hintText != null)
            {
                hintText.text = "No more hints available!";
            }
            return;
        }

        hintsUsed++;
        string hint = hintsUsed switch
        {
            1 => currentChallenge.hint1,
            2 => currentChallenge.hint2,
            3 => currentChallenge.hint3,
            _ => ""
        };

        if (hintText != null && !string.IsNullOrEmpty(hint))
        {
            hintText.text = $"Hint {hintsUsed}: {hint}";
            FontManager.ApplyAnnotationStyle(hintText);
        }

        Debug.Log($"[ChallengeManager] Showing hint {hintsUsed}");
    }

    private IEnumerator ShowResultAfterDelay(bool success, float delay)
    {
        yield return new WaitForSeconds(delay);

        // Hide challenge panel
        if (challengePanel != null) challengePanel.SetActive(false);

        // Show result panel
        if (resultPanel != null) resultPanel.SetActive(true);

        if (success)
        {
            if (resultTitleText != null)
            {
                resultTitleText.text = "Building Complete!";
                resultTitleText.color = GameColors.SuccessGreen;
                FontManager.ApplyHeadingStyle(resultTitleText);
            }

            if (explanationText != null)
            {
                explanationText.text = currentChallenge.explanation;
                FontManager.ApplyBodyStyle(explanationText);
            }
        }
    }

    private void OnContinueClicked()
    {
        // Hide result panel
        if (resultPanel != null) resultPanel.SetActive(false);

        // Place the building with bloom animation
        if (currentPlot != null && currentBuilding != null)
        {
            currentPlot.PlaceBuilding(currentBuilding, currentBuilding.BuildingPrefab);
        }

        // Return to playing state
        GameManager.Instance?.SetState(GameManager.GameState.Playing);

        // Notify listeners
        OnChallengeCompleted?.Invoke(true);

        // Clean up
        currentPlot = null;
        currentBuilding = null;
        currentChallenge = null;
    }

    private ChallengeData CreateDefaultChallenge(BuildingData building)
    {
        return new ChallengeData
        {
            challengeTitle = $"Build the {building.BuildingName}",
            challengeType = building.PrimaryChallenge,
            problemStatement = $"Calculate the golden ratio.\n\nIf φ (phi) = 1.618, what is 10 ÷ φ?\n\nRound to 2 decimal places.",
            correctAnswer = "6.18",
            tolerance = 0.05f,
            hint1 = "The golden ratio φ ≈ 1.618",
            hint2 = "Divide 10 by 1.618",
            hint3 = "10 ÷ 1.618 = ?",
            explanation = "The golden ratio was used extensively in Renaissance architecture to create visually pleasing proportions.",
            formula = "φ = 1.618..."
        };
    }

    /// <summary>
    /// Skip challenge (for testing/debug)
    /// </summary>
    public void SkipChallenge()
    {
        OnCorrectAnswer();
    }
}

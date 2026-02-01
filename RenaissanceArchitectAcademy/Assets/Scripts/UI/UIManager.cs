using UnityEngine;
using UnityEngine.UI;
using TMPro;

/// <summary>
/// Manages all UI panels and navigation
/// Leonardo da Vinci notebook aesthetic
/// </summary>
public class UIManager : MonoBehaviour
{
    public static UIManager Instance { get; private set; }

    [Header("Main Menu Panels")]
    [SerializeField] private GameObject mainMenuPanel;
    [SerializeField] private GameObject settingsPanel;
    [SerializeField] private GameObject creditsPanel;

    [Header("Game UI Panels")]
    [SerializeField] private GameObject gameHUDPanel;
    [SerializeField] private GameObject buildingMenuPanel;
    [SerializeField] private GameObject challengePanel;
    [SerializeField] private GameObject pauseMenuPanel;

    [Header("Resource Display")]
    [SerializeField] private TextMeshProUGUI goldText;
    [SerializeField] private TextMeshProUGUI stoneText;
    [SerializeField] private TextMeshProUGUI woodText;

    [Header("Animation Settings")]
    [SerializeField] private float panelFadeDuration = 0.3f;

    private GameObject currentActivePanel;

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
        // Subscribe to resource changes
        if (ResourceManager.Instance != null)
        {
            ResourceManager.Instance.OnGoldChanged += UpdateGoldDisplay;
            ResourceManager.Instance.OnStoneChanged += UpdateStoneDisplay;
            ResourceManager.Instance.OnWoodChanged += UpdateWoodDisplay;
            RefreshResourceDisplay();
        }
    }

    private void OnDestroy()
    {
        if (ResourceManager.Instance != null)
        {
            ResourceManager.Instance.OnGoldChanged -= UpdateGoldDisplay;
            ResourceManager.Instance.OnStoneChanged -= UpdateStoneDisplay;
            ResourceManager.Instance.OnWoodChanged -= UpdateWoodDisplay;
        }
    }

    // Panel Management
    public void ShowPanel(GameObject panel)
    {
        if (currentActivePanel != null)
        {
            currentActivePanel.SetActive(false);
        }

        if (panel != null)
        {
            panel.SetActive(true);
            currentActivePanel = panel;
        }
    }

    public void HideAllPanels()
    {
        if (mainMenuPanel != null) mainMenuPanel.SetActive(false);
        if (settingsPanel != null) settingsPanel.SetActive(false);
        if (creditsPanel != null) creditsPanel.SetActive(false);
        if (buildingMenuPanel != null) buildingMenuPanel.SetActive(false);
        if (challengePanel != null) challengePanel.SetActive(false);
        if (pauseMenuPanel != null) pauseMenuPanel.SetActive(false);
        currentActivePanel = null;
    }

    // Main Menu Navigation
    public void ShowMainMenu()
    {
        HideAllPanels();
        ShowPanel(mainMenuPanel);
    }

    public void ShowSettings()
    {
        ShowPanel(settingsPanel);
    }

    public void ShowCredits()
    {
        ShowPanel(creditsPanel);
    }

    // Game UI
    public void ShowGameHUD()
    {
        if (gameHUDPanel != null)
        {
            gameHUDPanel.SetActive(true);
        }
        RefreshResourceDisplay();
    }

    public void HideGameHUD()
    {
        if (gameHUDPanel != null)
        {
            gameHUDPanel.SetActive(false);
        }
    }

    public void ShowBuildingMenu()
    {
        ShowPanel(buildingMenuPanel);
    }

    public void HideBuildingMenu()
    {
        if (buildingMenuPanel != null)
        {
            buildingMenuPanel.SetActive(false);
        }
    }

    public void ShowChallengePanel()
    {
        ShowPanel(challengePanel);
    }

    public void HideChallengePanel()
    {
        if (challengePanel != null)
        {
            challengePanel.SetActive(false);
        }
    }

    public void ShowPauseMenu()
    {
        ShowPanel(pauseMenuPanel);
    }

    public void HidePauseMenu()
    {
        if (pauseMenuPanel != null)
        {
            pauseMenuPanel.SetActive(false);
        }
    }

    // Resource Display Updates
    private void UpdateGoldDisplay(int amount)
    {
        if (goldText != null)
        {
            goldText.text = $"💰 {amount}";
        }
    }

    private void UpdateStoneDisplay(int amount)
    {
        if (stoneText != null)
        {
            stoneText.text = $"🪨 {amount}";
        }
    }

    private void UpdateWoodDisplay(int amount)
    {
        if (woodText != null)
        {
            woodText.text = $"🪵 {amount}";
        }
    }

    public void RefreshResourceDisplay()
    {
        if (ResourceManager.Instance != null)
        {
            UpdateGoldDisplay(ResourceManager.Instance.Gold);
            UpdateStoneDisplay(ResourceManager.Instance.Stone);
            UpdateWoodDisplay(ResourceManager.Instance.Wood);
        }
    }

    // Button callbacks for Main Menu
    public void OnPlayButtonClicked()
    {
        Debug.Log("[UIManager] Play button clicked");
        GameManager.Instance?.StartNewGame();
    }

    public void OnSettingsButtonClicked()
    {
        Debug.Log("[UIManager] Settings button clicked");
        ShowSettings();
    }

    public void OnCreditsButtonClicked()
    {
        Debug.Log("[UIManager] Credits button clicked");
        ShowCredits();
    }

    public void OnBackButtonClicked()
    {
        Debug.Log("[UIManager] Back button clicked");
        ShowMainMenu();
    }

    public void OnQuitButtonClicked()
    {
        Debug.Log("[UIManager] Quit button clicked");
        GameManager.Instance?.QuitGame();
    }

    public void OnResumeButtonClicked()
    {
        HidePauseMenu();
        GameManager.Instance?.ResumeGame();
    }

    public void OnMainMenuButtonClicked()
    {
        Time.timeScale = 1f;
        GameManager.Instance?.LoadMainMenu();
    }
}

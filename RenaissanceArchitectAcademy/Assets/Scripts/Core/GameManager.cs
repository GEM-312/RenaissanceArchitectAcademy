using UnityEngine;
using UnityEngine.SceneManagement;

/// <summary>
/// Core game manager singleton - persists across scenes
/// Handles game state, scene transitions, and global settings
/// </summary>
public class GameManager : MonoBehaviour
{
    public static GameManager Instance { get; private set; }

    [Header("Game State")]
    [SerializeField] private GameState currentState = GameState.MainMenu;

    [Header("Scene Names")]
    [SerializeField] private string mainMenuScene = "MainMenu";
    [SerializeField] private string citySelectionScene = "CitySelection";
    [SerializeField] private string florenceScene = "Florence_City";

    [Header("Settings")]
    [SerializeField] private bool enableTutorial = true;
    [SerializeField] private float masterVolume = 1f;

    public GameState CurrentState => currentState;
    public bool EnableTutorial => enableTutorial;
    public float MasterVolume => masterVolume;

    public enum GameState
    {
        MainMenu,
        CitySelection,
        Playing,
        Challenge,
        Paused,
        BuildingPlacement
    }

    private void Awake()
    {
        if (Instance == null)
        {
            Instance = this;
            DontDestroyOnLoad(gameObject);
            InitializeGame();
        }
        else
        {
            Destroy(gameObject);
        }
    }

    private void InitializeGame()
    {
        Application.targetFrameRate = 60;
        Debug.Log("[GameManager] Renaissance Architect Academy initialized");
    }

    public void SetState(GameState newState)
    {
        GameState previousState = currentState;
        currentState = newState;
        Debug.Log($"[GameManager] State changed: {previousState} -> {newState}");
        OnStateChanged?.Invoke(previousState, newState);
    }

    public delegate void StateChangedHandler(GameState previousState, GameState newState);
    public event StateChangedHandler OnStateChanged;

    // Scene Navigation
    public void LoadMainMenu()
    {
        SetState(GameState.MainMenu);
        SceneManager.LoadScene(mainMenuScene);
    }

    public void LoadCitySelection()
    {
        SetState(GameState.CitySelection);
        SceneManager.LoadScene(citySelectionScene);
    }

    public void LoadFlorence()
    {
        SetState(GameState.Playing);
        SceneManager.LoadScene(florenceScene);
    }

    public void StartNewGame()
    {
        ResourceManager.Instance?.ResetResources();
        LoadFlorence();
    }

    public void PauseGame()
    {
        if (currentState == GameState.Playing)
        {
            SetState(GameState.Paused);
            Time.timeScale = 0f;
        }
    }

    public void ResumeGame()
    {
        if (currentState == GameState.Paused)
        {
            SetState(GameState.Playing);
            Time.timeScale = 1f;
        }
    }

    public void QuitGame()
    {
        Debug.Log("[GameManager] Quitting game...");
        #if UNITY_EDITOR
            UnityEditor.EditorApplication.isPlaying = false;
        #else
            Application.Quit();
        #endif
    }

    // Settings
    public void SetMasterVolume(float volume)
    {
        masterVolume = Mathf.Clamp01(volume);
        AudioListener.volume = masterVolume;
    }

    public void SetTutorialEnabled(bool enabled)
    {
        enableTutorial = enabled;
    }
}

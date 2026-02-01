#if UNITY_EDITOR
using UnityEngine;
using UnityEditor;
using UnityEngine.UI;
using TMPro;
using UnityEditor.SceneManagement;

/// <summary>
/// Editor tools for quickly setting up Renaissance Architect Academy scenes
/// Access via menu: Tools > Renaissance Academy
/// </summary>
public class RenaissanceAcademySetup : EditorWindow
{
    [MenuItem("Tools/Renaissance Academy/Setup Main Menu Scene")]
    public static void SetupMainMenuScene()
    {
        if (!EditorUtility.DisplayDialog("Setup Main Menu",
            "This will create the MainMenu scene structure. Continue?", "Yes", "Cancel"))
            return;

        // Create new scene
        var scene = EditorSceneManager.NewScene(NewSceneSetup.DefaultGameObjects, NewSceneMode.Single);

        // Set camera background to parchment
        Camera.main.backgroundColor = GameColors.Parchment;
        Camera.main.orthographic = true;

        // Create GameManager
        CreateGameManager();

        // Create Canvas
        GameObject canvas = CreateMainMenuCanvas();

        // Create EventSystem if not exists
        if (FindObjectOfType<UnityEngine.EventSystems.EventSystem>() == null)
        {
            var eventSystem = new GameObject("EventSystem");
            eventSystem.AddComponent<UnityEngine.EventSystems.EventSystem>();
            eventSystem.AddComponent<UnityEngine.EventSystems.StandaloneInputModule>();
        }

        // Save scene
        EditorSceneManager.SaveScene(scene, "Assets/Scenes/MainMenu.unity");

        Debug.Log("[Renaissance Academy] Main Menu scene created successfully!");
    }

    [MenuItem("Tools/Renaissance Academy/Setup Florence City Scene")]
    public static void SetupFlorenceCityScene()
    {
        if (!EditorUtility.DisplayDialog("Setup Florence City",
            "This will create the Florence City scene structure. Continue?", "Yes", "Cancel"))
            return;

        var scene = EditorSceneManager.NewScene(NewSceneSetup.DefaultGameObjects, NewSceneMode.Single);

        // Setup camera for isometric view
        Camera.main.backgroundColor = GameColors.Parchment;
        Camera.main.orthographic = true;
        Camera.main.orthographicSize = 8f;
        Camera.main.gameObject.AddComponent<IsometricCameraController>();

        // Create managers
        CreateGameManager();
        CreateCityManager();

        // Create building plots
        CreateBuildingPlots();

        // Create UI Canvas
        CreateGameUICanvas();

        // Create EventSystem
        if (FindObjectOfType<UnityEngine.EventSystems.EventSystem>() == null)
        {
            var eventSystem = new GameObject("EventSystem");
            eventSystem.AddComponent<UnityEngine.EventSystems.EventSystem>();
            eventSystem.AddComponent<UnityEngine.EventSystems.StandaloneInputModule>();
        }

        EditorSceneManager.SaveScene(scene, "Assets/Scenes/Florence_City.unity");

        Debug.Log("[Renaissance Academy] Florence City scene created successfully!");
    }

    [MenuItem("Tools/Renaissance Academy/Create Building Plot Prefab")]
    public static void CreateBuildingPlotPrefab()
    {
        GameObject plot = new GameObject("BuildingPlot");

        // Add sprite renderer
        var sr = plot.AddComponent<SpriteRenderer>();
        sr.color = GameColors.BlueprintFill;
        sr.sortingOrder = 0;

        // Add collider
        var collider = plot.AddComponent<BoxCollider2D>();
        collider.size = new Vector2(3f, 2f);

        // Add BuildingPlot script
        plot.AddComponent<BuildingPlot>();

        // Save as prefab
        string path = "Assets/Prefabs/BuildingPlot.prefab";
        PrefabUtility.SaveAsPrefabAsset(plot, path);
        DestroyImmediate(plot);

        Debug.Log($"[Renaissance Academy] Building Plot prefab created at {path}");
    }

    [MenuItem("Tools/Renaissance Academy/Apply Renaissance Style to Selected UI")]
    public static void ApplyRenaissanceStyle()
    {
        foreach (var obj in Selection.gameObjects)
        {
            ApplyStyleRecursive(obj);
        }
        Debug.Log("[Renaissance Academy] Style applied to selected objects");
    }

    private static void ApplyStyleRecursive(GameObject obj)
    {
        // Style images
        var image = obj.GetComponent<Image>();
        if (image != null)
        {
            if (obj.name.ToLower().Contains("background") || obj.name.ToLower().Contains("panel"))
            {
                image.color = GameColors.Parchment;
            }
            else if (obj.name.ToLower().Contains("button"))
            {
                image.color = GameColors.Terracotta;
            }
        }

        // Style text
        var text = obj.GetComponent<TextMeshProUGUI>();
        if (text != null)
        {
            text.color = GameColors.SepiaInk;

            if (obj.name.ToLower().Contains("title"))
            {
                text.fontSize = 48;
            }
            else if (obj.name.ToLower().Contains("button"))
            {
                text.color = GameColors.ParchmentLight;
                text.fontSize = 24;
            }
        }

        // Recurse to children
        foreach (Transform child in obj.transform)
        {
            ApplyStyleRecursive(child.gameObject);
        }
    }

    private static void CreateGameManager()
    {
        if (FindObjectOfType<GameManager>() != null) return;

        GameObject managers = new GameObject("--- MANAGERS ---");

        GameObject gmObj = new GameObject("GameManager");
        gmObj.transform.SetParent(managers.transform);
        gmObj.AddComponent<GameManager>();

        GameObject rmObj = new GameObject("ResourceManager");
        rmObj.transform.SetParent(managers.transform);
        rmObj.AddComponent<ResourceManager>();

        GameObject srsObj = new GameObject("SealRewardSystem");
        srsObj.transform.SetParent(managers.transform);
        srsObj.AddComponent<SealRewardSystem>();

        GameObject baObj = new GameObject("BuildingAnimator");
        baObj.transform.SetParent(managers.transform);
        baObj.AddComponent<BuildingAnimator>();
    }

    private static void CreateCityManager()
    {
        GameObject cmObj = new GameObject("CityManager");
        cmObj.AddComponent<CityManager>();

        GameObject cmgObj = new GameObject("ChallengeManager");
        cmgObj.AddComponent<ChallengeManager>();

        GameObject svoObj = new GameObject("ScienceVisualizationOverlay");
        svoObj.AddComponent<ScienceVisualizationOverlay>();
    }

    private static GameObject CreateMainMenuCanvas()
    {
        // Create Canvas
        GameObject canvasObj = new GameObject("MainMenuCanvas");
        Canvas canvas = canvasObj.AddComponent<Canvas>();
        canvas.renderMode = RenderMode.ScreenSpaceOverlay;
        canvasObj.AddComponent<CanvasScaler>().uiScaleMode = CanvasScaler.ScaleMode.ScaleWithScreenSize;
        canvasObj.AddComponent<GraphicRaycaster>();

        // Add UIManager
        canvasObj.AddComponent<UIManager>();

        // Background Panel
        GameObject bgPanel = CreatePanel(canvasObj.transform, "BackgroundPanel", GameColors.Parchment);
        var bgRect = bgPanel.GetComponent<RectTransform>();
        bgRect.anchorMin = Vector2.zero;
        bgRect.anchorMax = Vector2.one;
        bgRect.sizeDelta = Vector2.zero;

        // Main Menu Panel
        GameObject mainMenuPanel = CreatePanel(bgPanel.transform, "MainMenuPanel", new Color(0, 0, 0, 0));
        mainMenuPanel.AddComponent<MainMenuController>();
        mainMenuPanel.AddComponent<CanvasGroup>();

        // Title
        CreateText(mainMenuPanel.transform, "TitleText", "Renaissance Architect Academy",
            new Vector2(0, 200), 48, GameColors.SepiaInk);

        // Subtitle
        CreateText(mainMenuPanel.transform, "SubtitleText", "Learn Like Leonardo. Build Like Brunelleschi.",
            new Vector2(0, 140), 24, GameColors.SepiaLight);

        // Tagline
        CreateText(mainMenuPanel.transform, "TaglineText", "A fusion of Art, History, and 13+ STEM Sciences.",
            new Vector2(0, 100), 18, GameColors.RenaissanceBlue);

        // Buttons
        CreateButton(mainMenuPanel.transform, "PlayButton", "Play", new Vector2(0, -20), GameColors.Terracotta);
        CreateButton(mainMenuPanel.transform, "SettingsButton", "Settings", new Vector2(0, -90), GameColors.Ochre);
        CreateButton(mainMenuPanel.transform, "CreditsButton", "Credits", new Vector2(0, -160), GameColors.SageGreen);
        CreateButton(mainMenuPanel.transform, "QuitButton", "Quit", new Vector2(0, -230), GameColors.SepiaLight);

        return canvasObj;
    }

    private static void CreateGameUICanvas()
    {
        GameObject canvasObj = new GameObject("GameUICanvas");
        Canvas canvas = canvasObj.AddComponent<Canvas>();
        canvas.renderMode = RenderMode.ScreenSpaceOverlay;
        var scaler = canvasObj.AddComponent<CanvasScaler>();
        scaler.uiScaleMode = CanvasScaler.ScaleMode.ScaleWithScreenSize;
        scaler.referenceResolution = new Vector2(1920, 1080);
        canvasObj.AddComponent<GraphicRaycaster>();
        canvasObj.AddComponent<UIManager>();

        // HUD Panel (top bar with resources)
        GameObject hudPanel = CreatePanel(canvasObj.transform, "HUDPanel", new Color(0, 0, 0, 0.3f));
        var hudRect = hudPanel.GetComponent<RectTransform>();
        hudRect.anchorMin = new Vector2(0, 1);
        hudRect.anchorMax = new Vector2(1, 1);
        hudRect.pivot = new Vector2(0.5f, 1);
        hudRect.sizeDelta = new Vector2(0, 80);
        hudRect.anchoredPosition = Vector2.zero;

        // Resource displays
        CreateText(hudPanel.transform, "GoldText", "Gold: 1000", new Vector2(-300, -40), 24, GameColors.GoldAccent);
        CreateText(hudPanel.transform, "StoneText", "Stone: 50", new Vector2(0, -40), 24, GameColors.SepiaInk);
        CreateText(hudPanel.transform, "WoodText", "Wood: 50", new Vector2(300, -40), 24, GameColors.Terracotta);

        // Building Menu Panel (hidden by default)
        GameObject buildingMenuPanel = CreatePanel(canvasObj.transform, "BuildingMenuPanel", GameColors.Parchment);
        buildingMenuPanel.SetActive(false);
        var bmRect = buildingMenuPanel.GetComponent<RectTransform>();
        bmRect.anchorMin = new Vector2(0.5f, 0.5f);
        bmRect.anchorMax = new Vector2(0.5f, 0.5f);
        bmRect.sizeDelta = new Vector2(600, 500);
        buildingMenuPanel.AddComponent<BuildingSelectionMenu>();

        // Challenge Panel (hidden by default)
        GameObject challengePanel = CreatePanel(canvasObj.transform, "ChallengePanel", GameColors.Parchment);
        challengePanel.SetActive(false);
        var cpRect = challengePanel.GetComponent<RectTransform>();
        cpRect.anchorMin = new Vector2(0.5f, 0.5f);
        cpRect.anchorMax = new Vector2(0.5f, 0.5f);
        cpRect.sizeDelta = new Vector2(700, 600);
    }

    private static void CreateBuildingPlots()
    {
        GameObject plotsParent = new GameObject("--- BUILDING PLOTS ---");

        // Create 6 plots in a grid
        Vector3[] positions = new Vector3[]
        {
            new Vector3(-6, 2, 0),
            new Vector3(0, 2, 0),
            new Vector3(6, 2, 0),
            new Vector3(-6, -2, 0),
            new Vector3(0, -2, 0),
            new Vector3(6, -2, 0)
        };

        for (int i = 0; i < positions.Length; i++)
        {
            GameObject plot = new GameObject($"BuildingPlot_{i + 1}");
            plot.transform.SetParent(plotsParent.transform);
            plot.transform.position = positions[i];

            var sr = plot.AddComponent<SpriteRenderer>();
            sr.color = GameColors.BlueprintFill;

            var collider = plot.AddComponent<BoxCollider2D>();
            collider.size = new Vector2(4f, 3f);

            var bp = plot.AddComponent<BuildingPlot>();

            // Create placeholder sprite (blueprint-style rectangle)
            CreatePlotVisual(plot.transform);
        }
    }

    private static void CreatePlotVisual(Transform parent)
    {
        // Create a simple visual placeholder
        GameObject visual = new GameObject("PlotVisual");
        visual.transform.SetParent(parent);
        visual.transform.localPosition = Vector3.zero;

        var sr = visual.AddComponent<SpriteRenderer>();
        sr.color = new Color(GameColors.BlueprintLine.r, GameColors.BlueprintLine.g, GameColors.BlueprintLine.b, 0.3f);

        // Create border lines
        for (int i = 0; i < 4; i++)
        {
            GameObject line = new GameObject($"Border_{i}");
            line.transform.SetParent(visual.transform);
            var lineSr = line.AddComponent<SpriteRenderer>();
            lineSr.color = GameColors.BlueprintLine;
        }
    }

    private static GameObject CreatePanel(Transform parent, string name, Color color)
    {
        GameObject panel = new GameObject(name);
        panel.transform.SetParent(parent, false);

        var image = panel.AddComponent<Image>();
        image.color = color;

        var rect = panel.GetComponent<RectTransform>();
        rect.anchorMin = new Vector2(0.5f, 0.5f);
        rect.anchorMax = new Vector2(0.5f, 0.5f);
        rect.sizeDelta = new Vector2(800, 600);

        return panel;
    }

    private static GameObject CreateText(Transform parent, string name, string content, Vector2 position, float fontSize, Color color)
    {
        GameObject textObj = new GameObject(name);
        textObj.transform.SetParent(parent, false);

        var text = textObj.AddComponent<TextMeshProUGUI>();
        text.text = content;
        text.fontSize = fontSize;
        text.color = color;
        text.alignment = TextAlignmentOptions.Center;

        var rect = textObj.GetComponent<RectTransform>();
        rect.anchoredPosition = position;
        rect.sizeDelta = new Vector2(600, 60);

        return textObj;
    }

    private static GameObject CreateButton(Transform parent, string name, string label, Vector2 position, Color color)
    {
        GameObject buttonObj = new GameObject(name);
        buttonObj.transform.SetParent(parent, false);

        var image = buttonObj.AddComponent<Image>();
        image.color = color;

        var button = buttonObj.AddComponent<Button>();
        var colors = button.colors;
        colors.normalColor = color;
        colors.highlightedColor = Color.Lerp(color, Color.white, 0.2f);
        colors.pressedColor = Color.Lerp(color, Color.black, 0.2f);
        button.colors = colors;

        var rect = buttonObj.GetComponent<RectTransform>();
        rect.anchoredPosition = position;
        rect.sizeDelta = new Vector2(250, 55);

        // Button text
        GameObject textObj = new GameObject("Text");
        textObj.transform.SetParent(buttonObj.transform, false);

        var text = textObj.AddComponent<TextMeshProUGUI>();
        text.text = label;
        text.fontSize = 24;
        text.color = GameColors.ParchmentLight;
        text.alignment = TextAlignmentOptions.Center;

        var textRect = textObj.GetComponent<RectTransform>();
        textRect.anchorMin = Vector2.zero;
        textRect.anchorMax = Vector2.one;
        textRect.sizeDelta = Vector2.zero;

        return buttonObj;
    }

    // ============ WINDOW FOR ADDITIONAL TOOLS ============

    [MenuItem("Tools/Renaissance Academy/Open Setup Window")]
    public static void OpenSetupWindow()
    {
        GetWindow<RenaissanceAcademySetup>("Renaissance Academy Setup");
    }

    private Vector2 scrollPos;

    private void OnGUI()
    {
        scrollPos = EditorGUILayout.BeginScrollView(scrollPos);

        GUILayout.Label("Renaissance Architect Academy", EditorStyles.boldLabel);
        GUILayout.Label("Quick Setup Tools", EditorStyles.miniLabel);

        EditorGUILayout.Space(10);

        GUILayout.Label("Scene Setup", EditorStyles.boldLabel);

        if (GUILayout.Button("Create Main Menu Scene", GUILayout.Height(30)))
        {
            SetupMainMenuScene();
        }

        if (GUILayout.Button("Create Florence City Scene", GUILayout.Height(30)))
        {
            SetupFlorenceCityScene();
        }

        EditorGUILayout.Space(10);

        GUILayout.Label("Prefabs", EditorStyles.boldLabel);

        if (GUILayout.Button("Create Building Plot Prefab", GUILayout.Height(25)))
        {
            CreateBuildingPlotPrefab();
        }

        EditorGUILayout.Space(10);

        GUILayout.Label("Style", EditorStyles.boldLabel);

        if (GUILayout.Button("Apply Renaissance Style to Selection", GUILayout.Height(25)))
        {
            ApplyRenaissanceStyle();
        }

        EditorGUILayout.Space(20);

        GUILayout.Label("Color Palette Preview", EditorStyles.boldLabel);
        DrawColorSwatch("Parchment", GameColors.Parchment);
        DrawColorSwatch("Sepia Ink", GameColors.SepiaInk);
        DrawColorSwatch("Renaissance Blue", GameColors.RenaissanceBlue);
        DrawColorSwatch("Terracotta", GameColors.Terracotta);
        DrawColorSwatch("Ochre", GameColors.Ochre);
        DrawColorSwatch("Sage Green", GameColors.SageGreen);

        EditorGUILayout.EndScrollView();
    }

    private void DrawColorSwatch(string name, Color color)
    {
        EditorGUILayout.BeginHorizontal();
        EditorGUILayout.LabelField(name, GUILayout.Width(120));
        EditorGUILayout.ColorField(GUIContent.none, color, false, false, false, GUILayout.Width(60));
        EditorGUILayout.EndHorizontal();
    }
}
#endif

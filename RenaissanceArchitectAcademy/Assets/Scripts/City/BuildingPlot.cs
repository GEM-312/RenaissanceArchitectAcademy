using UnityEngine;
using System.Collections;

/// <summary>
/// Clickable building plot that shows blueprint outline when empty
/// Handles hover effects, click detection, and building placement
/// </summary>
[RequireComponent(typeof(SpriteRenderer))]
[RequireComponent(typeof(Collider2D))]
public class BuildingPlot : MonoBehaviour
{
    [Header("Plot Info")]
    [SerializeField] private int plotIndex;
    [SerializeField] private string plotName = "Building Plot";

    [Header("Sprites")]
    [SerializeField] private Sprite emptyPlotSprite;
    [SerializeField] private Sprite highlightedPlotSprite;

    [Header("Current State")]
    [SerializeField] private bool hasBuilding = false;
    [SerializeField] private BuildingData currentBuilding;
    [SerializeField] private GameObject constructedBuildingObject;

    [Header("Visual Settings")]
    [SerializeField] private Color normalColor = Color.white;
    [SerializeField] private Color hoverColor = new Color(1f, 1f, 0.8f, 1f);
    [SerializeField] private Color unavailableColor = new Color(0.5f, 0.5f, 0.5f, 0.5f);

    [Header("Animation")]
    [SerializeField] private float pulseSpeed = 2f;
    [SerializeField] private float pulseAmount = 0.1f;

    private SpriteRenderer spriteRenderer;
    private bool isHovered = false;
    private bool isInteractable = true;

    public int PlotIndex => plotIndex;
    public bool HasBuilding => hasBuilding;
    public BuildingData CurrentBuilding => currentBuilding;

    public event System.Action<BuildingPlot> OnPlotClicked;
    public event System.Action<BuildingPlot> OnPlotHoverEnter;
    public event System.Action<BuildingPlot> OnPlotHoverExit;

    private void Awake()
    {
        spriteRenderer = GetComponent<SpriteRenderer>();

        // Ensure we have a collider for click detection
        var collider = GetComponent<Collider2D>();
        if (collider == null)
        {
            gameObject.AddComponent<BoxCollider2D>();
        }
    }

    private void Start()
    {
        // Register with CityManager
        CityManager.Instance?.RegisterPlot(this);

        UpdateVisuals();
    }

    private void Update()
    {
        if (!hasBuilding && isHovered && isInteractable)
        {
            // Subtle pulse effect on hover
            float pulse = 1f + Mathf.Sin(Time.time * pulseSpeed) * pulseAmount;
            transform.localScale = Vector3.one * pulse;
        }
    }

    private void OnMouseEnter()
    {
        if (!isInteractable || hasBuilding) return;

        isHovered = true;
        spriteRenderer.color = hoverColor;

        if (highlightedPlotSprite != null)
        {
            spriteRenderer.sprite = highlightedPlotSprite;
        }

        OnPlotHoverEnter?.Invoke(this);
    }

    private void OnMouseExit()
    {
        isHovered = false;
        transform.localScale = Vector3.one;

        if (!hasBuilding)
        {
            spriteRenderer.color = normalColor;
            if (emptyPlotSprite != null)
            {
                spriteRenderer.sprite = emptyPlotSprite;
            }
        }

        OnPlotHoverExit?.Invoke(this);
    }

    private void OnMouseDown()
    {
        if (!isInteractable) return;

        if (hasBuilding)
        {
            // Show building info
            Debug.Log($"[BuildingPlot] Clicked on {currentBuilding?.BuildingName ?? "building"}");
        }
        else
        {
            // Open building menu
            Debug.Log($"[BuildingPlot] Plot {plotIndex} clicked - opening build menu");
            OnPlotClicked?.Invoke(this);
            OpenBuildMenu();
        }
    }

    private void OpenBuildMenu()
    {
        GameManager.Instance?.SetState(GameManager.GameState.BuildingPlacement);
        UIManager.Instance?.ShowBuildingMenu();

        // Camera focus on this plot
        IsometricCameraController.Instance?.FocusOn(transform.position, 0.5f);
    }

    /// <summary>
    /// Place a building on this plot with bloom animation
    /// </summary>
    public void PlaceBuilding(BuildingData building, GameObject buildingPrefab)
    {
        if (hasBuilding)
        {
            Debug.LogWarning($"[BuildingPlot] Plot {plotIndex} already has a building!");
            return;
        }

        currentBuilding = building;
        hasBuilding = true;

        // Instantiate the building
        if (buildingPrefab != null)
        {
            constructedBuildingObject = Instantiate(buildingPrefab, transform.position, Quaternion.identity, transform);

            // Start bloom animation
            StartCoroutine(BloomAnimation(constructedBuildingObject));
        }

        // Update visuals
        UpdateVisuals();

        // Notify CityManager
        CityManager.Instance?.OnBuildingPlaced(this, building);

        // Focus camera on new building
        IsometricCameraController.Instance?.FocusOn(transform.position, 1f);
    }

    private IEnumerator BloomAnimation(GameObject buildingObj)
    {
        var renderer = buildingObj.GetComponent<SpriteRenderer>();
        if (renderer == null) yield break;

        float bloomDuration = 2.5f;
        float elapsed = 0f;

        // Start with gray/blueprint color
        renderer.color = Color.gray;

        while (elapsed < bloomDuration)
        {
            elapsed += Time.deltaTime;
            float t = elapsed / bloomDuration;

            // Fade from gray to full color
            renderer.color = Color.Lerp(Color.gray, Color.white, t);

            // Subtle scale pulse for bloom effect
            float scale = 1f + Mathf.Sin(t * Mathf.PI) * 0.1f;
            buildingObj.transform.localScale = Vector3.one * scale;

            yield return null;
        }

        // Final state
        renderer.color = Color.white;
        buildingObj.transform.localScale = Vector3.one;

        Debug.Log($"[BuildingPlot] Bloom animation complete for {currentBuilding?.BuildingName}");
    }

    private void UpdateVisuals()
    {
        if (hasBuilding)
        {
            // Hide the plot sprite, building is now visible
            spriteRenderer.color = new Color(1f, 1f, 1f, 0f);
            isInteractable = true; // Still clickable to show info
        }
        else
        {
            spriteRenderer.color = normalColor;
            if (emptyPlotSprite != null)
            {
                spriteRenderer.sprite = emptyPlotSprite;
            }
        }
    }

    public void SetInteractable(bool interactable)
    {
        isInteractable = interactable;

        if (!interactable && !hasBuilding)
        {
            spriteRenderer.color = unavailableColor;
        }
        else if (!hasBuilding)
        {
            spriteRenderer.color = normalColor;
        }
    }

    /// <summary>
    /// Remove building from plot (for testing/reset)
    /// </summary>
    public void ClearPlot()
    {
        if (constructedBuildingObject != null)
        {
            Destroy(constructedBuildingObject);
        }

        hasBuilding = false;
        currentBuilding = null;
        constructedBuildingObject = null;

        UpdateVisuals();
    }
}

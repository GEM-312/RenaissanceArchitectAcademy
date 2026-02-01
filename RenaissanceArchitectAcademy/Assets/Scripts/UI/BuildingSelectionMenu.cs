using UnityEngine;
using UnityEngine.UI;
using TMPro;
using System.Collections.Generic;

/// <summary>
/// UI for selecting which building to construct on a plot
/// Shows era selection, building options, costs, and previews
/// </summary>
public class BuildingSelectionMenu : MonoBehaviour
{
    [Header("Panel References")]
    [SerializeField] private GameObject eraSelectionPanel;
    [SerializeField] private GameObject buildingListPanel;
    [SerializeField] private GameObject buildingPreviewPanel;

    [Header("Era Selection")]
    [SerializeField] private Button ancientRomeButton;
    [SerializeField] private Button renaissanceButton;

    [Header("Building List")]
    [SerializeField] private Transform buildingButtonContainer;
    [SerializeField] private GameObject buildingButtonPrefab;

    [Header("Preview Panel")]
    [SerializeField] private Image previewImage;
    [SerializeField] private TextMeshProUGUI buildingNameText;
    [SerializeField] private TextMeshProUGUI descriptionText;
    [SerializeField] private TextMeshProUGUI costText;
    [SerializeField] private TextMeshProUGUI historicalFactText;
    [SerializeField] private Button confirmButton;
    [SerializeField] private Button cancelButton;

    [Header("Building Data")]
    [SerializeField] private List<BuildingData> romanBuildings = new List<BuildingData>();
    [SerializeField] private List<BuildingData> renaissanceBuildings = new List<BuildingData>();

    private BuildingPlot currentPlot;
    private BuildingData selectedBuilding;
    private BuildingEra selectedEra;

    private void Start()
    {
        // Setup button listeners
        if (ancientRomeButton != null)
            ancientRomeButton.onClick.AddListener(() => SelectEra(BuildingEra.AncientRome));

        if (renaissanceButton != null)
            renaissanceButton.onClick.AddListener(() => SelectEra(BuildingEra.Renaissance));

        if (confirmButton != null)
            confirmButton.onClick.AddListener(ConfirmBuilding);

        if (cancelButton != null)
            cancelButton.onClick.AddListener(Cancel);

        // Style era buttons
        StyleEraButton(ancientRomeButton, "Ancient Rome", GameColors.Terracotta);
        StyleEraButton(renaissanceButton, "Renaissance", GameColors.RenaissanceBlue);

        // Hide initially
        gameObject.SetActive(false);
    }

    private void StyleEraButton(Button button, string text, Color color)
    {
        if (button == null) return;

        var image = button.GetComponent<Image>();
        if (image != null) image.color = color;

        var buttonText = button.GetComponentInChildren<TextMeshProUGUI>();
        if (buttonText != null)
        {
            buttonText.text = text;
            buttonText.color = GameColors.ParchmentLight;
        }
    }

    /// <summary>
    /// Open the building selection menu for a specific plot
    /// </summary>
    public void OpenForPlot(BuildingPlot plot)
    {
        currentPlot = plot;
        selectedBuilding = null;

        // Show era selection first
        ShowEraSelection();

        gameObject.SetActive(true);
        Debug.Log($"[BuildingSelectionMenu] Opened for plot {plot.PlotIndex}");
    }

    private void ShowEraSelection()
    {
        if (eraSelectionPanel != null) eraSelectionPanel.SetActive(true);
        if (buildingListPanel != null) buildingListPanel.SetActive(false);
        if (buildingPreviewPanel != null) buildingPreviewPanel.SetActive(false);
    }

    private void SelectEra(BuildingEra era)
    {
        selectedEra = era;
        Debug.Log($"[BuildingSelectionMenu] Selected era: {era}");

        // Show building list for selected era
        ShowBuildingList(era);
    }

    private void ShowBuildingList(BuildingEra era)
    {
        if (eraSelectionPanel != null) eraSelectionPanel.SetActive(false);
        if (buildingListPanel != null) buildingListPanel.SetActive(true);
        if (buildingPreviewPanel != null) buildingPreviewPanel.SetActive(false);

        // Clear existing buttons
        if (buildingButtonContainer != null)
        {
            foreach (Transform child in buildingButtonContainer)
            {
                Destroy(child.gameObject);
            }
        }

        // Get buildings for this era
        List<BuildingData> buildings = era == BuildingEra.AncientRome ? romanBuildings : renaissanceBuildings;

        // Create buttons for each building
        foreach (var building in buildings)
        {
            CreateBuildingButton(building);
        }
    }

    private void CreateBuildingButton(BuildingData building)
    {
        if (buildingButtonPrefab == null || buildingButtonContainer == null) return;

        GameObject buttonObj = Instantiate(buildingButtonPrefab, buildingButtonContainer);
        Button button = buttonObj.GetComponent<Button>();

        // Setup button visuals
        var buttonText = buttonObj.GetComponentInChildren<TextMeshProUGUI>();
        if (buttonText != null)
        {
            buttonText.text = building.BuildingName;
        }

        // Set icon if available
        var iconImage = buttonObj.transform.Find("Icon")?.GetComponent<Image>();
        if (iconImage != null && building.IconSprite != null)
        {
            iconImage.sprite = building.IconSprite;
        }

        // Show cost
        var costTextComponent = buttonObj.transform.Find("Cost")?.GetComponent<TextMeshProUGUI>();
        if (costTextComponent != null)
        {
            costTextComponent.text = building.GetCostString();
        }

        // Gray out if can't afford
        if (!building.CanAfford())
        {
            var image = buttonObj.GetComponent<Image>();
            if (image != null) image.color = GameColors.SepiaLight;
            button.interactable = false;
        }

        // Add click listener
        button.onClick.AddListener(() => SelectBuilding(building));
    }

    private void SelectBuilding(BuildingData building)
    {
        selectedBuilding = building;
        Debug.Log($"[BuildingSelectionMenu] Selected building: {building.BuildingName}");

        ShowPreview(building);
    }

    private void ShowPreview(BuildingData building)
    {
        if (buildingListPanel != null) buildingListPanel.SetActive(false);
        if (buildingPreviewPanel != null) buildingPreviewPanel.SetActive(true);

        // Update preview panel
        if (previewImage != null && building.WatercolorSprite != null)
        {
            previewImage.sprite = building.WatercolorSprite;
        }

        if (buildingNameText != null)
        {
            buildingNameText.text = building.BuildingName;
            FontManager.ApplyHeadingStyle(buildingNameText, GameFonts.Sizes.HeadingMedium);
        }

        if (descriptionText != null)
        {
            descriptionText.text = building.Description;
            FontManager.ApplyBodyStyle(descriptionText);
        }

        if (costText != null)
        {
            costText.text = building.GetCostString();

            // Color based on affordability
            costText.color = building.CanAfford() ? GameColors.SageGreen : GameColors.ErrorRed;
        }

        if (historicalFactText != null)
        {
            historicalFactText.text = building.HistoricalFact;
            FontManager.ApplyAnnotationStyle(historicalFactText);
        }

        // Enable/disable confirm button based on affordability
        if (confirmButton != null)
        {
            confirmButton.interactable = building.CanAfford();
        }
    }

    private void ConfirmBuilding()
    {
        if (selectedBuilding == null || currentPlot == null)
        {
            Debug.LogWarning("[BuildingSelectionMenu] No building or plot selected");
            return;
        }

        if (!selectedBuilding.CanAfford())
        {
            Debug.LogWarning("[BuildingSelectionMenu] Cannot afford building");
            return;
        }

        Debug.Log($"[BuildingSelectionMenu] Confirming build: {selectedBuilding.BuildingName}");

        // Deduct resources
        ResourceManager.Instance?.TrySpendResources(
            selectedBuilding.GoldCost,
            selectedBuilding.StoneCost,
            selectedBuilding.WoodCost
        );

        // Close menu
        Close();

        // Start the challenge
        ChallengeManager.Instance?.StartChallenge(currentPlot, selectedBuilding);
    }

    public void Cancel()
    {
        Close();
        GameManager.Instance?.SetState(GameManager.GameState.Playing);
    }

    public void Close()
    {
        currentPlot = null;
        selectedBuilding = null;
        gameObject.SetActive(false);
    }

    /// <summary>
    /// Go back to era selection
    /// </summary>
    public void BackToEraSelection()
    {
        selectedBuilding = null;
        ShowEraSelection();
    }

    /// <summary>
    /// Go back to building list
    /// </summary>
    public void BackToBuildingList()
    {
        selectedBuilding = null;
        ShowBuildingList(selectedEra);
    }
}

using UnityEngine;
using System.Collections.Generic;

/// <summary>
/// Manages the Florence city - building plots, construction, and city state
/// </summary>
public class CityManager : MonoBehaviour
{
    public static CityManager Instance { get; private set; }

    [Header("Building Plots")]
    [SerializeField] private List<BuildingPlot> buildingPlots = new List<BuildingPlot>();
    [SerializeField] private int totalPlots = 6;

    [Header("City Stats")]
    [SerializeField] private int buildingsConstructed = 0;
    [SerializeField] private int romanBuildings = 0;
    [SerializeField] private int renaissanceBuildings = 0;

    public int BuildingsConstructed => buildingsConstructed;
    public int RomanBuildings => romanBuildings;
    public int RenaissanceBuildings => renaissanceBuildings;
    public int TotalPlots => totalPlots;
    public int RemainingPlots => totalPlots - buildingsConstructed;

    public event System.Action<BuildingPlot> OnBuildingConstructed;
    public event System.Action OnAllBuildingsComplete;

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
        // Find all building plots in scene if not assigned
        if (buildingPlots.Count == 0)
        {
            buildingPlots.AddRange(FindObjectsOfType<BuildingPlot>());
        }

        totalPlots = buildingPlots.Count;
        Debug.Log($"[CityManager] Found {totalPlots} building plots");
    }

    public void RegisterPlot(BuildingPlot plot)
    {
        if (!buildingPlots.Contains(plot))
        {
            buildingPlots.Add(plot);
            totalPlots = buildingPlots.Count;
        }
    }

    public void OnBuildingPlaced(BuildingPlot plot, BuildingData building)
    {
        buildingsConstructed++;

        if (building.Era == BuildingEra.AncientRome)
        {
            romanBuildings++;
        }
        else if (building.Era == BuildingEra.Renaissance)
        {
            renaissanceBuildings++;
        }

        Debug.Log($"[CityManager] Building constructed: {building.BuildingName} ({buildingsConstructed}/{totalPlots})");

        OnBuildingConstructed?.Invoke(plot);

        // Check if all plots are filled
        if (buildingsConstructed >= totalPlots)
        {
            OnCityComplete();
        }
    }

    private void OnCityComplete()
    {
        Debug.Log("[CityManager] All buildings constructed! City is complete!");
        OnAllBuildingsComplete?.Invoke();
    }

    public BuildingPlot GetPlotByIndex(int index)
    {
        if (index >= 0 && index < buildingPlots.Count)
        {
            return buildingPlots[index];
        }
        return null;
    }

    public List<BuildingPlot> GetEmptyPlots()
    {
        return buildingPlots.FindAll(p => !p.HasBuilding);
    }

    public List<BuildingPlot> GetOccupiedPlots()
    {
        return buildingPlots.FindAll(p => p.HasBuilding);
    }
}

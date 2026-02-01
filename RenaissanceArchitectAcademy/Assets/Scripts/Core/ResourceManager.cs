using UnityEngine;
using System;

/// <summary>
/// Manages player resources: Gold, Stone, Wood
/// Starting resources: Gold 1000, Stone 50, Wood 50
/// </summary>
public class ResourceManager : MonoBehaviour
{
    public static ResourceManager Instance { get; private set; }

    [Header("Starting Resources")]
    [SerializeField] private int startingGold = 1000;
    [SerializeField] private int startingStone = 50;
    [SerializeField] private int startingWood = 50;

    [Header("Current Resources")]
    [SerializeField] private int gold;
    [SerializeField] private int stone;
    [SerializeField] private int wood;

    // Public accessors
    public int Gold => gold;
    public int Stone => stone;
    public int Wood => wood;

    // Events for UI updates
    public event Action<int> OnGoldChanged;
    public event Action<int> OnStoneChanged;
    public event Action<int> OnWoodChanged;
    public event Action OnResourcesChanged;

    private void Awake()
    {
        if (Instance == null)
        {
            Instance = this;
            DontDestroyOnLoad(gameObject);
            ResetResources();
        }
        else
        {
            Destroy(gameObject);
        }
    }

    public void ResetResources()
    {
        gold = startingGold;
        stone = startingStone;
        wood = startingWood;

        NotifyAllChanges();
        Debug.Log($"[ResourceManager] Resources reset - Gold: {gold}, Stone: {stone}, Wood: {wood}");
    }

    public bool CanAfford(int goldCost, int stoneCost, int woodCost)
    {
        return gold >= goldCost && stone >= stoneCost && wood >= woodCost;
    }

    public bool TrySpendResources(int goldCost, int stoneCost, int woodCost)
    {
        if (!CanAfford(goldCost, stoneCost, woodCost))
        {
            Debug.LogWarning($"[ResourceManager] Cannot afford: Gold {goldCost}, Stone {stoneCost}, Wood {woodCost}");
            return false;
        }

        gold -= goldCost;
        stone -= stoneCost;
        wood -= woodCost;

        NotifyAllChanges();
        Debug.Log($"[ResourceManager] Spent - Gold: {goldCost}, Stone: {stoneCost}, Wood: {woodCost}");
        return true;
    }

    public void AddGold(int amount)
    {
        gold += amount;
        OnGoldChanged?.Invoke(gold);
        OnResourcesChanged?.Invoke();
    }

    public void AddStone(int amount)
    {
        stone += amount;
        OnStoneChanged?.Invoke(stone);
        OnResourcesChanged?.Invoke();
    }

    public void AddWood(int amount)
    {
        wood += amount;
        OnWoodChanged?.Invoke(wood);
        OnResourcesChanged?.Invoke();
    }

    private void NotifyAllChanges()
    {
        OnGoldChanged?.Invoke(gold);
        OnStoneChanged?.Invoke(stone);
        OnWoodChanged?.Invoke(wood);
        OnResourcesChanged?.Invoke();
    }

    // For debugging/cheats
    public void AddAllResources(int goldAmount, int stoneAmount, int woodAmount)
    {
        gold += goldAmount;
        stone += stoneAmount;
        wood += woodAmount;
        NotifyAllChanges();
    }
}

using UnityEngine;
using UnityEngine.UI;
using System.Collections;
using System.Collections.Generic;

/// <summary>
/// Gamification & Rewards: The Seal of Approval
///
/// Badges are physical "stamps" of approval pressed onto notebook pages.
/// High scores look like masterworks with golden flourishes.
/// Low scores look like unfinished sketches with red corrective notes.
///
/// Seal Tiers:
/// - Bronze Seal: Basic completion (compass star)
/// - Silver Seal: Good performance (geometric star)
/// - Gold Seal: Excellent work (crown with laurels)
/// - Iridescent Seal: Mastery - perfect score (Eye of Providence)
/// </summary>
public class SealRewardSystem : MonoBehaviour
{
    public static SealRewardSystem Instance { get; private set; }

    [Header("Seal Sprites")]
    [SerializeField] private Sprite bronzeSealSprite;
    [SerializeField] private Sprite silverSealSprite;
    [SerializeField] private Sprite goldSealSprite;
    [SerializeField] private Sprite iridescentSealSprite;

    [Header("Seal Colors")]
    [SerializeField] private Color bronzeColor = new Color(0.80f, 0.50f, 0.20f);
    [SerializeField] private Color silverColor = new Color(0.75f, 0.75f, 0.80f);
    [SerializeField] private Color goldColor = new Color(0.85f, 0.65f, 0.13f);
    [SerializeField] private Color iridescentColor = new Color(0.85f, 0.85f, 1.0f);

    [Header("Animation Settings")]
    [SerializeField] private float stampDuration = 0.5f;
    [SerializeField] private float stampBounce = 1.3f;
    [SerializeField] private AnimationCurve stampCurve;

    [Header("Audio")]
    [SerializeField] private AudioClip stampSound;
    [SerializeField] private AudioClip masterworkSound;

    [Header("Effects")]
    [SerializeField] private GameObject goldenFlourishes;  // Particle effect for Gold+
    [SerializeField] private GameObject sparkleEffect;     // For Iridescent

    public enum SealTier
    {
        None,
        Bronze,
        Silver,
        Gold,
        Iridescent
    }

    // Track earned seals per building
    private Dictionary<string, SealTier> earnedSeals = new Dictionary<string, SealTier>();

    public event System.Action<SealTier, string> OnSealEarned;

    private void Awake()
    {
        if (Instance == null)
        {
            Instance = this;
            DontDestroyOnLoad(gameObject);
        }
        else
        {
            Destroy(gameObject);
        }
    }

    /// <summary>
    /// Calculate seal tier based on challenge performance
    /// </summary>
    public SealTier CalculateSealTier(int attempts, int hintsUsed, float timeSpent, float parTime)
    {
        // Perfect: 1 attempt, no hints, under par time
        if (attempts == 1 && hintsUsed == 0 && timeSpent <= parTime)
        {
            return SealTier.Iridescent;
        }

        // Gold: 1-2 attempts, max 1 hint
        if (attempts <= 2 && hintsUsed <= 1)
        {
            return SealTier.Gold;
        }

        // Silver: 3-4 attempts, max 2 hints
        if (attempts <= 4 && hintsUsed <= 2)
        {
            return SealTier.Silver;
        }

        // Bronze: Completed (any performance)
        return SealTier.Bronze;
    }

    /// <summary>
    /// Award a seal for completing a building challenge
    /// </summary>
    public void AwardSeal(string buildingId, SealTier tier, Image sealDisplay = null)
    {
        // Store the earned seal
        if (earnedSeals.ContainsKey(buildingId))
        {
            // Only upgrade, never downgrade
            if (tier > earnedSeals[buildingId])
            {
                earnedSeals[buildingId] = tier;
            }
        }
        else
        {
            earnedSeals[buildingId] = tier;
        }

        Debug.Log($"[SealRewardSystem] Awarded {tier} seal for {buildingId}");

        // Play stamp animation if display provided
        if (sealDisplay != null)
        {
            StartCoroutine(PlaySealStampAnimation(sealDisplay, tier));
        }

        OnSealEarned?.Invoke(tier, buildingId);
    }

    /// <summary>
    /// Get the sprite for a seal tier
    /// </summary>
    public Sprite GetSealSprite(SealTier tier)
    {
        return tier switch
        {
            SealTier.Bronze => bronzeSealSprite,
            SealTier.Silver => silverSealSprite,
            SealTier.Gold => goldSealSprite,
            SealTier.Iridescent => iridescentSealSprite,
            _ => null
        };
    }

    /// <summary>
    /// Get the color for a seal tier
    /// </summary>
    public Color GetSealColor(SealTier tier)
    {
        return tier switch
        {
            SealTier.Bronze => bronzeColor,
            SealTier.Silver => silverColor,
            SealTier.Gold => goldColor,
            SealTier.Iridescent => iridescentColor,
            _ => Color.white
        };
    }

    /// <summary>
    /// Get tier display name
    /// </summary>
    public string GetTierName(SealTier tier)
    {
        return tier switch
        {
            SealTier.Bronze => "Bronze Seal",
            SealTier.Silver => "Silver Seal",
            SealTier.Gold => "Gold Seal",
            SealTier.Iridescent => "Seal of Mastery",
            _ => "No Seal"
        };
    }

    /// <summary>
    /// Get tier description (for tooltips)
    /// </summary>
    public string GetTierDescription(SealTier tier)
    {
        return tier switch
        {
            SealTier.Bronze => "You've completed the challenge. Keep practicing!",
            SealTier.Silver => "Good work! You're getting the hang of this.",
            SealTier.Gold => "Excellent! A true Renaissance mind at work.",
            SealTier.Iridescent => "Perfect mastery! Leonardo himself would be proud.",
            _ => ""
        };
    }

    private IEnumerator PlaySealStampAnimation(Image sealImage, SealTier tier)
    {
        // Set the seal sprite
        sealImage.sprite = GetSealSprite(tier);
        sealImage.color = GetSealColor(tier);

        // Play sound
        AudioClip sound = (tier >= SealTier.Gold) ? masterworkSound : stampSound;
        if (sound != null)
        {
            AudioSource.PlayClipAtPoint(sound, Camera.main.transform.position);
        }

        // Start invisible and large (stamp coming down)
        RectTransform rect = sealImage.rectTransform;
        Vector3 originalScale = rect.localScale;
        rect.localScale = originalScale * 2f;
        sealImage.color = new Color(sealImage.color.r, sealImage.color.g, sealImage.color.b, 0f);

        float elapsed = 0f;

        // Stamp down animation
        while (elapsed < stampDuration)
        {
            elapsed += Time.deltaTime;
            float t = stampCurve != null ? stampCurve.Evaluate(elapsed / stampDuration) : elapsed / stampDuration;

            // Scale down with bounce
            float scaleT = Mathf.Lerp(2f, 1f, t);
            if (t > 0.8f)
            {
                // Bounce at the end
                float bounceT = (t - 0.8f) / 0.2f;
                scaleT = 1f + Mathf.Sin(bounceT * Mathf.PI) * (stampBounce - 1f) * 0.3f;
            }
            rect.localScale = originalScale * scaleT;

            // Fade in
            Color c = sealImage.color;
            c.a = Mathf.Min(1f, t * 2f);
            sealImage.color = c;

            yield return null;
        }

        // Final state
        rect.localScale = originalScale;
        sealImage.color = GetSealColor(tier);

        // Special effects for high tiers
        if (tier >= SealTier.Gold && goldenFlourishes != null)
        {
            Instantiate(goldenFlourishes, rect.position, Quaternion.identity, rect);
        }

        if (tier == SealTier.Iridescent && sparkleEffect != null)
        {
            Instantiate(sparkleEffect, rect.position, Quaternion.identity, rect);
            // Iridescent shimmer effect
            StartCoroutine(PlayIridescentShimmer(sealImage));
        }
    }

    private IEnumerator PlayIridescentShimmer(Image sealImage)
    {
        // Continuous subtle color shift for iridescent seal
        float hueShift = 0f;
        Color baseColor = iridescentColor;

        while (sealImage != null && sealImage.gameObject.activeInHierarchy)
        {
            hueShift += Time.deltaTime * 0.1f;
            if (hueShift > 1f) hueShift -= 1f;

            // Subtle rainbow shift
            Color.RGBToHSV(baseColor, out float h, out float s, out float v);
            h = (h + hueShift) % 1f;
            sealImage.color = Color.HSVToRGB(h, s * 0.3f, v);

            yield return null;
        }
    }

    /// <summary>
    /// Check if a seal has been earned for a building
    /// </summary>
    public bool HasEarnedSeal(string buildingId, out SealTier tier)
    {
        if (earnedSeals.TryGetValue(buildingId, out tier))
        {
            return tier != SealTier.None;
        }
        tier = SealTier.None;
        return false;
    }

    /// <summary>
    /// Get count of seals by tier
    /// </summary>
    public int GetSealCount(SealTier tier)
    {
        int count = 0;
        foreach (var kvp in earnedSeals)
        {
            if (kvp.Value == tier) count++;
        }
        return count;
    }

    /// <summary>
    /// Get total seals earned
    /// </summary>
    public int GetTotalSeals()
    {
        return earnedSeals.Count;
    }
}

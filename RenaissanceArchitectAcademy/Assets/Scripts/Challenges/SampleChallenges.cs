using UnityEngine;

/// <summary>
/// Sample challenge data for buildings
/// These can be used as templates or assigned directly
///
/// Challenge Types from Visual Style Guide:
/// - Physics: Load distribution, forces, structural stability
/// - Math: Golden ratio, proportions, measurements
/// - Chemistry: Pigments, mortar mixing, materials
/// - Optics: Light rays, window placement, shadows
/// - Geometry: Arches, angles, symmetry
/// </summary>
public static class SampleChallenges
{
    // ============ MATHEMATICS CHALLENGES ============

    public static ChallengeData GoldenRatioBasic => new ChallengeData
    {
        challengeTitle = "The Golden Ratio",
        challengeType = ChallengeType.Mathematics,
        problemStatement = "The Golden Ratio (φ) was used by Renaissance architects to create perfect proportions.\n\n" +
                          "If the width of a doorway is 1 meter, and we want the height to follow the golden ratio (φ ≈ 1.618),\n\n" +
                          "What should the height be?\n\n" +
                          "(Round to 2 decimal places)",
        correctAnswer = "1.62",
        tolerance = 0.02f,
        hint1 = "The golden ratio φ ≈ 1.618",
        hint2 = "Height = Width × φ",
        hint3 = "1 × 1.618 = ?",
        explanation = "The Golden Ratio (φ ≈ 1.618) creates naturally pleasing proportions. Renaissance architects like Brunelleschi used it extensively in their designs.",
        formula = "φ = (1 + √5) / 2 ≈ 1.618"
    };

    public static ChallengeData ProportionCalculation => new ChallengeData
    {
        challengeTitle = "Column Proportions",
        challengeType = ChallengeType.Mathematics,
        problemStatement = "A Doric column should have a height that is 6 times its base diameter.\n\n" +
                          "If the base diameter is 0.8 meters, what should the column height be?\n\n" +
                          "(Answer in meters)",
        correctAnswer = "4.8",
        tolerance = 0.1f,
        hint1 = "The proportion is 6:1 (height to diameter)",
        hint2 = "Height = Diameter × 6",
        hint3 = "0.8 × 6 = ?",
        explanation = "The ancient Greeks established strict proportional rules for columns. Doric columns are the most sturdy, with a 6:1 height-to-diameter ratio.",
        formula = "Height = Diameter × 6"
    };

    // ============ PHYSICS CHALLENGES ============

    public static ChallengeData LoadDistribution => new ChallengeData
    {
        challengeTitle = "Load Distribution",
        challengeType = ChallengeType.Physics,
        problemStatement = "A stone roof weighs 1200 kg and rests on 4 equal columns.\n\n" +
                          "How much weight does each column support?\n\n" +
                          "(Answer in kg)",
        correctAnswer = "300",
        tolerance = 1f,
        hint1 = "The load is distributed equally among all columns",
        hint2 = "Total weight ÷ Number of columns",
        hint3 = "1200 ÷ 4 = ?",
        explanation = "Even load distribution is critical in architecture. If columns aren't equally loaded, the building becomes unstable.",
        formula = "Load per column = Total weight / Number of columns"
    };

    public static ChallengeData ArchForces => new ChallengeData
    {
        challengeTitle = "The Roman Arch",
        challengeType = ChallengeType.Physics,
        problemStatement = "An arch transfers downward force into outward thrust.\n\n" +
                          "If a 500 kg keystone creates 250 kg of force on each side,\n" +
                          "and the arch angle is 45°, what is the horizontal thrust?\n\n" +
                          "Use: Horizontal = Vertical × tan(45°)\n" +
                          "(Note: tan(45°) = 1)",
        correctAnswer = "250",
        tolerance = 1f,
        hint1 = "tan(45°) = 1, so horizontal equals vertical",
        hint2 = "Horizontal thrust = 250 × 1",
        hint3 = "The answer is the same as the vertical force",
        explanation = "Roman arches revolutionized architecture. The keystone transfers vertical load into horizontal thrust, which is absorbed by buttresses.",
        formula = "Horizontal Thrust = Vertical Force × tan(angle)"
    };

    // ============ GEOMETRY CHALLENGES ============

    public static ChallengeData TrussAngle => new ChallengeData
    {
        challengeTitle = "Roof Truss Angles",
        challengeType = ChallengeType.Geometry,
        problemStatement = "A roof truss forms a triangle. The two base angles are both 45°.\n\n" +
                          "What is the angle at the peak of the roof?\n\n" +
                          "(Remember: angles in a triangle sum to 180°)",
        correctAnswer = "90",
        tolerance = 0f,
        hint1 = "All angles in a triangle sum to 180°",
        hint2 = "Peak angle = 180° - (base angle 1 + base angle 2)",
        hint3 = "180° - 45° - 45° = ?",
        explanation = "Renaissance architects understood that proper roof angles ensure rain runoff while maintaining structural integrity.",
        formula = "Sum of angles = 180°"
    };

    public static ChallengeData CircleGeometry => new ChallengeData
    {
        challengeTitle = "The Perfect Circle",
        challengeType = ChallengeType.Geometry,
        problemStatement = "A rose window has a diameter of 4 meters.\n\n" +
                          "What is its circumference?\n\n" +
                          "Use π = 3.14\n" +
                          "(Round to 2 decimal places)",
        correctAnswer = "12.56",
        tolerance = 0.02f,
        hint1 = "Circumference = π × diameter",
        hint2 = "C = 3.14 × 4",
        hint3 = "Multiply 3.14 by 4",
        explanation = "Rose windows were engineering marvels. Understanding circular geometry was essential for creating their intricate patterns.",
        formula = "Circumference = π × d"
    };

    // ============ CHEMISTRY CHALLENGES ============

    public static ChallengeData MortarMixing => new ChallengeData
    {
        challengeTitle = "Roman Mortar",
        challengeType = ChallengeType.Chemistry,
        problemStatement = "Roman concrete used a 3:1 ratio of volcanic ash to lime.\n\n" +
                          "If you have 12 buckets of volcanic ash,\n" +
                          "how many buckets of lime do you need?",
        correctAnswer = "4",
        tolerance = 0f,
        hint1 = "The ratio is 3:1 (ash to lime)",
        hint2 = "Lime = Ash ÷ 3",
        hint3 = "12 ÷ 3 = ?",
        explanation = "Roman concrete was so strong that structures like the Pantheon still stand today. The volcanic ash (pozzolana) created a chemical reaction with seawater.",
        formula = "Ash : Lime = 3 : 1"
    };

    // ============ OPTICS CHALLENGES ============

    public static ChallengeData LightAngle => new ChallengeData
    {
        challengeTitle = "Window Light",
        challengeType = ChallengeType.Optics,
        problemStatement = "For optimal reading light, sunlight should enter at 30° above horizontal.\n\n" +
                          "If your window is 2 meters above the floor,\n" +
                          "how far from the window will the light reach on the floor?\n\n" +
                          "Use: tan(30°) ≈ 0.58\n" +
                          "(Round to 1 decimal place)",
        correctAnswer = "3.4",
        tolerance = 0.2f,
        hint1 = "tan(angle) = opposite / adjacent",
        hint2 = "tan(30°) = height / distance, so distance = height / tan(30°)",
        hint3 = "2 ÷ 0.58 ≈ ?",
        explanation = "Renaissance architects carefully planned window placement. Libraries often had south-facing windows angled for optimal reading light.",
        formula = "Distance = Height / tan(angle)"
    };

    // ============ HELPER METHODS ============

    /// <summary>
    /// Get a random challenge for a specific type
    /// </summary>
    public static ChallengeData GetRandomChallenge(ChallengeType type)
    {
        switch (type)
        {
            case ChallengeType.Mathematics:
                return Random.value > 0.5f ? GoldenRatioBasic : ProportionCalculation;
            case ChallengeType.Physics:
                return Random.value > 0.5f ? LoadDistribution : ArchForces;
            case ChallengeType.Geometry:
                return Random.value > 0.5f ? TrussAngle : CircleGeometry;
            case ChallengeType.Chemistry:
                return MortarMixing;
            case ChallengeType.Optics:
                return LightAngle;
            default:
                return GoldenRatioBasic;
        }
    }

    /// <summary>
    /// Get all challenges as an array (useful for testing)
    /// </summary>
    public static ChallengeData[] GetAllChallenges()
    {
        return new ChallengeData[]
        {
            GoldenRatioBasic,
            ProportionCalculation,
            LoadDistribution,
            ArchForces,
            TrussAngle,
            CircleGeometry,
            MortarMixing,
            LightAngle
        };
    }
}

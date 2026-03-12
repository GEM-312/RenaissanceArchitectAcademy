import Foundation

// MARK: - Wolfram Geometry Query

/// Pre-defined geometry queries for each building's math concepts.
/// Wolfram computes exact values; our SwiftUI renders the visuals.
struct WolframGeometryQuery {
    let label: String              // "Dome Volume"
    let wolframInput: String       // "volume of hemisphere radius 21.65 meters"
    let extractPod: String         // "Result" — which pod to pull from
    let unit: String               // "m³"
    let fallbackValue: String      // "42,508 m³" — shown if offline
}

/// Structured result from a geometry computation
struct WolframGeometryResult: Identifiable {
    let id = UUID()
    let label: String
    let value: String
    let unit: String
    let isFromWolfram: Bool        // true = live API, false = fallback
}

/// A complete geometry context for a building — queries + results + interactive parameters
struct BuildingGeometry {
    let buildingName: String
    let title: String              // "The Perfect Sphere"
    let description: String        // Short educational text
    let queries: [WolframGeometryQuery]
    let interactiveParameter: InteractiveParam?

    /// A parameter the player can adjust with a slider
    struct InteractiveParam {
        let label: String          // "Dome Diameter"
        let unit: String           // "meters"
        let defaultValue: Double   // 43.3
        let range: ClosedRange<Double>  // 20...80
        let step: Double           // 0.5
        /// Template: replace {value} with slider value, {radius} with value/2
        let queryTemplate: String  // "volume of hemisphere radius {radius} meters"
        let resultLabel: String    // "Volume"
        let resultUnit: String     // "m³"
    }
}

// MARK: - Wolfram Geometry Helper

/// Fetches geometry computations from Wolfram Alpha and caches results.
/// Falls back to pre-computed values when offline.
actor WolframGeometryHelper {

    private let wolfram = WolframService()
    private var cache: [String: String] = [:]

    /// Compute all geometry values for a building
    func computeAll(for geometry: BuildingGeometry) async -> [WolframGeometryResult] {
        var results: [WolframGeometryResult] = []

        for query in geometry.queries {
            let value = await compute(query: query)
            results.append(value)
        }

        return results
    }

    /// Compute a single query — tries Wolfram, falls back to cached/default
    func compute(query: WolframGeometryQuery) async -> WolframGeometryResult {
        let cacheKey = query.wolframInput.lowercased()

        // Check cache first
        if let cached = cache[cacheKey] {
            return WolframGeometryResult(
                label: query.label, value: cached, unit: query.unit, isFromWolfram: true
            )
        }

        // Try Wolfram
        do {
            let result = try await wolfram.query(query.wolframInput)
            if let text = result.text(for: query.extractPod)
                ?? result.text(for: "Result")
                ?? result.text(for: "Exact result") {
                let cleaned = cleanWolframValue(text)
                cache[cacheKey] = cleaned
                return WolframGeometryResult(
                    label: query.label, value: cleaned, unit: query.unit, isFromWolfram: true
                )
            }
        } catch {
            print("Wolfram geometry query failed: \(error.localizedDescription)")
        }

        // Fallback
        return WolframGeometryResult(
            label: query.label, value: query.fallbackValue, unit: query.unit, isFromWolfram: false
        )
    }

    /// Compute an interactive query with a custom parameter value
    func computeInteractive(param: BuildingGeometry.InteractiveParam, value: Double) async -> WolframGeometryResult {
        let radius = value / 2.0
        let queryStr = param.queryTemplate
            .replacingOccurrences(of: "{value}", with: String(format: "%.1f", value))
            .replacingOccurrences(of: "{radius}", with: String(format: "%.2f", radius))

        let cacheKey = queryStr.lowercased()
        if let cached = cache[cacheKey] {
            return WolframGeometryResult(
                label: param.resultLabel, value: cached, unit: param.resultUnit, isFromWolfram: true
            )
        }

        do {
            let result = try await wolfram.query(queryStr)
            if let text = result.text(for: "Result")
                ?? result.text(for: "Exact result")
                ?? result.allText.components(separatedBy: "\n").first {
                let cleaned = cleanWolframValue(text)
                cache[cacheKey] = cleaned
                return WolframGeometryResult(
                    label: param.resultLabel, value: cleaned, unit: param.resultUnit, isFromWolfram: true
                )
            }
        } catch {
            print("Wolfram interactive query failed: \(error.localizedDescription)")
        }

        // Fallback: compute locally for common formulas
        let localResult = localCompute(param: param, value: value)
        return WolframGeometryResult(
            label: param.resultLabel, value: localResult, unit: param.resultUnit, isFromWolfram: false
        )
    }

    /// Local fallback for basic formulas
    private func localCompute(param: BuildingGeometry.InteractiveParam, value: Double) -> String {
        let r = value / 2.0
        if param.queryTemplate.contains("hemisphere") {
            let volume = (2.0 / 3.0) * .pi * pow(r, 3)
            return formatNumber(volume)
        } else if param.queryTemplate.contains("circle") {
            let area = .pi * pow(r, 2)
            return formatNumber(area)
        } else if param.queryTemplate.contains("sphere") {
            let volume = (4.0 / 3.0) * .pi * pow(r, 3)
            return formatNumber(volume)
        }
        return "—"
    }

    private func formatNumber(_ n: Double) -> String {
        if n >= 1000 {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.maximumFractionDigits = 0
            return formatter.string(from: NSNumber(value: n)) ?? "\(Int(n))"
        }
        return String(format: "%.1f", n)
    }

    private func cleanWolframValue(_ raw: String) -> String {
        var s = raw
        // Remove "≈" prefix
        s = s.replacingOccurrences(of: "≈ ", with: "")
        s = s.replacingOccurrences(of: "≈", with: "")
        // Remove parenthetical unit descriptions like "(CUBIC METERS)"
        if let parenStart = s.range(of: "(") {
            s = String(s[s.startIndex..<parenStart.lowerBound])
        }
        // Replace Wolfram power notation "M~3" → "" (we add our own units)
        s = s.replacingOccurrences(of: "~", with: "")
        // Remove trailing unit strings
        for suffix in [" m3", " m^3", " m³", " m2", " m^2", " m²", " m", " meters",
                       " kg", " tons", " degrees", " liters", " L", " gallons"] {
            if s.lowercased().hasSuffix(suffix.lowercased()) {
                s = String(s.dropLast(suffix.count))
            }
        }
        // Remove trailing periods ("42508." → "42508")
        if s.hasSuffix(".") { s = String(s.dropLast()) }
        s = s.trimmingCharacters(in: .whitespaces)
        // Format as number with commas if it's a plain number
        if let number = Double(s.replacingOccurrences(of: ",", with: "")) {
            return formatNumber(number)
        }
        return s
    }
}

// MARK: - Building Geometry Content

/// Pre-defined geometry data for each building
enum BuildingGeometryContent {

    static func geometry(for buildingName: String) -> BuildingGeometry? {
        switch buildingName {

        // ── Pantheon ──
        case "Pantheon":
            return BuildingGeometry(
                buildingName: "Pantheon",
                title: "The Perfect Sphere",
                description: "The Pantheon's dome is a perfect hemisphere. Height equals diameter: 43.3 meters. A sphere fits inside perfectly — touching the floor and the top of the dome.",
                queries: [
                    WolframGeometryQuery(
                        label: "Dome Volume",
                        wolframInput: "volume of hemisphere radius 21.65 meters",
                        extractPod: "Result",
                        unit: "m³",
                        fallbackValue: "21,254"
                    ),
                    WolframGeometryQuery(
                        label: "Inner Surface Area",
                        wolframInput: "surface area of hemisphere radius 21.65 meters",
                        extractPod: "Result",
                        unit: "m²",
                        fallbackValue: "2,952"
                    ),
                    WolframGeometryQuery(
                        label: "Oculus Area",
                        wolframInput: "area of circle diameter 8.7 meters",
                        extractPod: "Result",
                        unit: "m²",
                        fallbackValue: "59.4"
                    ),
                    WolframGeometryQuery(
                        label: "Circumference",
                        wolframInput: "circumference of circle diameter 43.3 meters",
                        extractPod: "Result",
                        unit: "m",
                        fallbackValue: "136.0"
                    )
                ],
                interactiveParameter: BuildingGeometry.InteractiveParam(
                    label: "Dome Diameter",
                    unit: "meters",
                    defaultValue: 43.3,
                    range: 10...80,
                    step: 0.5,
                    queryTemplate: "volume of hemisphere radius {radius} meters",
                    resultLabel: "Volume",
                    resultUnit: "m³"
                )
            )

        // ── Colosseum ──
        case "Colosseum":
            return BuildingGeometry(
                buildingName: "Colosseum",
                title: "The Elliptical Arena",
                description: "The Colosseum is an ellipse, not a circle. Major axis: 188 m, minor axis: 156 m. The shape maximized seating while keeping every spectator close to the action.",
                queries: [
                    WolframGeometryQuery(
                        label: "Arena Perimeter",
                        wolframInput: "perimeter of ellipse semi-major axis 94 meters semi-minor axis 78 meters",
                        extractPod: "Result",
                        unit: "m",
                        fallbackValue: "545"
                    ),
                    WolframGeometryQuery(
                        label: "Arena Area",
                        wolframInput: "area of ellipse semi-major axis 94 meters semi-minor axis 78 meters",
                        extractPod: "Result",
                        unit: "m²",
                        fallbackValue: "23,036"
                    ),
                    WolframGeometryQuery(
                        label: "Height",
                        wolframInput: "48 meters in stories assuming 3.6 meters per story",
                        extractPod: "Result",
                        unit: "stories",
                        fallbackValue: "4 stories (48 m)"
                    )
                ],
                interactiveParameter: BuildingGeometry.InteractiveParam(
                    label: "Major Axis",
                    unit: "meters",
                    defaultValue: 188,
                    range: 50...300,
                    step: 1,
                    queryTemplate: "area of ellipse semi-major axis {radius} meters semi-minor axis 78 meters",
                    resultLabel: "Arena Area",
                    resultUnit: "m²"
                )
            )

        // ── Duomo ──
        case "Duomo":
            return BuildingGeometry(
                buildingName: "Duomo",
                title: "Brunelleschi's Double Shell",
                description: "The Florence Cathedral dome spans 44 meters — the largest masonry dome ever built. Brunelleschi's secret: two shells with herringbone bricks, creating strength without scaffolding.",
                queries: [
                    WolframGeometryQuery(
                        label: "Dome Span",
                        wolframInput: "area of circle diameter 44 meters",
                        extractPod: "Result",
                        unit: "m²",
                        fallbackValue: "1,521"
                    ),
                    WolframGeometryQuery(
                        label: "Dome Weight",
                        wolframInput: "37000 tons in kilograms",
                        extractPod: "Result",
                        unit: "kg",
                        fallbackValue: "37,000,000"
                    ),
                    WolframGeometryQuery(
                        label: "Dome Height",
                        wolframInput: "114.5 meters minus 55 meters",
                        extractPod: "Result",
                        unit: "m",
                        fallbackValue: "59.5"
                    )
                ],
                interactiveParameter: BuildingGeometry.InteractiveParam(
                    label: "Dome Diameter",
                    unit: "meters",
                    defaultValue: 44,
                    range: 10...80,
                    step: 0.5,
                    queryTemplate: "volume of hemisphere radius {radius} meters",
                    resultLabel: "Interior Volume",
                    resultUnit: "m³"
                )
            )

        // ── Aqueduct ──
        case "Aqueduct":
            return BuildingGeometry(
                buildingName: "Aqueduct",
                title: "Gravity's Highway",
                description: "Roman aqueducts dropped just 1 meter for every 200 meters of length. That tiny gradient — 0.5% — was enough. Gravity did all the work. No pumps. No engines.",
                queries: [
                    WolframGeometryQuery(
                        label: "Gradient",
                        wolframInput: "1/200 as a percentage",
                        extractPod: "Result",
                        unit: "%",
                        fallbackValue: "0.5"
                    ),
                    WolframGeometryQuery(
                        label: "Daily Flow",
                        wolframInput: "300 million gallons in liters",
                        extractPod: "Result",
                        unit: "liters",
                        fallbackValue: "1,135,624,000"
                    ),
                    WolframGeometryQuery(
                        label: "Channel Cross-Section",
                        wolframInput: "area of rectangle 1.2 meters by 0.9 meters",
                        extractPod: "Result",
                        unit: "m²",
                        fallbackValue: "1.08"
                    )
                ],
                interactiveParameter: BuildingGeometry.InteractiveParam(
                    label: "Aqueduct Length",
                    unit: "meters",
                    defaultValue: 200,
                    range: 50...1000,
                    step: 10,
                    queryTemplate: "{value} * 0.005",
                    resultLabel: "Total Drop",
                    resultUnit: "m"
                )
            )

        // ── Roman Baths ──
        case "Roman Baths":
            return BuildingGeometry(
                buildingName: "Roman Baths",
                title: "Engineering Warmth",
                description: "The Baths of Caracalla held 1,600 bathers. The frigidarium pool alone held 2,500 cubic meters of water — heated from below by the hypocaust system.",
                queries: [
                    WolframGeometryQuery(
                        label: "Pool Volume",
                        wolframInput: "volume of rectangular prism 35 meters by 22 meters by 1.5 meters",
                        extractPod: "Result",
                        unit: "m³",
                        fallbackValue: "1,155"
                    ),
                    WolframGeometryQuery(
                        label: "Floor Area",
                        wolframInput: "area of rectangle 35 meters by 22 meters",
                        extractPod: "Result",
                        unit: "m²",
                        fallbackValue: "770"
                    )
                ],
                interactiveParameter: nil
            )

        default:
            return nil
        }
    }
}

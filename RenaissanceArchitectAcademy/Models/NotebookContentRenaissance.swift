import Foundation

// MARK: - Renaissance Italy Vocabulary (Buildings 9-17)

extension NotebookContent {

    // MARK: - Il Duomo (#9)
    static var duomoVocabulary: [NotebookEntry] {
        let bid = 9
        return [
            NotebookEntry(
                buildingId: bid,
                entryType: .vocabulary,
                science: .geometry,
                title: "Herringbone",
                body: "**Herringbone** — a brick-laying pattern where bricks are set at alternating angles, forming a zigzag. Brunelleschi used this pattern to make each ring of bricks self-supporting during construction."
            ),
            NotebookEntry(
                buildingId: bid,
                entryType: .vocabulary,
                science: .architecture,
                title: "Lantern",
                body: "**Lantern** — the decorative tower crowning the dome, weighing 725 tonnes. Its weight actually helps stabilize the dome by pressing the bricks together at the top."
            ),
            NotebookEntry(
                buildingId: bid,
                entryType: .vocabulary,
                science: .architecture,
                title: "Drum",
                body: "**Drum** — the octagonal base (tambour) on which the dome sits, 13 meters tall. The drum raised the dome high above the cathedral's roof line."
            ),
            NotebookEntry(
                buildingId: bid,
                entryType: .vocabulary,
                science: .physics,
                title: "Double Shell",
                body: "**Double Shell** — Brunelleschi's innovation of building two concentric domes with a gap between them, connected by ribs. This made the dome lighter while remaining strong."
            ),
            NotebookEntry(
                buildingId: bid,
                entryType: .vocabulary,
                science: .architecture,
                title: "Centering",
                body: "**Centering** — temporary wooden scaffolding traditionally used to support an arch or dome during construction. Brunelleschi's genius was building without it — the span was too wide."
            ),
            NotebookEntry(
                buildingId: bid,
                entryType: .vocabulary,
                science: .geometry,
                title: "Cupola",
                body: "**Cupola** — Italian word for dome. Brunelleschi's cupola spans 42 meters — only slightly less than the Pantheon's 43.3 meters, but without the Pantheon's concrete advantage."
            ),
        ]
    }

    // MARK: - Botanical Garden (#10)
    static var botanicalGardenVocabulary: [NotebookEntry] {
        let bid = 10
        return [
            NotebookEntry(
                buildingId: bid,
                entryType: .vocabulary,
                science: .biology,
                title: "Taxonomy",
                body: "**Taxonomy** — the science of classifying living things into groups. Renaissance botanists began organizing plants by shared features, paving the way for Linnaeus's system 200 years later."
            ),
            NotebookEntry(
                buildingId: bid,
                entryType: .vocabulary,
                science: .biology,
                title: "Herbarium",
                body: "**Herbarium** — a collection of dried, pressed plant specimens mounted on sheets and labeled. Luca Ghini created the first known herbarium in the 1530s at Pisa."
            ),
            NotebookEntry(
                buildingId: bid,
                entryType: .vocabulary,
                science: .chemistry,
                title: "Distillation",
                body: "**Distillation** — the process of heating a liquid to vapor and condensing it back to liquid, used to extract essential oils and medicines from plants."
            ),
            NotebookEntry(
                buildingId: bid,
                entryType: .vocabulary,
                science: .chemistry,
                title: "Medicinal",
                body: "**Medicinal** — relating to healing or medicine. Renaissance gardens were living pharmacies — digitalis (foxglove) for the heart, quinine (cinchona bark) for malaria."
            ),
            NotebookEntry(
                buildingId: bid,
                entryType: .vocabulary,
                science: .biology,
                title: "Genus",
                body: "**Genus** — a group of closely related species. The Renaissance practice of grouping plants by physical similarity evolved into the modern genus-species naming system."
            ),
            NotebookEntry(
                buildingId: bid,
                entryType: .vocabulary,
                science: .geology,
                title: "Terroir",
                body: "**Terroir** — the complete natural environment (soil, climate, terrain) affecting plant growth. Renaissance gardeners understood that different soils produced different medicinal potencies."
            ),
        ]
    }

    // MARK: - Glassworks (#11)
    static var glassworksVocabulary: [NotebookEntry] {
        let bid = 11
        return [
            NotebookEntry(
                buildingId: bid,
                entryType: .vocabulary,
                science: .chemistry,
                title: "Cristallo",
                body: "**Cristallo** — ultra-clear glass invented by Angelo Barovier around 1450. Made by purifying soda ash with manganese dioxide, it was the clearest glass ever produced."
            ),
            NotebookEntry(
                buildingId: bid,
                entryType: .vocabulary,
                science: .chemistry,
                title: "Silica",
                body: "**Silica** — silicon dioxide (SiO₂), the main ingredient in glass, obtained from sand. It melts at 1,700°C, but adding soda ash lowers this to about 1,400°C."
            ),
            NotebookEntry(
                buildingId: bid,
                entryType: .vocabulary,
                science: .chemistry,
                title: "Flux",
                body: "**Flux** — a substance (like soda ash) added to lower the melting point of silica. Without flux, the furnace temperatures needed would be impossibly high for Renaissance technology."
            ),
            NotebookEntry(
                buildingId: bid,
                entryType: .vocabulary,
                science: .materials,
                title: "Annealing",
                body: "**Annealing** — slowly cooling glass in a special oven (lehr) to relieve internal stresses. Without annealing, glass cracks or shatters from uneven cooling."
            ),
            NotebookEntry(
                buildingId: bid,
                entryType: .vocabulary,
                science: .optics,
                title: "Refraction",
                body: "**Refraction** — the bending of light as it passes through glass or other transparent materials. Venetian glassmakers discovered this property led to lenses and spectacles."
            ),
            NotebookEntry(
                buildingId: bid,
                entryType: .vocabulary,
                science: .materials,
                title: "Murano",
                body: "**Murano** — the island near Venice where glassmakers were forced to relocate in 1291. Officially for fire safety, but also to guard trade secrets under penalty of death."
            ),
        ]
    }

    // MARK: - Arsenal (#12)
    static var arsenalVocabulary: [NotebookEntry] {
        let bid = 12
        return [
            NotebookEntry(
                buildingId: bid,
                entryType: .vocabulary,
                science: .engineering,
                title: "Galley",
                body: "**Galley** — a warship powered by oars and sails. The Arsenal could produce one fully equipped galley per day during wartime — an astonishing feat of organization."
            ),
            NotebookEntry(
                buildingId: bid,
                entryType: .vocabulary,
                science: .engineering,
                title: "Standardization",
                body: "**Standardization** — making parts to identical specifications so they're interchangeable. The Arsenal pioneered this concept centuries before the Industrial Revolution."
            ),
            NotebookEntry(
                buildingId: bid,
                entryType: .vocabulary,
                science: .engineering,
                title: "Assembly Line",
                body: "**Assembly Line** — a production system where the product moves past fixed workstations. At the Arsenal, ship hulls were towed along a canal past specialized workshops."
            ),
            NotebookEntry(
                buildingId: bid,
                entryType: .vocabulary,
                science: .materials,
                title: "Keel",
                body: "**Keel** — the central structural beam running along the bottom of a ship. Oak was preferred for keels because it resisted rot and provided immense strength."
            ),
            NotebookEntry(
                buildingId: bid,
                entryType: .vocabulary,
                science: .materials,
                title: "Caulking",
                body: "**Caulking** — sealing the gaps between hull planks with oakum (tarred rope fibers) and pitch to make the ship watertight."
            ),
            NotebookEntry(
                buildingId: bid,
                entryType: .vocabulary,
                science: .physics,
                title: "Tana",
                body: "**Tana** — the Arsenal's rope-making building, 316 meters long — one of the longest buildings in Europe. Hemp fibers were twisted into rope strong enough to anchor warships."
            ),
        ]
    }

    // MARK: - Anatomy Theater (#13)
    static var anatomyTheaterVocabulary: [NotebookEntry] {
        let bid = 13
        return [
            NotebookEntry(
                buildingId: bid,
                entryType: .vocabulary,
                science: .biology,
                title: "Dissection",
                body: "**Dissection** — the systematic cutting open and examination of a body to study its internal structure. Public dissections in Padua drew crowds of 500 or more."
            ),
            NotebookEntry(
                buildingId: bid,
                entryType: .vocabulary,
                science: .biology,
                title: "Vesalius",
                body: "**Vesalius** — Andreas Vesalius (1514-1564), who revolutionized anatomy by performing his own dissections rather than relying on ancient texts. His book corrected over 200 of Galen's errors."
            ),
            NotebookEntry(
                buildingId: bid,
                entryType: .vocabulary,
                science: .biology,
                title: "Anatomy",
                body: "**Anatomy** — from Greek \"anatomē\" (cutting up). The scientific study of body structure. Renaissance anatomists transformed medicine from book-learning to direct observation."
            ),
            NotebookEntry(
                buildingId: bid,
                entryType: .vocabulary,
                science: .chemistry,
                title: "Embalming",
                body: "**Embalming** — preserving a body using chemicals to slow decay. Renaissance methods used vinegar, herbs, and turpentine — dissections were limited to winter months."
            ),
            NotebookEntry(
                buildingId: bid,
                entryType: .vocabulary,
                science: .biology,
                title: "Cadaver",
                body: "**Cadaver** — a dead human body used for anatomical study. Bodies were typically those of executed criminals, and a single cadaver had to last an entire lecture series."
            ),
            NotebookEntry(
                buildingId: bid,
                entryType: .vocabulary,
                science: .optics,
                title: "Optic Nerve",
                body: "**Optic Nerve** — the nerve connecting the eye to the brain. Vesalius's precise drawings of this nerve corrected centuries of incorrect descriptions from Galen."
            ),
        ]
    }

    // MARK: - Leonardo's Workshop (#14)
    static var leonardoWorkshopVocabulary: [NotebookEntry] {
        let bid = 14
        return [
            NotebookEntry(
                buildingId: bid,
                entryType: .vocabulary,
                science: .materials,
                title: "Sfumato",
                body: "**Sfumato** — Leonardo's signature painting technique meaning \"smoky.\" Colors blend without visible brushstrokes, creating soft, lifelike transitions — seen perfectly in the Mona Lisa's smile."
            ),
            NotebookEntry(
                buildingId: bid,
                entryType: .vocabulary,
                science: .engineering,
                title: "Codex",
                body: "**Codex** — (plural: codices) a bound manuscript. Leonardo filled over 7,000 pages with notes and drawings. The Codex Atlanticus alone contains 1,119 pages of inventions."
            ),
            NotebookEntry(
                buildingId: bid,
                entryType: .vocabulary,
                science: .physics,
                title: "Vitruvian Man",
                body: "**Vitruvian Man** — Leonardo's famous drawing of a man in a circle and square, illustrating the ideal human proportions described by the Roman architect Vitruvius."
            ),
            NotebookEntry(
                buildingId: bid,
                entryType: .vocabulary,
                science: .physics,
                title: "Chiaroscuro",
                body: "**Chiaroscuro** — the dramatic use of light and shadow in art. Leonardo studied how light falls on curved surfaces to make his paintings appear three-dimensional."
            ),
            NotebookEntry(
                buildingId: bid,
                entryType: .vocabulary,
                science: .engineering,
                title: "Prototype",
                body: "**Prototype** — an early model built to test a design. Leonardo built scale models of his inventions from wood, leather, and metal before proposing full-size versions."
            ),
            NotebookEntry(
                buildingId: bid,
                entryType: .vocabulary,
                science: .engineering,
                title: "Polymath",
                body: "**Polymath** — a person with deep knowledge in many subjects. Leonardo excelled in painting, sculpture, anatomy, engineering, botany, geology, and mathematics."
            ),
        ]
    }

    // MARK: - Flying Machine (#15)
    static var flyingMachineVocabulary: [NotebookEntry] {
        let bid = 15
        return [
            NotebookEntry(
                buildingId: bid,
                entryType: .vocabulary,
                science: .engineering,
                title: "Ornithopter",
                body: "**Ornithopter** — a flying machine that generates lift by flapping its wings, inspired by bird flight. Leonardo designed several versions between 1485-1490."
            ),
            NotebookEntry(
                buildingId: bid,
                entryType: .vocabulary,
                science: .physics,
                title: "Lift",
                body: "**Lift** — the upward force on a wing created by air flowing faster over the curved top than the flat bottom. Leonardo observed this principle in bird wings centuries before it was mathematically described."
            ),
            NotebookEntry(
                buildingId: bid,
                entryType: .vocabulary,
                science: .physics,
                title: "Drag",
                body: "**Drag** — the air resistance that opposes forward motion. Leonardo realized that streamlined shapes (like fish and birds) reduce drag, informing his aircraft designs."
            ),
            NotebookEntry(
                buildingId: bid,
                entryType: .vocabulary,
                science: .physics,
                title: "Airfoil",
                body: "**Airfoil** — the cross-sectional shape of a wing, curved on top and flatter below. This shape forces air to move faster above, creating lower pressure and generating lift."
            ),
            NotebookEntry(
                buildingId: bid,
                entryType: .vocabulary,
                science: .engineering,
                title: "Air Screw",
                body: "**Air Screw** — Leonardo's helicopter precursor (1489) — a helical screw meant to \"screw\" through air like a corkscrew through cork. It anticipated the helicopter rotor by 400 years."
            ),
            NotebookEntry(
                buildingId: bid,
                entryType: .vocabulary,
                science: .mathematics,
                title: "Wingspan",
                body: "**Wingspan** — the distance from wingtip to wingtip. Leonardo calculated that a human-carrying ornithopter would need wings spanning at least 12 meters (40 feet)."
            ),
        ]
    }

    // MARK: - Vatican Observatory (#16)
    static var vaticanObservatoryVocabulary: [NotebookEntry] {
        let bid = 16
        return [
            NotebookEntry(
                buildingId: bid,
                entryType: .vocabulary,
                science: .astronomy,
                title: "Meridian",
                body: "**Meridian** — an imaginary line running north-south. A meridian line on a church floor tracks the sun's position throughout the year, functioning as a giant sundial."
            ),
            NotebookEntry(
                buildingId: bid,
                entryType: .vocabulary,
                science: .astronomy,
                title: "Solstice",
                body: "**Solstice** — the two days each year (around June 21 and December 21) when the sun reaches its highest or lowest point in the sky. Meridian lines precisely mark these dates."
            ),
            NotebookEntry(
                buildingId: bid,
                entryType: .vocabulary,
                science: .optics,
                title: "Refraction",
                body: "**Refraction** — the bending of light through lenses or the atmosphere. Galileo used two lenses (convex + concave) to build his telescope, magnifying objects 20 times."
            ),
            NotebookEntry(
                buildingId: bid,
                entryType: .vocabulary,
                science: .mathematics,
                title: "Gregorian",
                body: "**Gregorian** — relating to the calendar reform of 1582 by Pope Gregory XIII. The Julian calendar had drifted 10 days — the fix required dropping 10 days from October."
            ),
            NotebookEntry(
                buildingId: bid,
                entryType: .vocabulary,
                science: .astronomy,
                title: "Ecliptic",
                body: "**Ecliptic** — the apparent path of the sun across the sky throughout the year. The ecliptic is tilted 23.5° relative to the celestial equator, causing the seasons."
            ),
            NotebookEntry(
                buildingId: bid,
                entryType: .vocabulary,
                science: .astronomy,
                title: "Parallax",
                body: "**Parallax** — the apparent shift in a star's position when viewed from different points in Earth's orbit. Renaissance astronomers struggled to measure stellar parallax, which would prove Earth orbits the sun."
            ),
        ]
    }

    // MARK: - Printing Press (#17)
    static var printingPressVocabulary: [NotebookEntry] {
        let bid = 17
        return [
            NotebookEntry(
                buildingId: bid,
                entryType: .vocabulary,
                science: .engineering,
                title: "Movable Type",
                body: "**Movable Type** — individual letter blocks that can be rearranged to spell any text. Gutenberg's innovation was casting identical metal letters from a hand mold."
            ),
            NotebookEntry(
                buildingId: bid,
                entryType: .vocabulary,
                science: .chemistry,
                title: "Alloy",
                body: "**Alloy** — a mixture of metals. Gutenberg's type metal combined lead (83%), tin (12%), and antimony (5%) — hard enough to stamp thousands of impressions without wearing down."
            ),
            NotebookEntry(
                buildingId: bid,
                entryType: .vocabulary,
                science: .engineering,
                title: "Matrix",
                body: "**Matrix** — a small copper block with a letter carved into it, used as a mold. Molten type metal was poured into the matrix to cast identical copies of each letter."
            ),
            NotebookEntry(
                buildingId: bid,
                entryType: .vocabulary,
                science: .engineering,
                title: "Compositing Stick",
                body: "**Compositing Stick** — a hand-held tray where a typesetter arranged individual letters into lines of text. A skilled compositor could set about 2,000 characters per hour."
            ),
            NotebookEntry(
                buildingId: bid,
                entryType: .vocabulary,
                science: .chemistry,
                title: "Ink",
                body: "**Ink** — Gutenberg invented oil-based printing ink by mixing lampblack (soot) with linseed oil. Water-based ink (used for woodcuts) wouldn't stick to metal type."
            ),
            NotebookEntry(
                buildingId: bid,
                entryType: .vocabulary,
                science: .physics,
                title: "Colophon",
                body: "**Colophon** — a note at the end of a book listing the printer, date, and place of publication. Early printers used colophons before title pages became common."
            ),
        ]
    }
}

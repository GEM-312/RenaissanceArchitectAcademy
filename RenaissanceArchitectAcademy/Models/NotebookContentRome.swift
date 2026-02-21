import Foundation

// MARK: - Ancient Rome Vocabulary (Buildings 1-3, 5-8)

extension NotebookContent {

    // MARK: - Aqueduct (#1)

    static var aqueductVocabulary: [NotebookEntry] {
        let bid = 1 // Aqueduct building ID
        return [
            NotebookEntry(
                buildingId: bid,
                entryType: .vocabulary,
                science: .engineering,
                title: "Specus",
                body: "**Specus** — the main channel that carried water, lined with waterproof concrete (opus signinum). The specus was typically 0.6–0.9 meters wide."
            ),
            NotebookEntry(
                buildingId: bid,
                entryType: .vocabulary,
                science: .hydraulics,
                title: "Castellum",
                body: "**Castellum** — (castellum divisorium) a distribution tank at the end of an aqueduct that divided water into three channels: public fountains, baths, and private users."
            ),
            NotebookEntry(
                buildingId: bid,
                entryType: .vocabulary,
                science: .mathematics,
                title: "Gradient",
                body: "**Gradient** — the slope of the aqueduct channel, typically 1:200 (a drop of 1 meter for every 200 meters). Too steep and water erodes the channel; too gentle and it stagnates."
            ),
            NotebookEntry(
                buildingId: bid,
                entryType: .vocabulary,
                science: .hydraulics,
                title: "Siphon",
                body: "**Siphon** — an inverted siphon used to carry water across valleys. Water descends into a U-shaped pipe and pressure forces it back up the other side."
            ),
            NotebookEntry(
                buildingId: bid,
                entryType: .vocabulary,
                science: .engineering,
                title: "Arcade",
                body: "**Arcade** — a series of arches supporting the channel above ground. The Pont du Gard has three tiers of arches reaching 49 meters high."
            ),
            NotebookEntry(
                buildingId: bid,
                entryType: .vocabulary,
                science: .materials,
                title: "Pozzolana",
                body: "**Pozzolana** — volcanic ash mixed with lime to make waterproof concrete, essential for lining the specus channel."
            ),
        ]
    }

    // MARK: - Colosseum (#2)

    static var colosseumVocabulary: [NotebookEntry] {
        let bid = 2 // Colosseum building ID
        return [
            NotebookEntry(
                buildingId: bid,
                entryType: .vocabulary,
                science: .engineering,
                title: "Velarium",
                body: "**Velarium** — a retractable canvas awning that shaded spectators. Operated by sailors from the Roman navy using 240 mast poles."
            ),
            NotebookEntry(
                buildingId: bid,
                entryType: .vocabulary,
                science: .engineering,
                title: "Hypogeum",
                body: "**Hypogeum** — the underground network of tunnels, cages, and machinery beneath the arena floor. Trap doors and elevators lifted animals and scenery."
            ),
            NotebookEntry(
                buildingId: bid,
                entryType: .vocabulary,
                science: .materials,
                title: "Travertine",
                body: "**Travertine** — a form of limestone used for the Colosseum's exterior. Over 100,000 cubic meters were quarried from Tivoli, 30 km away."
            ),
            NotebookEntry(
                buildingId: bid,
                entryType: .vocabulary,
                science: .architecture,
                title: "Vomitorium",
                body: "**Vomitorium** — (plural: vomitoria) passage entrances that allowed 50,000 spectators to enter or exit in about 15 minutes. From Latin \"vomere\" (to spew forth)."
            ),
            NotebookEntry(
                buildingId: bid,
                entryType: .vocabulary,
                science: .architecture,
                title: "Amphitheater",
                body: "**Amphitheater** — an oval arena enclosed by tiered seating on all sides. \"Amphi\" means \"on both sides\" in Greek — two theaters facing each other."
            ),
            NotebookEntry(
                buildingId: bid,
                entryType: .vocabulary,
                science: .acoustics,
                title: "Cavea",
                body: "**Cavea** — the seating area divided into three sections by social class: ima (senators), media (citizens), summa (commoners and women)."
            ),
        ]
    }

    // MARK: - Roman Baths (#3)

    static var romanBathsVocabulary: [NotebookEntry] {
        let bid = 3 // Roman Baths building ID
        return [
            NotebookEntry(
                buildingId: bid,
                entryType: .vocabulary,
                science: .hydraulics,
                title: "Hypocaust",
                body: "**Hypocaust** — an underfloor heating system where hot air from a furnace (praefurnium) circulated beneath a raised floor supported by brick pillars (pilae)."
            ),
            NotebookEntry(
                buildingId: bid,
                entryType: .vocabulary,
                science: .chemistry,
                title: "Tepidarium",
                body: "**Tepidarium** — the warm room in a Roman bath complex, kept at a comfortable temperature as a transition between hot and cold rooms."
            ),
            NotebookEntry(
                buildingId: bid,
                entryType: .vocabulary,
                science: .chemistry,
                title: "Caldarium",
                body: "**Caldarium** — the hot room, heated directly above the furnace. Water in the alveus (hot tub) reached temperatures of 40°C (104°F)."
            ),
            NotebookEntry(
                buildingId: bid,
                entryType: .vocabulary,
                science: .hydraulics,
                title: "Frigidarium",
                body: "**Frigidarium** — the cold room with a plunge pool. Bathers moved from hot to cold for health benefits — similar to modern contrast therapy."
            ),
            NotebookEntry(
                buildingId: bid,
                entryType: .vocabulary,
                science: .materials,
                title: "Mosaic",
                body: "**Mosaic** — decorative floor art made from tiny stone or glass pieces (tesserae). Bath mosaics often depicted marine scenes and geometric patterns."
            ),
            NotebookEntry(
                buildingId: bid,
                entryType: .vocabulary,
                science: .materials,
                title: "Thermae",
                body: "**Thermae** — the Latin term for large public bath complexes. The Baths of Caracalla covered 25 acres and could hold 1,600 bathers at once."
            ),
        ]
    }

    // MARK: - Roman Roads (#5)

    static var romanRoadsVocabulary: [NotebookEntry] {
        let bid = 5 // Roman Roads building ID
        return [
            NotebookEntry(
                buildingId: bid,
                entryType: .vocabulary,
                science: .engineering,
                title: "Via",
                body: "**Via** — Latin for road. The Via Appia (Appian Way), built in 312 BC, was the first major Roman road and is still visible today."
            ),
            NotebookEntry(
                buildingId: bid,
                entryType: .vocabulary,
                science: .geology,
                title: "Statumen",
                body: "**Statumen** — the bottom layer of a Roman road, made of large flat stones. It provided a stable foundation and drainage."
            ),
            NotebookEntry(
                buildingId: bid,
                entryType: .vocabulary,
                science: .materials,
                title: "Summa Crusta",
                body: "**Summa Crusta** — the top surface layer of tightly fitted polygonal stone blocks, usually basalt. The interlocking pattern distributed weight evenly."
            ),
            NotebookEntry(
                buildingId: bid,
                entryType: .vocabulary,
                science: .engineering,
                title: "Groma",
                body: "**Groma** — a surveying instrument with two crossed arms and hanging plumb weights, used to lay out perfectly straight road lines."
            ),
            NotebookEntry(
                buildingId: bid,
                entryType: .vocabulary,
                science: .mathematics,
                title: "Milestone",
                body: "**Milestone** — (miliarium) stone markers placed every Roman mile (1,000 paces ≈ 1.48 km) recording distance to the next town and who paid for repairs."
            ),
            NotebookEntry(
                buildingId: bid,
                entryType: .vocabulary,
                science: .engineering,
                title: "Crown",
                body: "**Crown** — the slight convex curve of the road surface (higher in the center), which directed rainwater to drainage ditches on either side."
            ),
        ]
    }

    // MARK: - Harbor (#6)

    static var harborVocabulary: [NotebookEntry] {
        let bid = 6 // Harbor building ID
        return [
            NotebookEntry(
                buildingId: bid,
                entryType: .vocabulary,
                science: .engineering,
                title: "Breakwater",
                body: "**Breakwater** — a structure built into the sea to protect a harbor from waves. Roman breakwaters used pozzolana concrete poured into wooden forms underwater."
            ),
            NotebookEntry(
                buildingId: bid,
                entryType: .vocabulary,
                science: .physics,
                title: "Pharos",
                body: "**Pharos** — a lighthouse, named after the famous Pharos of Alexandria. Roman harbors used fire beacons at the top of towers to guide ships at night."
            ),
            NotebookEntry(
                buildingId: bid,
                entryType: .vocabulary,
                science: .hydraulics,
                title: "Pozzolana Concrete",
                body: "**Pozzolana Concrete** — concrete made with volcanic ash that hardens underwater through a chemical reaction with seawater. Still strong after 2,000 years."
            ),
            NotebookEntry(
                buildingId: bid,
                entryType: .vocabulary,
                science: .physics,
                title: "Ballast",
                body: "**Ballast** — heavy material (usually stones or sand) placed in the bottom of a ship to keep it stable. Roman grain ships carried ballast on outbound voyages."
            ),
            NotebookEntry(
                buildingId: bid,
                entryType: .vocabulary,
                science: .engineering,
                title: "Quay",
                body: "**Quay** — a solid wharf built along the water's edge for loading and unloading ships. Roman quays used massive stone blocks and concrete foundations."
            ),
            NotebookEntry(
                buildingId: bid,
                entryType: .vocabulary,
                science: .physics,
                title: "Treadwheel Crane",
                body: "**Treadwheel Crane** — a human-powered crane where workers walked inside a large wooden wheel to lift cargo weighing up to 6 tonnes from ships."
            ),
        ]
    }

    // MARK: - Siege Workshop (#7)

    static var siegeWorkshopVocabulary: [NotebookEntry] {
        let bid = 7 // Siege Workshop building ID
        return [
            NotebookEntry(
                buildingId: bid,
                entryType: .vocabulary,
                science: .physics,
                title: "Catapult",
                body: "**Catapult** — (onager) a one-armed torsion engine that hurled heavy stones. The arm was pulled back against twisted sinew ropes, storing elastic potential energy."
            ),
            NotebookEntry(
                buildingId: bid,
                entryType: .vocabulary,
                science: .engineering,
                title: "Ballista",
                body: "**Ballista** — a two-armed torsion weapon resembling a giant crossbow. It fired bolts or stones with deadly accuracy up to 500 meters."
            ),
            NotebookEntry(
                buildingId: bid,
                entryType: .vocabulary,
                science: .physics,
                title: "Trebuchet",
                body: "**Trebuchet** — a later siege engine using a counterweight to launch projectiles. The heavy end falls, the light end whips up — converting gravitational energy to kinetic."
            ),
            NotebookEntry(
                buildingId: bid,
                entryType: .vocabulary,
                science: .physics,
                title: "Torsion",
                body: "**Torsion** — the twisting force stored in bundles of sinew, hair, or rope. Roman engineers discovered that animal sinew provided the greatest energy storage."
            ),
            NotebookEntry(
                buildingId: bid,
                entryType: .vocabulary,
                science: .mathematics,
                title: "Trajectory",
                body: "**Trajectory** — the curved path a projectile follows through the air, affected by launch angle, speed, and gravity. A 45° angle gives maximum range."
            ),
            NotebookEntry(
                buildingId: bid,
                entryType: .vocabulary,
                science: .engineering,
                title: "Counterweight",
                body: "**Counterweight** — a heavy mass (often stone-filled box) that falls under gravity to power a trebuchet's throwing arm. Heavier counterweight = greater range."
            ),
        ]
    }

    // MARK: - Insula (#8)

    static var insulaVocabulary: [NotebookEntry] {
        let bid = 8 // Insula building ID
        return [
            NotebookEntry(
                buildingId: bid,
                entryType: .vocabulary,
                science: .architecture,
                title: "Insula",
                body: "**Insula** — (plural: insulae) a Roman apartment block, typically 6–7 stories tall. The word means \"island\" because each block was surrounded by streets."
            ),
            NotebookEntry(
                buildingId: bid,
                entryType: .vocabulary,
                science: .architecture,
                title: "Taberna",
                body: "**Taberna** — a ground-floor shop or workshop built into the front of an insula. Shopkeepers often lived in a loft (pergula) above their business."
            ),
            NotebookEntry(
                buildingId: bid,
                entryType: .vocabulary,
                science: .materials,
                title: "Opus Latericium",
                body: "**Opus Latericium** — brick-faced concrete construction. Triangular bricks were set into wet mortar, creating strong walls that resisted fire better than timber."
            ),
            NotebookEntry(
                buildingId: bid,
                entryType: .vocabulary,
                science: .architecture,
                title: "Cenaculum",
                body: "**Cenaculum** — an upper-floor apartment room. The higher the floor, the cheaper the rent — top floors had no running water and were fire traps."
            ),
            NotebookEntry(
                buildingId: bid,
                entryType: .vocabulary,
                science: .architecture,
                title: "Atrium",
                body: "**Atrium** — the central courtyard of a Roman house. While insulae lacked proper atria, some had small light wells for ventilation and natural light."
            ),
            NotebookEntry(
                buildingId: bid,
                entryType: .vocabulary,
                science: .mathematics,
                title: "Load-bearing Wall",
                body: "**Load-bearing Wall** — a wall that supports the weight of floors above it. In insulae, the ground floor used thick brick walls while upper floors dangerously used timber."
            ),
        ]
    }
}

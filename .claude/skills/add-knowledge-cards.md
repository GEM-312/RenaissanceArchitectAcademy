---
name: add-knowledge-cards
description: Author knowledge cards for a building across all environments
---

Help author knowledge cards for a building. Ask the user which building, then:

1. Read `RenaissanceArchitectAcademy/Models/KnowledgeCard.swift` for the model and content pattern
2. Read existing Pantheon cards as reference (14 cards: 5 cityMap, 4 workshop, 2 forest, 3 craftingRoom)

Create cards following these rules:
- **Writing style: Morgan Housel** — punchy, story-driven, ~60-80 words per card
- Spread across environments: cityMap, workshop, forest, craftingRoom
- Each card has: id, buildingName, environment, title, body, science tag
- Add to `KnowledgeCardContent` in KnowledgeCard.swift

Target ~12-14 cards per building with good environment distribution.

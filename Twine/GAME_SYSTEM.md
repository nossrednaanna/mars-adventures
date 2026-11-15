# Space-fantasy story system

This story uses a compact d20 system inspired by tabletop role-playing games while keeping its space-mission setting and rules original.

## Core check

1. Roll `1d20`.
2. Add the participating crew's average current Stardust, rounded down. This is the team modifier; there is no separate teamwork tally.
3. Meet or exceed the Difficulty Class (DC) to succeed.
4. A natural 20 creates a critical success; a natural 1 creates a critical failure.

## Attributes

- **Might** — force, endurance, combat, and physical risk.
- **Wits** — science, magic-like signal craft, investigation, and technology.
- **Presence** — persuasion, command, empathy, and communion with strange beings.

## Mission roles and crew structure

- **Engineer** — excels at repairing machinery, forcing damaged systems, and improvising technical solutions.
- **Researcher** — investigates minerals, plants, gases, liquids, and other subjects of scientific interest.
- **Medic** — excels at treating injuries, stabilizing the crew, and reading human behaviour under pressure.
- **Programer** — writes code and maintains or develops the mission's computing systems.
- **Modeler** — uses computer simulations to predict local climate and environmental conditions.
- **Electrician (AKA Sparky)** — repairs wiring, electrical conductors, and the ship's power systems.
- **Astrophysicist** — excels at navigation, energy phenomena, orbital mechanics, and interpreting signals from space.

Players may select any team size from one to seven characters. Only selected characters are named and displayed in the persistent crew status bar.

The player builds a flexible mission roster from the seven available roles rather than selecting one permanent protagonist. Each challenge can involve a lead specialist, a subset of the selected team, or the whole selected crew.

Individual subquests temporarily send one character away from the group. Their result changes shared mission resources and may give that character stress.

## Daily station loop

Each station day has four chronological missions:

1. **Morning** — establish safe station operations.
2. **Midday** — survey and explore the station.
3. **Evening** — respond to a developing threat.
4. **Night** — secure the habitat and investigate hidden activity.

All selected astronauts belong to the mission roster, but each challenge may use any non-empty subset of that roster. Before a challenge begins, the player chooses its participating crew. The challenge modifier is their average current Stardust, so it reflects individual crew condition rather than group size or a separate teamwork tally. Only participating astronauts receive that challenge's Stardust effects.

Each mission is a hub with at least two independent primary challenges at depth 1. Both primary challenges must be completed before time can advance. The first primary challenge is resolved independently using its d20 plus average-Stardust check and its physical d6 Stardust-loss roll. A separate second d6 then determines the route: 1–3 makes the linked follow-up challenge mandatory, while 4–6 returns directly to the mission. This routing roll never changes Stardust. A depth-2 follow-up always returns to its originating mission and cannot open another challenge. This guarantees a maximum challenge depth of two while allowing multiple challenges per mission.

Straightforward navigation uses Twine's `[[label->Passage]]` link notation. Challenge routes require Harlowe macros to prepare a destination and participating crew, so each dynamic route also has an `(if: false)[[map label->Passage]]` marker. These markers are invisible during play but make the corresponding arrows appear in Twine's story map.

At the end of the day, shared resources and individual stress determine which quests are available the following morning.

## Resources

- **Stardust** is each astronaut's persistent health and resilience score. Every selected astronaut begins with 6 Stardust, with a minimum of 0 and maximum of 12.
- Completing a mission gives +2 Stardust to every astronaut who participated in at least one of that mission's challenges. Participation is accumulated across the mission, and the completion reward is granted only once.
- Challenges can only reduce Stardust. After a challenge, choose one participating astronaut and enter the physical d6 result: 1 = −5 Stardust, 2 = −3, 3–4 = −1, and 5–6 = no loss.
- The crew status header appears as a single horizontal line at the top of every story passage after crew naming. On narrow screens it scrolls horizontally instead of wrapping onto extra lines.
- **Resolve** is a scarce resource that can turn a failed scene into a costly success.
- **Credits** are rewards and can later support equipment, repairs, or bribes.

## Quest states

Use `Unstarted`, `Active`, `Completed`, and `Failed`. Later quests can also use `Complication` when the objective remains possible but the situation has worsened.

## Design rule

Every meaningful check should lead somewhere:

- Critical success: extra reward, secret, ally, or new route.
- Success: intended progress.
- Failure: damage, lost resources, harder choices, or a new complication.
- Critical failure: a major twist, never a dead screen with no decision.

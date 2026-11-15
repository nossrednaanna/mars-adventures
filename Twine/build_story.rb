#!/usr/bin/env ruby

require "cgi"

story_path = File.join(__dir__, "Stories", "Mars adventures .html")
image_directory = File.expand_path("images", __dir__)
local_image_base = "file://#{image_directory.gsub(" ", "%20")}" 

css = <<~CSS
  tw-story {
    background-color: #050914;
    background-image: linear-gradient(rgba(3, 6, 16, .68), rgba(3, 6, 16, .82)), url("#{local_image_base}/passage-background.png");
    background-position: center;
    background-size: cover;
    background-attachment: fixed;
    color: #f5f7ff;
    font-family: system-ui, sans-serif;
  }
  tw-passage { max-width: 1100px; padding: 0; }
  tw-link { color: #91c9ff; }
  tw-link:hover { color: #fff; }
  .scene-page { min-height: 78vh; display: flex; align-items: flex-end; box-sizing: border-box; padding: clamp(1.25rem, 5vw, 4rem); border-radius: 1rem; overflow: hidden; background-position: center; background-size: cover; box-shadow: inset 0 -16rem 12rem -6rem rgba(0,0,0,.92); }
  .scene-content { max-width: 46rem; padding: clamp(1.25rem, 3vw, 2.25rem); border: 1px solid rgba(255,255,255,.18); border-radius: .8rem; background: rgba(3,8,20,.78); backdrop-filter: blur(8px); }
  .scene-content h1 { margin-top: 0; }
  .hud, .roll-card, .quest-card, .schedule { display: flex; flex-wrap: wrap; gap: .65rem 1.25rem; margin: 1rem 0; padding: 1rem; border: 1px solid rgba(145,201,255,.28); border-radius: .75rem; background: rgba(12,23,48,.88); }
  .hud span { color: #dcecff; font-size: .85rem; letter-spacing: .04em; }
  .crew-grid, .choice-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(13rem, 1fr)); gap: .8rem; margin: 1rem 0; }
  .crew-card { padding: 1rem; border: 1px solid rgba(145,201,255,.25); border-radius: .7rem; background: rgba(15,29,58,.78); }
  .crew-card strong { color: #b9ddff; }
  .role-portrait { display: block; width: 100%; max-width: 8rem; aspect-ratio: 1; margin: 0 auto .6rem; border-radius: .7rem; background: radial-gradient(circle, rgba(145,201,255,.2), rgba(11,22,46,.18) 70%); object-fit: contain; }
  .crew-status-bar { display: flex; flex-flow: row nowrap; gap: .5rem; width: 100%; max-width: 1100px; margin: 0 auto 1rem; overflow-x: auto; padding: .2rem 0 .45rem; scrollbar-color: rgba(145,201,255,.5) transparent; }
  .crew-status-card { flex: 1 0 8.25rem; min-width: 0; padding: .5rem; border: 1px solid rgba(145,201,255,.3); border-radius: .65rem; background: rgba(10,20,42,.94); text-align: center; }
  .crew-portrait { display: block; width: 3.4rem; height: 3.4rem; margin: 0 auto .25rem; border: 2px solid rgba(145,201,255,.55); border-radius: 50%; background: #101c36; object-fit: cover; }
  .crew-status-name { display: block; overflow: hidden; color: #eaf5ff; font-weight: 700; text-overflow: ellipsis; white-space: nowrap; }
  .crew-status-role { display: block; overflow: hidden; color: #9db8d8; font-size: .68rem; text-overflow: ellipsis; white-space: nowrap; }
  .stardust-score { display: block; margin-top: .25rem; color: #ffe79b; font-size: .8rem; font-weight: 700; white-space: nowrap; }
  .stardust-input { display: block; width: min(100%, 32rem); margin-top: 1rem; padding: 1rem; border: 1px solid rgba(255,231,155,.4); border-radius: .75rem; background: rgba(44,35,69,.88); }
  .mission-image { display: block; width: 100%; max-height: 31rem; margin: 1rem 0; border: 1px solid rgba(145,201,255,.28); border-radius: .85rem; object-fit: cover; }
  .challenge-name { display: inline-block; margin-left: .5rem; padding: .2rem .5rem; border-radius: 999px; background: rgba(145,201,255,.14); }
  .roll-equation { display: block; flex-basis: 100%; line-height: 1.8; }
  .roll-equation strong { margin: 0 .18rem; color: #ffe79b; }
  .stardust-roster { display: flex; flex-wrap: wrap; gap: .45rem; margin: .75rem 0; }
  .stardust-member { padding: .35rem .55rem; border: 1px solid rgba(255,231,155,.32); border-radius: .5rem; background: rgba(10,20,42,.55); white-space: nowrap; }
  .choice-grid tw-link, .action-link tw-link { display: block; box-sizing: border-box; padding: .85rem 1rem; border: 1px solid rgba(145,201,255,.45); border-radius: .65rem; background: rgba(40,76,125,.35); }
  .choice-grid tw-link:hover, .action-link tw-link:hover { background: rgba(70,120,185,.48); }
  .schedule span { opacity: .55; }
  .schedule .current { color: #fff; opacity: 1; font-weight: 700; }
  .success { color: #8fffc1; }
  .danger { color: #ff9a9a; }
  .warning { color: #ffd27d; }
  @media (max-width: 600px) { .scene-page { min-height: 70vh; padding: .75rem; } .crew-status-card { flex-basis: 7.25rem; } }
CSS

passages = [
  [1, "Mars Approach", "700,250", <<~'TWINE'],
    (set: $day to 0, $stage to "Arrival")
    (set: $morale to 6, $supplies to 8, $stationPower to 0, $discoveries to 0)
    (set: $stardustMax to 12)
    (set: $engineerStardust to 6, $researcherStardust to 6, $medicStardust to 6, $programerStardust to 6)
    (set: $modelerStardust to 6, $electricianStardust to 6, $physicistStardust to 6)
    (set: $engineerStress to 0, $medicStress to 0, $physicistStress to 0, $biologistStress to 0)
    (set: $morningComplete to false, $middayComplete to false, $eveningComplete to false, $nightComplete to false)
    (set: $morningFirstComplete to false, $middayFirstComplete to false, $eveningFirstComplete to false, $nightFirstComplete to false)
    (set: $morningSecondComplete to false, $middaySecondComplete to false, $eveningSecondComplete to false, $nightSecondComplete to false)
    (set: $morningDeepComplete to false, $middayDeepComplete to false, $eveningDeepComplete to false, $nightDeepComplete to false)
    (set: $morningRewardGranted to false, $middayRewardGranted to false, $eveningRewardGranted to false, $nightRewardGranted to false)
    (set: $morningEngineerParticipated to false, $morningResearcherParticipated to false, $morningMedicParticipated to false, $morningProgramerParticipated to false, $morningModelerParticipated to false, $morningElectricianParticipated to false, $morningPhysicistParticipated to false)
    (set: $middayEngineerParticipated to false, $middayResearcherParticipated to false, $middayMedicParticipated to false, $middayProgramerParticipated to false, $middayModelerParticipated to false, $middayElectricianParticipated to false, $middayPhysicistParticipated to false)
    (set: $eveningEngineerParticipated to false, $eveningResearcherParticipated to false, $eveningMedicParticipated to false, $eveningProgramerParticipated to false, $eveningModelerParticipated to false, $eveningElectricianParticipated to false, $eveningPhysicistParticipated to false)
    (set: $nightEngineerParticipated to false, $nightResearcherParticipated to false, $nightMedicParticipated to false, $nightProgramerParticipated to false, $nightModelerParticipated to false, $nightElectricianParticipated to false, $nightPhysicistParticipated to false)
    (set: $missionStatus to "Approaching Mars")
    (set: $returnPassage to "Mars Approach")

    <div class="scene-page" style="background-image: url('../images/station-placeholder.svg');">
      <div class="scene-content">
        # Life on Mars

        ## Welcome to the Shooting Star

        Welcome to the **Shooting Star**, the fastest rocket ship in the galaxy!

        In this game, you will find out which planet is closest to the Sun, exactly how far away it is, and what it is really like to survive on Mars. The mission comes with many risks and dangers, including radiation, extreme temperatures, and many other problems.

        Anyway—buckle up, start the engines, and let's get this going!

        <div class="crew-grid">
          <div class="crew-card"><img class="role-portrait" src="../images/astronaut-engineer.png" alt="Engineer astronaut"><strong>Engineer</strong><br>Systems, repair, structures</div>
          <div class="crew-card"><img class="role-portrait" src="../images/astronaut-researcher.png" alt="Researcher astronaut"><strong>Researcher</strong><br>Minerals, plants, gases, liquids, and other discoveries</div>
          <div class="crew-card"><img class="role-portrait" src="../images/astronaut-medic.png" alt="Medic astronaut"><strong>Medic</strong><br>Health, trauma, crew safety</div>
          <div class="crew-card"><img class="role-portrait" src="../images/astronaut-programer.png" alt="Programer astronaut"><strong>Programer</strong><br>Code and computing systems</div>
          <div class="crew-card"><img class="role-portrait" src="../images/astronaut-modeler.png" alt="Modeler astronaut"><strong>Modeler</strong><br>Computer simulations and climate prediction</div>
          <div class="crew-card"><img class="role-portrait" src="../images/astronaut-electrician.png" alt="Electrician astronaut"><strong>Electrician</strong><br>Wiring and electrical systems</div>
          <div class="crew-card"><img class="role-portrait" src="../images/astronaut-astrophysicist.png" alt="Astrophysicist astronaut"><strong>Astrophysicist</strong><br>Navigation, energy, signals</div>
        </div>

        [[Choose the surface team->Choose Your Character]]
      </div>
    </div>
  TWINE
  [2, "Choose Your Character", "700,375", <<~'TWINE'],
    # Choose your character

    Seven specialists made the journey to Mars. Select any number of characters for the surface expedition; unselected crew members will support the mission from orbit.

    <div class="choice-grid">
    <div class="crew-card"><img class="role-portrait" src="../images/astronaut-engineer.png" alt="Engineer astronaut">(checkbox: bind $takeEngineer, "Engineer")<br>The Engineer helps around the ship by fixing broken parts and machinery.</div>
    <div class="crew-card"><img class="role-portrait" src="../images/astronaut-researcher.png" alt="Researcher astronaut">(checkbox: bind $takeResearcher, "Researcher")<br>The Researcher investigates minerals, plants, gases, liquids, and other subjects of interest.</div>
    <div class="crew-card"><img class="role-portrait" src="../images/astronaut-medic.png" alt="Medic astronaut">(checkbox: bind $takeMedic, "Medic")<br>The Medic uses medical knowledge to heal or save a comrade in any situation.</div>
    <div class="crew-card"><img class="role-portrait" src="../images/astronaut-programer.png" alt="Programer astronaut">(checkbox: bind $takeProgramer, "Programer")<br>The Programer uses code to maintain and develop computing systems.</div>
    <div class="crew-card"><img class="role-portrait" src="../images/astronaut-modeler.png" alt="Modeler astronaut">(checkbox: bind $takeModeler, "Modeler")<br>The Modeler uses computer simulations to predict the climate in an area.</div>
    <div class="crew-card"><img class="role-portrait" src="../images/astronaut-electrician.png" alt="Electrician astronaut">(checkbox: bind $takeElectrician, "Electrician — AKA Sparky")<br>The Electrician works in the electrical chamber and repairs wires and other electrical conductors.</div>
    <div class="crew-card"><img class="role-portrait" src="../images/astronaut-astrophysicist.png" alt="Astrophysicist astronaut">(checkbox: bind $takePhysicist, "Astrophysicist")<br>The Astrophysicist studies the rules of the universe and how it works.</div>
    </div>

    (link: "Continue with this team")[
      (set: $selectedCount to 0)
      (if: $takeEngineer)[(set: $selectedCount to it + 1)]
      (if: $takeResearcher)[(set: $selectedCount to it + 1)]
      (if: $takeMedic)[(set: $selectedCount to it + 1)]
      (if: $takeProgramer)[(set: $selectedCount to it + 1)]
      (if: $takeModeler)[(set: $selectedCount to it + 1)]
      (if: $takeElectrician)[(set: $selectedCount to it + 1)]
      (if: $takePhysicist)[(set: $selectedCount to it + 1)]

      (if: $selectedCount > 0)[
        (go-to: "Name Crew")
      ]
      (else:)[
        (alert: "Select at least one crew member before continuing.")
      ]
    ]
  TWINE
  [3, "Name Crew", "825,375", <<~'TWINE'],
    (set: $engineerName to "", $researcherName to "", $medicName to "", $programerName to "")
    (set: $modelerName to "", $electricianName to "", $physicistName to "")
    # Name the selected crew

    Enter a name for each member of the surface team.

    (if: $takeEngineer)[
      **Engineer**
      (input: bind $engineerName, "XXXX=", "Alex")
    ]
    (if: $takeResearcher)[
      **Researcher**
      (input: bind $researcherName, "XXXX=", "Riley")
    ]
    (if: $takeMedic)[
      **Medic**
      (input: bind $medicName, "XXXX=", "Sam")
    ]
    (if: $takeProgramer)[
      **Programer**
      (input: bind $programerName, "XXXX=", "Ada")
    ]
    (if: $takeModeler)[
      **Modeler**
      (input: bind $modelerName, "XXXX=", "Taylor")
    ]
    (if: $takeElectrician)[
      **Electrician — AKA Sparky**
      (input: bind $electricianName, "XXXX=", "Sparky")
    ]
    (if: $takePhysicist)[
      **Astrophysicist**
      (input: bind $physicistName, "XXXX=", "Jordan")
    ]

    (link: "Confirm crew names")[
      (if:
        ($takeEngineer and $engineerName is "") or
        ($takeResearcher and $researcherName is "") or
        ($takeMedic and $medicName is "") or
        ($takeProgramer and $programerName is "") or
        ($takeModeler and $modelerName is "") or
        ($takeElectrician and $electricianName is "") or
        ($takePhysicist and $physicistName is "")
      )[
        (alert: "Please enter a name for every selected crew member.")
      ]
      (else:)[
        (set: $crew to (a:))
        (set: $crewRoles to (a:))
        (if: $takeEngineer)[
          (set: $crew to $crew + (a: (dm: "name", $engineerName, "role", "Engineer")))
          (set: $crewRoles to $crewRoles + (a: "Engineer"))
        ]
        (if: $takeResearcher)[
          (set: $crew to $crew + (a: (dm: "name", $researcherName, "role", "Researcher")))
          (set: $crewRoles to $crewRoles + (a: "Researcher"))
        ]
        (if: $takeMedic)[
          (set: $crew to $crew + (a: (dm: "name", $medicName, "role", "Medic")))
          (set: $crewRoles to $crewRoles + (a: "Medic"))
        ]
        (if: $takeProgramer)[
          (set: $crew to $crew + (a: (dm: "name", $programerName, "role", "Programer")))
          (set: $crewRoles to $crewRoles + (a: "Programer"))
        ]
        (if: $takeModeler)[
          (set: $crew to $crew + (a: (dm: "name", $modelerName, "role", "Modeler")))
          (set: $crewRoles to $crewRoles + (a: "Modeler"))
        ]
        (if: $takeElectrician)[
          (set: $crew to $crew + (a: (dm: "name", $electricianName, "role", "Electrician")))
          (set: $crewRoles to $crewRoles + (a: "Electrician"))
        ]
        (if: $takePhysicist)[
          (set: $crew to $crew + (a: (dm: "name", $physicistName, "role", "Astrophysicist")))
          (set: $crewRoles to $crewRoles + (a: "Astrophysicist"))
        ]
        (go-to: "Arrival and Station")
      ]
    ]
  TWINE
  [4, "Arrival and Station", "950,375", <<~'TWINE'],
    (set: $missionStatus to "Station discovered")
    # Arrival at Mars

    The surface team descends through a dust storm, lands beside a canyon, and deploys the rover. Working together, the astronauts trace the orbital energy signature to a sealed research station buried beneath the Martian surface.

    <div class="quest-card">**DAY 1 OBJECTIVE**<br>Complete four linked missions: Morning, Midday, Evening, and Night. The full roster supports each mission, while individual challenges may use smaller crews.</div>

    [[Begin the morning mission->Morning Mission]]
  TWINE
  [5, "Morning Mission", "700,500", <<~'TWINE'],
    (set: $day to 1, $stage to "Morning", $missionStatus to "Growing food")
    (set: $morningComplete to ($morningFirstComplete and $morningSecondComplete))
    # Mission 1 — Growing food

    <div class="schedule"><span class="current">Morning</span><span>Midday</span><span>Evening</span><span>Night</span></div>
    <div class="hud"><span>MORALE: $morale</span><span>SUPPLIES: $supplies</span><span>POWER: $stationPower</span><span>DISCOVERIES: $discoveries</span></div>

    <img class="mission-image" src="../images/mars-greenhouse.png" alt="An astronaut tending food crops inside a greenhouse on Mars">

    The crew must find out whether plants from Earth can survive on Mars. If they can, the greenhouse will provide fresh food and may also become a useful source of oxygen.

    Build a greenhouse using soil, seeds, and plants brought from Earth. The crops need a reliable water supply, heating through the freezing Martian night, and fertiliser to keep the soil productive.

    <div class="quest-card"><strong>MARS SCIENCE</strong><br>Mars' atmosphere contains a high concentration of carbon dioxide, which plants need for photosynthesis and growth, but its oxygen level is very low.<br><br>Plants release oxygen as a byproduct of photosynthesis, so a healthy greenhouse could help supply oxygen as well as food.</div>

    (if: not $morningFirstComplete)[<div class="action-link">(link: "Challenge 1 — Clean the gardens")[(set: $challengeDestination to "Morning Challenge", $challengeTitle to "Clean the gardens", $challengeMission to "Morning")(go-to: "Select Challenge Crew")]</div>]
    (if: false)[[Map route: clean the gardens->Morning Challenge]]
    (if: not $morningSecondComplete)[<div class="action-link">(link: "Challenge 1.2 — Fungal pathogen")[(set: $challengeDestination to "Morning Second Challenge", $challengeTitle to "Stop the fungal pathogen", $challengeMission to "Morning")(go-to: "Select Challenge Crew")]</div>]
    (if: false)[[Map route: fungal pathogen->Morning Second Challenge]]
    (if: $morningComplete and not $morningRewardGranted)[(set: $rewardMission to "Morning")(display: "Apply Mission Stardust Reward")]
    (if: $morningComplete)[
      <div class="quest-card"><span class="success">Morning mission complete.</span> The team has returned to the mission hub.</div>
      [[Advance in time to the midday mission->Midday Mission]]
    ]
  TWINE
  [6, "Morning Challenge", "825,500", <<~'TWINE'],
    (display: "Calculate Team Stardust")
    (set: $usesD6Check to true, $roll to (random:1,6), $total to $roll, $morningFirstComplete to true)
    # Challenge 1 — Clean the gardens
    (display: "Challenge Crew Display")

    Water the plants in the garden and pump more carbon dioxide into the greenhouse air so the plants can photosynthesise and do not wither and die.

    (if: $roll is 6)[
      (set: $discoveries to $discoveries + 1)
      <span class="success">Exceptional success: the irrigation and airflow are perfectly balanced. The plants perk up, and the crew records useful greenhouse data.</span>
    ]
    (else-if: $roll >= 4)[
      <span class="success">Success: the plants receive enough water and carbon dioxide to continue growing.</span>
    ]
    (else:)[
      (set: $supplies to (max:0,$supplies - 1))
      <span class="warning">Setback: uneven watering damages part of the crop and costs one supply, but the garden can still be saved.</span>
    ]

    **Challenge depth 1 of 2**

    (set: $stardustReturn to "Morning Mission", $stardustFollowup to "Morning Follow-up")
    (if: false)[[Map return->Morning Mission]]
    (if: false)[[Map follow-up->Morning Follow-up]]
    (display: "Stardust Input")
  TWINE
  [7, "Morning Follow-up", "950,500", <<~'TWINE'],
    (set: $roll to (random:1,6), $morningDeepComplete to true)
    # Challenge 1.1 — The open greenhouse
    (display: "Challenge Crew Display")

    You forgot to close the side of the greenhouse overnight, exposing the plants to the freezing Martian cold. Roll the d6 to discover what happens.

    <div class="roll-card"><strong>d6 result: $roll</strong></div>

    (if: $roll is 1)[
      (set: $supplies to (max:0,$supplies - 4))
      (if: $takeEngineer)[(set: $engineerStardust to (max:0,$engineerStardust - 3))](if: $takeResearcher)[(set: $researcherStardust to (max:0,$researcherStardust - 3))](if: $takeMedic)[(set: $medicStardust to (max:0,$medicStardust - 3))](if: $takeProgramer)[(set: $programerStardust to (max:0,$programerStardust - 3))](if: $takeModeler)[(set: $modelerStardust to (max:0,$modelerStardust - 3))](if: $takeElectrician)[(set: $electricianStardust to (max:0,$electricianStardust - 3))](if: $takePhysicist)[(set: $physicistStardust to (max:0,$physicistStardust - 3))]
      <span class="danger">All the plants and soil bacteria freeze to death. There is no fresh food and no way to grow more crops. Every team member loses 3 Stardust.</span>
    ]
    (else-if: $roll <= 3)[
      (set: $supplies to (max:0,$supplies - 2))
      (if: $takeEngineer)[(set: $engineerStardust to (max:0,$engineerStardust - 2))](if: $takeResearcher)[(set: $researcherStardust to (max:0,$researcherStardust - 2))](if: $takeMedic)[(set: $medicStardust to (max:0,$medicStardust - 2))](if: $takeProgramer)[(set: $programerStardust to (max:0,$programerStardust - 2))](if: $takeModeler)[(set: $modelerStardust to (max:0,$modelerStardust - 2))](if: $takeElectrician)[(set: $electricianStardust to (max:0,$electricianStardust - 2))](if: $takePhysicist)[(set: $physicistStardust to (max:0,$physicistStardust - 2))]
      <span class="danger">All the plants and soil bacteria freeze, so there is no fresh food for now. Luckily, secure soil samples, bacteria, and seeds will let the crew restart the crop system, although fresh food is weeks away. Every team member loses 2 Stardust.</span>
    ]
    (else-if: $roll <= 5)[
      (set: $supplies to (max:0,$supplies - 1), $leadRole to $challengeCrewRoles's 1st)
      (if: $leadRole is "Engineer")[(set: $engineerStardust to (max:0,$engineerStardust - 1))](else-if: $leadRole is "Researcher")[(set: $researcherStardust to (max:0,$researcherStardust - 1))](else-if: $leadRole is "Medic")[(set: $medicStardust to (max:0,$medicStardust - 1))](else-if: $leadRole is "Programer")[(set: $programerStardust to (max:0,$programerStardust - 1))](else-if: $leadRole is "Modeler")[(set: $modelerStardust to (max:0,$modelerStardust - 1))](else-if: $leadRole is "Electrician")[(set: $electricianStardust to (max:0,$electricianStardust - 1))](else:)[(set: $physicistStardust to (max:0,$physicistStardust - 1))]
      <span class="warning">An inner wall protects half the plants. The crew loses half the crop but can regrow it over time, and there is still a smaller amount of fresh food. The lead astronaut loses 1 Stardust.</span>
    ]
    (else:)[
      <span class="success">The temperature alarm wakes the crew as the greenhouse approaches freezing. The side is sealed in time and every plant is saved.</span>
    ]

    **Challenge depth 2 of 2 — no deeper challenge links.**

    [[Return to the growing-food mission->Morning Mission]]
  TWINE
  [8, "Midday Mission", "1075,500", <<~'TWINE'],
    (set: $stage to "Midday", $missionStatus to "Protecting the research station")
    (set: $middayComplete to ($middayFirstComplete and $middaySecondComplete))
    # Mission 2 — Protect the research station

    <div class="schedule"><span>Morning</span><span class="current">Midday</span><span>Evening</span><span>Night</span></div>
    <div class="hud"><span>MORALE: $morale</span><span>SUPPLIES: $supplies</span><span>POWER: $stationPower</span><span>DISCOVERIES: $discoveries</span></div>

    The Sun's radiation can harm the crew and damage equipment on Mars. The station must also be insulated against night-time temperatures that can fall to **−90°C**. Complete the work before night arrives so nobody has to remain outside in the extreme cold.

    <div class="quest-card"><strong>ENGINEERING IDEA</strong><br>Computers and other electrical equipment generate heat while they operate. Could the crew capture this waste heat and use it to warm the station at night?</div>

    ## 2.1 — Secure the station

    Fix or tighten every loose and broken part inside the station. This work can be completed indoors, away from the Sun's radiation.

    (if: not $middayFirstComplete)[<div class="action-link">(link: "Secure the station")[(set: $challengeDestination to "Midday Challenge", $challengeTitle to "Secure the station", $challengeMission to "Midday")(go-to: "Select Challenge Crew")]</div>]
    (if: false)[[Map route: secure the station->Midday Challenge]]
    (if: not $middaySecondComplete)[<div class="action-link">(link: "Challenge 2.2 — Solar flare")[(set: $challengeDestination to "Midday Second Challenge", $challengeTitle to "Escape the solar flare", $challengeMission to "Midday")(go-to: "Select Challenge Crew")]</div>]
    (if: false)[[Map route: solar flare->Midday Second Challenge]]
    (if: $middayComplete and not $middayRewardGranted)[(set: $rewardMission to "Midday")(display: "Apply Mission Stardust Reward")]
    (if: $middayComplete)[
      <div class="quest-card"><span class="success">Midday mission complete.</span> The team has returned to the mission hub.</div>
      [[Advance in time to the evening mission->Evening Mission]]
    ]
  TWINE
  [9, "Midday Challenge", "1200,500", <<~'TWINE'],
    (display: "Calculate Team Stardust")
    (set: $usesD6Check to true, $roll to (random:1,6), $total to $roll, $middayFirstComplete to true)
    # Mission 2.1 — Secure the station
    (display: "Challenge Crew Display")

    Working safely inside, tighten loose fittings, repair broken panels, seal draughts, and connect the computers' waste-heat vents to the station's heating system.

    (if: $roll is 6)[
      (set: $stationPower to $stationPower + 1)
      <span class="success">Exceptional success: the station is secure, and the crew successfully redirects waste heat from the computers to warm the habitat.</span>
    ]
    (else-if: $roll >= 4)[
      <span class="success">Success: loose equipment is tightened, damaged panels are repaired, and the station is ready for the cold night.</span>
    ]
    (else:)[
      (set: $supplies to (max:0,$supplies - 1))
      <span class="warning">Setback: a damaged interior seal requires an extra supply, but the crew secures the station.</span>
    ]

    **Challenge depth 1 of 2**

    (set: $stardustReturn to "Midday Mission", $stardustFollowup to "Midday Follow-up")
    (if: false)[[Map return->Midday Mission]]
    (if: false)[[Map follow-up->Midday Follow-up]]
    (display: "Stardust Input")
  TWINE
  [10, "Midday Follow-up", "1325,500", <<~'TWINE'],
    (set: $roll to (random:1,6), $middayDeepComplete to true, $leadRole to $challengeCrewRoles's 1st)
    # Challenge 2.1 — Dust storm
    (display: "Challenge Crew Display")

    While you are attaching the last section of exterior insulation for the **−90°C** night, a giant dust storm arrives and blows you off the roof. Roll the d6 to see what happens.

    <div class="roll-card"><strong>d6 result: $roll</strong></div>

    (if: $roll is 1)[
      (set: $damage to 5)(display: "Apply Lead Damage")
      <span class="danger">You become lost in the dust and cannot find your way back. Damage: 5 Stardust.</span>
    ]
    (else-if: $roll <= 3)[
      (set: $damage to 3)(display: "Apply Lead Damage")
      <span class="danger">You fall unconscious until the medic finds you. Damage: 3 Stardust.</span>
    ]
    (else-if: $roll <= 5)[
      (set: $damage to 1)(display: "Apply Lead Damage")
      <span class="warning">You break your leg and cannot stand without help. Damage: 1 Stardust.</span>
    ]
    (else:)[
      <span class="success">You graze your knee and say, “Ouch!” Damage: 0 Stardust.</span>
    ]

    **Challenge depth 2 of 2 — no deeper challenge links.**

    [[Return to the station-protection mission->Midday Mission]]
  TWINE
  [11, "Evening Mission", "700,625", <<~'TWINE'],
    (set: $stage to "Evening")
    (set: $eveningComplete to ($eveningFirstComplete and $eveningSecondComplete))
    # Mission 3 — Evening

    <div class="schedule"><span>Morning</span><span>Midday</span><span class="current">Evening</span><span>Night</span></div>
    <div class="hud"><span>MORALE: $morale</span><span>SUPPLIES: $supplies</span><span>POWER: $stationPower</span><span>DISCOVERIES: $discoveries</span></div>

    An alarm calls the entire team to the greenhouse. Unknown growth is spreading into the ventilation system.

    (if: not $eveningFirstComplete)[<div class="action-link">(link: "Choose a crew for organism containment")[(set: $challengeDestination to "Evening Challenge", $challengeTitle to "Contain the growth", $challengeMission to "Evening")(go-to: "Select Challenge Crew")]</div>]
    (if: false)[[Map route: organism containment->Evening Challenge]]
    (if: not $eveningSecondComplete)[<div class="action-link">(link: "Choose a crew to decontaminate the vents")[(set: $challengeDestination to "Evening Second Challenge", $challengeTitle to "Decontaminate the ventilation system", $challengeMission to "Evening")(go-to: "Select Challenge Crew")]</div>]
    (if: false)[[Map route: decontaminate vents->Evening Second Challenge]]
    (if: $eveningComplete and not $eveningRewardGranted)[(set: $rewardMission to "Evening")(display: "Apply Mission Stardust Reward")]
    (if: $eveningComplete)[
      <div class="quest-card"><span class="success">Evening mission complete.</span> The team has returned to the mission hub.</div>
      [[Advance in time to the night mission->Night Mission]]
    ]
  TWINE
  [12, "Evening Challenge", "825,625", <<~'TWINE'],
    (display: "Calculate Team Stardust")
    (set: $roll to (random:1,20), $dc to 12)
    (set: $total to $roll + $modifier, $eveningFirstComplete to true)
    # Evening challenge — Contain the growth
    (display: "Challenge Crew Display")

    Every astronaut contributes: sealing vents, monitoring health, analyzing the organism, and controlling the greenhouse systems.

    (if: $total >= $dc)[
      (set: $discoveries to $discoveries + 1)
      <span class="success">The growth is contained and a viable sample is secured.</span>
    ]
    (else:)[
      (set: $supplies to (max:0,$supplies - 1), $morale to (max:0,$morale - 1))
      <span class="danger">The greenhouse is sealed permanently and the team loses supplies.</span>
    ]

    **Challenge depth 1 of 2**

    (set: $stardustReturn to "Evening Mission", $stardustFollowup to "Evening Follow-up")
    (if: false)[[Map return->Evening Mission]]
    (if: false)[[Map follow-up->Evening Follow-up]]
    (display: "Stardust Input")
  TWINE
  [13, "Evening Follow-up", "950,625", <<~'TWINE'],
    (display: "Calculate Team Stardust")
    (set: $roll to (random:1,20), $dc to 14)
    (set: $total to $roll + $modifier, $eveningDeepComplete to true)
    # Evening follow-up — Analyze the organism
    (display: "Challenge Crew Display")

    The full team conducts a rapid laboratory analysis before the sample degrades.

    (if: $total >= $dc)[
      (set: $discoveries to $discoveries + 1)
      <span class="success">The organism is neither terrestrial nor Martian. It responds to the station's hidden signal.</span>
    ]
    (else:)[
      <span class="warning">The sample degrades before its origin can be confirmed.</span>
    ]

    **Challenge depth 2 of 2 — no deeper challenge links.**

    (set: $stardustReturn to "Evening Mission", $stardustFollowup to "")
    (if: false)[[Map return->Evening Mission]]
    (display: "Stardust Input")
  TWINE
  [14, "Night Mission", "1075,625", <<~'TWINE'],
    (set: $stage to "Night")
    (set: $nightComplete to ($nightFirstComplete and $nightSecondComplete))
    # Mission 4 — Night

    <div class="schedule"><span>Morning</span><span>Midday</span><span>Evening</span><span class="current">Night</span></div>
    <div class="hud"><span>MORALE: $morale</span><span>SUPPLIES: $supplies</span><span>POWER: $stationPower</span><span>DISCOVERIES: $discoveries</span></div>

    Before anyone can sleep, the entire team must secure the habitat and investigate a repeating vibration beneath the floor.

    (if: not $nightFirstComplete)[<div class="action-link">(link: "Choose a crew to secure the habitat")[(set: $challengeDestination to "Night Challenge", $challengeTitle to "Secure the habitat", $challengeMission to "Night")(go-to: "Select Challenge Crew")]</div>]
    (if: false)[[Map route: secure habitat->Night Challenge]]
    (if: not $nightSecondComplete)[<div class="action-link">(link: "Choose a crew for the perimeter patrol")[(set: $challengeDestination to "Night Second Challenge", $challengeTitle to "Patrol the station perimeter", $challengeMission to "Night")(go-to: "Select Challenge Crew")]</div>]
    (if: false)[[Map route: perimeter patrol->Night Second Challenge]]
    (if: $nightComplete and not $nightRewardGranted)[(set: $rewardMission to "Night")(display: "Apply Mission Stardust Reward")]
    (if: $nightComplete)[
      <div class="quest-card"><span class="success">Night mission complete.</span> The team has returned to the mission hub.</div>
      [[End Day 1->Day 1 Summary]]
    ]
  TWINE
  [15, "Night Challenge", "1200,625", <<~'TWINE'],
    (display: "Calculate Team Stardust")
    (set: $roll to (random:1,20), $dc to 12)
    (set: $total to $roll + $modifier, $nightFirstComplete to true)
    # Night challenge — Secure the habitat
    (display: "Challenge Crew Display")

    The astronauts check seals, medical status, sensors, and power reserves as one team.

    (if: $total >= $dc)[
      (set: $morale to $morale + 1)
      <span class="success">The habitat is secure and the crew gains morale.</span>
    ]
    (else:)[
      (set: $supplies to (max:0,$supplies - 1))
      <span class="warning">A failing seal consumes one supply unit before it is stabilized.</span>
    ]

    **Challenge depth 1 of 2**

    (set: $stardustReturn to "Night Mission", $stardustFollowup to "Night Follow-up")
    (if: false)[[Map return->Night Mission]]
    (if: false)[[Map follow-up->Night Follow-up]]
    (display: "Stardust Input")
  TWINE
  [16, "Night Follow-up", "1325,625", <<~'TWINE'],
    (display: "Calculate Team Stardust")
    (set: $roll to (random:1,20), $dc to 15)
    (set: $total to $roll + $modifier, $nightDeepComplete to true)
    # Night follow-up — The signal below
    (display: "Challenge Crew Display")

    The team descends one level and listens as the vibration resolves into a repeating coded signal.

    (if: $total >= $dc)[
      (set: $discoveries to $discoveries + 2)
      <span class="success">The signal is a response. Something below knows the astronauts have arrived.</span>
    ]
    (else:)[
      (set: $morale to (max:0,$morale - 1))
      <span class="danger">The signal stops when the team approaches. Morale falls.</span>
    ]

    **Challenge depth 2 of 2 — no deeper challenge links.**

    (set: $stardustReturn to "Night Mission", $stardustFollowup to "")
    (if: false)[[Map return->Night Mission]]
    (display: "Stardust Input")
  TWINE
  [17, "Day 1 Summary", "950,750", <<~'TWINE'],
    (set: $stage to "Complete")
    # End of Day 1

    <div class="schedule"><span>Morning ✓</span><span>Midday ✓</span><span>Evening ✓</span><span>Night ✓</span></div>
    <div class="hud"><span>MORALE: $morale</span><span>SUPPLIES: $supplies</span><span>POWER: $stationPower</span><span>DISCOVERIES: $discoveries</span></div>

    All four chronological missions are complete. Each challenge returned to its own mission hub before time advanced.

    [[Review the mission log->Mission Log]]
    (link: "Restart the mission")[(restart:)]
  TWINE
  [18, "Mission Log", "1075,750", <<~'TWINE'],
    # Mission Log

    **Location:** Buried research station, Mars  
    **Day:** $day  
    **Current stage:** $stage  
    **Mission status:** $missionStatus

    <div class="hud"><span>MORALE: $morale</span><span>SUPPLIES: $supplies</span><span>POWER: $stationPower</span><span>DISCOVERIES: $discoveries</span></div>

    **Day 1 missions:** Morning → Midday → Evening → Night.  
    Each mission has two required primary challenges and one dice-triggered depth-2 follow-up. Players choose a crew for each primary challenge; a required follow-up continues with the same crew. Every route loops back to its originating mission.

    [[Return to Day 1 summary->Day 1 Summary]]
  TWINE
  [19, "Crew Status", "1200,750", <<~'TWINE', "header"],
    (if: $crew is an array)[
    <div class="crew-status-bar">
      (if: $takeEngineer)[<div class="crew-status-card"><img class="crew-portrait" src="../images/astronaut-engineer.png" alt="Engineer portrait"><span class="crew-status-name">(verbatim-print: $engineerName)</span><span class="crew-status-role">Engineer</span><span class="stardust-score">✦ Stardust: $engineerStardust / $stardustMax</span></div>]
      (if: $takeResearcher)[<div class="crew-status-card"><img class="crew-portrait" src="../images/astronaut-researcher.png" alt="Researcher portrait"><span class="crew-status-name">(verbatim-print: $researcherName)</span><span class="crew-status-role">Researcher</span><span class="stardust-score">✦ Stardust: $researcherStardust / $stardustMax</span></div>]
      (if: $takeMedic)[<div class="crew-status-card"><img class="crew-portrait" src="../images/astronaut-medic.png" alt="Medic portrait"><span class="crew-status-name">(verbatim-print: $medicName)</span><span class="crew-status-role">Medic</span><span class="stardust-score">✦ Stardust: $medicStardust / $stardustMax</span></div>]
      (if: $takeProgramer)[<div class="crew-status-card"><img class="crew-portrait" src="../images/astronaut-programer.png" alt="Programer portrait"><span class="crew-status-name">(verbatim-print: $programerName)</span><span class="crew-status-role">Programer</span><span class="stardust-score">✦ Stardust: $programerStardust / $stardustMax</span></div>]
      (if: $takeModeler)[<div class="crew-status-card"><img class="crew-portrait" src="../images/astronaut-modeler.png" alt="Modeler portrait"><span class="crew-status-name">(verbatim-print: $modelerName)</span><span class="crew-status-role">Modeler</span><span class="stardust-score">✦ Stardust: $modelerStardust / $stardustMax</span></div>]
      (if: $takeElectrician)[<div class="crew-status-card"><img class="crew-portrait" src="../images/astronaut-electrician.png" alt="Electrician portrait"><span class="crew-status-name">(verbatim-print: $electricianName)</span><span class="crew-status-role">Electrician — AKA Sparky</span><span class="stardust-score">✦ Stardust: $electricianStardust / $stardustMax</span></div>]
      (if: $takePhysicist)[<div class="crew-status-card"><img class="crew-portrait" src="../images/astronaut-astrophysicist.png" alt="Astrophysicist portrait"><span class="crew-status-name">(verbatim-print: $physicistName)</span><span class="crew-status-role">Astrophysicist</span><span class="stardust-score">✦ Stardust: $physicistStardust / $stardustMax</span></div>]
    </div>
    ]
  TWINE
  [20, "Stardust Input", "1325,750", <<~'TWINE'],
    (set: $d6Input to "", $followupD6Input to "")
    (set: $stardustTargetRole to $challengeCrewRoles's 1st)
    <div class="stardust-input">
    **Resolve the challenge**

    (if: $usesD6Check)[
      <div class="roll-card"><strong>Challenge result</strong><span class="roll-equation">d6 roll: <strong>$roll</strong> — 1–3 is a setback, 4–5 is a success, and 6 is an exceptional success.</span></div>
    ]
    (else:)[
      <div class="roll-card"><strong>Challenge result</strong><span class="roll-equation">d20 <strong>$roll</strong> + average participating Stardust <strong>$modifier</strong> = <strong>$total</strong> against DC <strong>$dc</strong></span></div>
    ]

    **Stardust used for this check**
    <div class="stardust-roster">
      (if: $sendEngineer)[<span class="stardust-member">(verbatim-print: $engineerName): **$challengeEngineerStardust**</span>]
      (if: $sendResearcher)[<span class="stardust-member">(verbatim-print: $researcherName): **$challengeResearcherStardust**</span>]
      (if: $sendMedic)[<span class="stardust-member">(verbatim-print: $medicName): **$challengeMedicStardust**</span>]
      (if: $sendProgramer)[<span class="stardust-member">(verbatim-print: $programerName): **$challengeProgramerStardust**</span>]
      (if: $sendModeler)[<span class="stardust-member">(verbatim-print: $modelerName): **$challengeModelerStardust**</span>]
      (if: $sendElectrician)[<span class="stardust-member">(verbatim-print: $electricianName): **$challengeElectricianStardust**</span>]
      (if: $sendPhysicist)[<span class="stardust-member">(verbatim-print: $physicistName): **$challengePhysicistStardust**</span>]
    </div>

    **Step 1 — Apply the challenge's Stardust loss**

    Choose an affected participating astronaut: (cycling-link: bind $stardustTargetRole, ...$challengeCrewRoles)

    Roll a d6 in the real world and enter the result: (input: bind $d6Input, "=XX=", "1–6")

    **Challenge loss:** 1 = −5 Stardust · 2 = −3 · 3–4 = −1 · 5–6 = no loss

    (if: $stardustFollowup is not "")[
      **Step 2 — Determine whether the follow-up challenge runs**

      Roll the d6 again and enter the separate follow-up result: (input: bind $followupD6Input, "=XX=", "1–6")

      <span class="warning">This second roll does not change Stardust. A result of 1–3 requires the follow-up; 4–6 returns the crew to the mission.</span>
    ]

    (link: "Apply rolls and continue")[
      (if: not ((a: "1", "2", "3", "4", "5", "6") contains $d6Input))[
        (alert: "Enter a Stardust-loss roll from 1 to 6.")
      ]
      (else-if: $stardustFollowup is not "" and not ((a: "1", "2", "3", "4", "5", "6") contains $followupD6Input))[
        (alert: "Enter the separate follow-up roll from 1 to 6.")
      ]
      (else:)[
        (set: $d6Roll to (num: $d6Input))
        (if: $stardustFollowup is not "")[(set: $followupD6Roll to (num: $followupD6Input))]
        (if: $d6Roll is 1)[(set: $stardustChange to -5)]
        (else-if: $d6Roll is 2)[(set: $stardustChange to -3)]
        (else-if: $d6Roll <= 4)[(set: $stardustChange to -1)]
        (else:)[(set: $stardustChange to 0)]

        (if: $stardustTargetRole is "Engineer")[(set: $engineerStardust to (min: $stardustMax, (max: 0, $engineerStardust + $stardustChange)))]
        (else-if: $stardustTargetRole is "Researcher")[(set: $researcherStardust to (min: $stardustMax, (max: 0, $researcherStardust + $stardustChange)))]
        (else-if: $stardustTargetRole is "Medic")[(set: $medicStardust to (min: $stardustMax, (max: 0, $medicStardust + $stardustChange)))]
        (else-if: $stardustTargetRole is "Programer")[(set: $programerStardust to (min: $stardustMax, (max: 0, $programerStardust + $stardustChange)))]
        (else-if: $stardustTargetRole is "Modeler")[(set: $modelerStardust to (min: $stardustMax, (max: 0, $modelerStardust + $stardustChange)))]
        (else-if: $stardustTargetRole is "Electrician")[(set: $electricianStardust to (min: $stardustMax, (max: 0, $electricianStardust + $stardustChange)))]
        (else:)[(set: $physicistStardust to (min: $stardustMax, (max: 0, $physicistStardust + $stardustChange)))]
        (if: $stardustFollowup is not "" and $followupD6Roll <= 3)[
          (go-to: $stardustFollowup)
        ]
        (else:)[
          (go-to: $stardustReturn)
        ]
      ]
    ]
    </div>
  TWINE
  [21, "Apply Mission Stardust Reward", "1450,750", <<~'TWINE'],
    (if: $rewardMission is "Morning")[
      (if: $morningEngineerParticipated)[(set: $engineerStardust to (min: $stardustMax, $engineerStardust + 2))]
      (if: $morningResearcherParticipated)[(set: $researcherStardust to (min: $stardustMax, $researcherStardust + 2))]
      (if: $morningMedicParticipated)[(set: $medicStardust to (min: $stardustMax, $medicStardust + 2))]
      (if: $morningProgramerParticipated)[(set: $programerStardust to (min: $stardustMax, $programerStardust + 2))]
      (if: $morningModelerParticipated)[(set: $modelerStardust to (min: $stardustMax, $modelerStardust + 2))]
      (if: $morningElectricianParticipated)[(set: $electricianStardust to (min: $stardustMax, $electricianStardust + 2))]
      (if: $morningPhysicistParticipated)[(set: $physicistStardust to (min: $stardustMax, $physicistStardust + 2))]
      (set: $morningRewardGranted to true)
    ]
    (else-if: $rewardMission is "Midday")[
      (if: $middayEngineerParticipated)[(set: $engineerStardust to (min: $stardustMax, $engineerStardust + 2))]
      (if: $middayResearcherParticipated)[(set: $researcherStardust to (min: $stardustMax, $researcherStardust + 2))]
      (if: $middayMedicParticipated)[(set: $medicStardust to (min: $stardustMax, $medicStardust + 2))]
      (if: $middayProgramerParticipated)[(set: $programerStardust to (min: $stardustMax, $programerStardust + 2))]
      (if: $middayModelerParticipated)[(set: $modelerStardust to (min: $stardustMax, $modelerStardust + 2))]
      (if: $middayElectricianParticipated)[(set: $electricianStardust to (min: $stardustMax, $electricianStardust + 2))]
      (if: $middayPhysicistParticipated)[(set: $physicistStardust to (min: $stardustMax, $physicistStardust + 2))]
      (set: $middayRewardGranted to true)
    ]
    (else-if: $rewardMission is "Evening")[
      (if: $eveningEngineerParticipated)[(set: $engineerStardust to (min: $stardustMax, $engineerStardust + 2))]
      (if: $eveningResearcherParticipated)[(set: $researcherStardust to (min: $stardustMax, $researcherStardust + 2))]
      (if: $eveningMedicParticipated)[(set: $medicStardust to (min: $stardustMax, $medicStardust + 2))]
      (if: $eveningProgramerParticipated)[(set: $programerStardust to (min: $stardustMax, $programerStardust + 2))]
      (if: $eveningModelerParticipated)[(set: $modelerStardust to (min: $stardustMax, $modelerStardust + 2))]
      (if: $eveningElectricianParticipated)[(set: $electricianStardust to (min: $stardustMax, $electricianStardust + 2))]
      (if: $eveningPhysicistParticipated)[(set: $physicistStardust to (min: $stardustMax, $physicistStardust + 2))]
      (set: $eveningRewardGranted to true)
    ]
    (else:)[
      (if: $nightEngineerParticipated)[(set: $engineerStardust to (min: $stardustMax, $engineerStardust + 2))]
      (if: $nightResearcherParticipated)[(set: $researcherStardust to (min: $stardustMax, $researcherStardust + 2))]
      (if: $nightMedicParticipated)[(set: $medicStardust to (min: $stardustMax, $medicStardust + 2))]
      (if: $nightProgramerParticipated)[(set: $programerStardust to (min: $stardustMax, $programerStardust + 2))]
      (if: $nightModelerParticipated)[(set: $modelerStardust to (min: $stardustMax, $modelerStardust + 2))]
      (if: $nightElectricianParticipated)[(set: $electricianStardust to (min: $stardustMax, $electricianStardust + 2))]
      (if: $nightPhysicistParticipated)[(set: $physicistStardust to (min: $stardustMax, $physicistStardust + 2))]
      (set: $nightRewardGranted to true)
    ]

    <div class="quest-card"><span class="success">✦ Mission complete: every astronaut who participated in this mission gains 2 Stardust.</span></div>
  TWINE
  [22, "Morning Second Challenge", "700,875", <<~'TWINE'],
    (set: $roll to (random:1,6), $morningSecondComplete to true)
    # Challenge 1.2 — Fungal pathogen
    (display: "Challenge Crew Display")

    The soil brought from Earth contains a fungal pathogen that has infected the crops. Roll the d6 to discover what happens.

    <div class="roll-card"><strong>d6 result: $roll</strong></div>

    (if: $roll is 1)[
      (set: $supplies to (max:0,$supplies - 4))
      (if: $takeEngineer)[(set: $engineerStardust to (max:0,$engineerStardust - 3))](if: $takeResearcher)[(set: $researcherStardust to (max:0,$researcherStardust - 3))](if: $takeMedic)[(set: $medicStardust to (max:0,$medicStardust - 3))](if: $takeProgramer)[(set: $programerStardust to (max:0,$programerStardust - 3))](if: $takeModeler)[(set: $modelerStardust to (max:0,$modelerStardust - 3))](if: $takeElectrician)[(set: $electricianStardust to (max:0,$electricianStardust - 3))](if: $takePhysicist)[(set: $physicistStardust to (max:0,$physicistStardust - 3))]
      <span class="danger">All the plants die. There is no fresh food and no seed stock left to grow more. Every team member loses 3 Stardust.</span>
    ]
    (else-if: $roll <= 3)[
      (set: $supplies to (max:0,$supplies - 2))
      (if: $takeEngineer)[(set: $engineerStardust to (max:0,$engineerStardust - 2))](if: $takeResearcher)[(set: $researcherStardust to (max:0,$researcherStardust - 2))](if: $takeMedic)[(set: $medicStardust to (max:0,$medicStardust - 2))](if: $takeProgramer)[(set: $programerStardust to (max:0,$programerStardust - 2))](if: $takeModeler)[(set: $modelerStardust to (max:0,$modelerStardust - 2))](if: $takeElectrician)[(set: $electricianStardust to (max:0,$electricianStardust - 2))](if: $takePhysicist)[(set: $physicistStardust to (max:0,$physicistStardust - 2))]
      <span class="danger">All the plants die, so there is no fresh food for now. Luckily, seeds stored in a secure room can restart the crop system, although fresh food is weeks away. Every team member loses 2 Stardust.</span>
    ]
    (else-if: $roll <= 5)[
      (set: $supplies to (max:0,$supplies - 1), $leadRole to $challengeCrewRoles's 1st)
      (if: $leadRole is "Engineer")[(set: $engineerStardust to (max:0,$engineerStardust - 1))](else-if: $leadRole is "Researcher")[(set: $researcherStardust to (max:0,$researcherStardust - 1))](else-if: $leadRole is "Medic")[(set: $medicStardust to (max:0,$medicStardust - 1))](else-if: $leadRole is "Programer")[(set: $programerStardust to (max:0,$programerStardust - 1))](else-if: $leadRole is "Modeler")[(set: $modelerStardust to (max:0,$modelerStardust - 1))](else-if: $leadRole is "Electrician")[(set: $electricianStardust to (max:0,$electricianStardust - 1))](else:)[(set: $physicistStardust to (max:0,$physicistStardust - 1))]
      <span class="warning">The crew finds a fungicide before the infection kills every plant. Half the crop is lost, but it can regrow and still provides a smaller amount of fresh food. The lead astronaut loses 1 Stardust.</span>
    ]
    (else:)[
      <span class="success">The crop is resistant to the fungus, and less than 10% of the plants are damaged. No Stardust is lost.</span>
    ]

    **Challenge depth 1 of 2 — no deeper branch.**
    [[Return to the growing-food mission->Morning Mission]]
  TWINE
  [23, "Midday Second Challenge", "825,875", <<~'TWINE'],
    (set: $roll to (random:1,6), $middaySecondComplete to true, $leadRole to $challengeCrewRoles's 1st)
    # Challenge 2.2 — Solar flare
    (display: "Challenge Crew Display")

    Solar flares can occur every few days, producing dangerous radiation for around an hour. Everyone must remain inside—but you are caught outdoors when the warning sounds. Roll the d6 to see what happens.

    <div class="roll-card"><strong>d6 result: $roll</strong></div>

    (if: $roll is 1)[
      (set: $damage to 5)(display: "Apply Lead Damage")
      <span class="danger">You develop radiation sickness, and nobody finds you until the next day. Damage: 5 Stardust.</span>
    ]
    (else-if: $roll <= 3)[
      (set: $damage to 3)(display: "Apply Lead Damage")
      <span class="danger">You are exposed to radiation, but the medic reaches you and provides treatment. Damage: 3 Stardust.</span>
    ]
    (else-if: $roll <= 5)[
      (set: $damage to 1)(display: "Apply Lead Damage")
      <span class="warning">You find your radiation suit in time but still become slightly ill. Damage: 1 Stardust.</span>
    ]
    (else:)[
      <span class="success">You return to the station before dangerous radiation reaches you. Damage: 0 Stardust.</span>
    ]

    **Challenge depth 1 of 2 — no deeper branch.**
    [[Return to the station-protection mission->Midday Mission]]
  TWINE
  [24, "Evening Second Challenge", "950,875", <<~'TWINE'],
    (display: "Calculate Team Stardust")
    (set: $roll to (random:1,20), $dc to 13)
    (set: $total to $roll + $modifier, $eveningSecondComplete to true)
    # Evening challenge — Decontaminate the vents
    (display: "Challenge Crew Display")

    The chosen astronauts crawl through the ventilation network, removing spores before they reach the habitat.

    (if: $total >= $dc)[
      (set: $morale to $morale + 1)
      <span class="success">The vents are clean and the habitat is protected.</span>
    ]
    (else:)[
      (set: $supplies to (max:0,$supplies - 1))
      <span class="danger">The vents are sealed, but contaminated equipment must be discarded.</span>
    ]

    **Challenge depth 1 of 2 — no deeper branch.**
    (set: $stardustReturn to "Evening Mission", $stardustFollowup to "")
    (if: false)[[Map return->Evening Mission]]
    (display: "Stardust Input")
  TWINE
  [25, "Night Second Challenge", "1075,875", <<~'TWINE'],
    (display: "Calculate Team Stardust")
    (set: $roll to (random:1,20), $dc to 14)
    (set: $total to $roll + $modifier, $nightSecondComplete to true)
    # Night challenge — Patrol the station perimeter
    (display: "Challenge Crew Display")

    The chosen astronauts cross the dark Martian surface to inspect the station's exterior sensors and airlocks.

    (if: $total >= $dc)[
      (set: $stationPower to $stationPower + 1)
      <span class="success">The patrol restores an exterior sensor array and finds no breach.</span>
    ]
    (else:)[
      (set: $morale to (max:0,$morale - 1))
      <span class="danger">A dust surge separates the patrol briefly before they regain the airlock.</span>
    ]

    **Challenge depth 1 of 2 — no deeper branch.**
    (set: $stardustReturn to "Night Mission", $stardustFollowup to "")
    (if: false)[[Map return->Night Mission]]
    (display: "Stardust Input")
  TWINE
  [26, "Select Challenge Crew", "1200,875", <<~'TWINE'],
    (set: $sendEngineer to false, $sendResearcher to false, $sendMedic to false, $sendProgramer to false)
    (set: $sendModeler to false, $sendElectrician to false, $sendPhysicist to false)
    # Choose the challenge crew

    **Challenge:** (verbatim-print: $challengeTitle)

    Select any subset of the available mission roster. The challenge modifier is the participating astronauts' average current Stardust, so the score reflects how well that crew is doing individually. Only participants receive the challenge's Stardust effects.

    (if: $takeEngineer)[(checkbox: bind $sendEngineer, "Engineer") — (verbatim-print: $engineerName)<br>]
    (if: $takeResearcher)[(checkbox: bind $sendResearcher, "Researcher") — (verbatim-print: $researcherName)<br>]
    (if: $takeMedic)[(checkbox: bind $sendMedic, "Medic") — (verbatim-print: $medicName)<br>]
    (if: $takeProgramer)[(checkbox: bind $sendProgramer, "Programer") — (verbatim-print: $programerName)<br>]
    (if: $takeModeler)[(checkbox: bind $sendModeler, "Modeler") — (verbatim-print: $modelerName)<br>]
    (if: $takeElectrician)[(checkbox: bind $sendElectrician, "Electrician") — (verbatim-print: $electricianName)<br>]
    (if: $takePhysicist)[(checkbox: bind $sendPhysicist, "Astrophysicist") — (verbatim-print: $physicistName)<br>]

    (link: "Send this crew")[
      (set: $challengeCrewCount to 0, $challengeCrewNames to (a:), $challengeCrewRoles to (a:))
      (if: $sendEngineer)[(set: $challengeCrewCount to $challengeCrewCount + 1, $challengeCrewNames to $challengeCrewNames + (a:$engineerName), $challengeCrewRoles to $challengeCrewRoles + (a:"Engineer"))]
      (if: $sendResearcher)[(set: $challengeCrewCount to $challengeCrewCount + 1, $challengeCrewNames to $challengeCrewNames + (a:$researcherName), $challengeCrewRoles to $challengeCrewRoles + (a:"Researcher"))]
      (if: $sendMedic)[(set: $challengeCrewCount to $challengeCrewCount + 1, $challengeCrewNames to $challengeCrewNames + (a:$medicName), $challengeCrewRoles to $challengeCrewRoles + (a:"Medic"))]
      (if: $sendProgramer)[(set: $challengeCrewCount to $challengeCrewCount + 1, $challengeCrewNames to $challengeCrewNames + (a:$programerName), $challengeCrewRoles to $challengeCrewRoles + (a:"Programer"))]
      (if: $sendModeler)[(set: $challengeCrewCount to $challengeCrewCount + 1, $challengeCrewNames to $challengeCrewNames + (a:$modelerName), $challengeCrewRoles to $challengeCrewRoles + (a:"Modeler"))]
      (if: $sendElectrician)[(set: $challengeCrewCount to $challengeCrewCount + 1, $challengeCrewNames to $challengeCrewNames + (a:$electricianName), $challengeCrewRoles to $challengeCrewRoles + (a:"Electrician"))]
      (if: $sendPhysicist)[(set: $challengeCrewCount to $challengeCrewCount + 1, $challengeCrewNames to $challengeCrewNames + (a:$physicistName), $challengeCrewRoles to $challengeCrewRoles + (a:"Astrophysicist"))]

      (if: $challengeCrewCount > 0)[
        (display: "Record Mission Participants")
        (go-to: $challengeDestination)
      ]
      (else:)[(alert: "Select at least one astronaut for this challenge.")]
    ]
  TWINE
  [27, "Challenge Crew Display", "1325,875", <<~'TWINE'],
    <div class="quest-card"><strong>PARTICIPATING CREW:</strong>(for: each _challengeName, ...$challengeCrewNames)[<span class="challenge-name">(verbatim-print: _challengeName)</span>]</div>
  TWINE
  [28, "Calculate Team Stardust", "1450,875", <<~'TWINE'],
    (set: $usesD6Check to false)
    (set: $challengeEngineerStardust to $engineerStardust, $challengeResearcherStardust to $researcherStardust)
    (set: $challengeMedicStardust to $medicStardust, $challengeProgramerStardust to $programerStardust)
    (set: $challengeModelerStardust to $modelerStardust, $challengeElectricianStardust to $electricianStardust)
    (set: $challengePhysicistStardust to $physicistStardust)
    (set: $challengeStardustTotal to 0)
    (if: $sendEngineer)[(set: $challengeStardustTotal to $challengeStardustTotal + $challengeEngineerStardust)]
    (if: $sendResearcher)[(set: $challengeStardustTotal to $challengeStardustTotal + $challengeResearcherStardust)]
    (if: $sendMedic)[(set: $challengeStardustTotal to $challengeStardustTotal + $challengeMedicStardust)]
    (if: $sendProgramer)[(set: $challengeStardustTotal to $challengeStardustTotal + $challengeProgramerStardust)]
    (if: $sendModeler)[(set: $challengeStardustTotal to $challengeStardustTotal + $challengeModelerStardust)]
    (if: $sendElectrician)[(set: $challengeStardustTotal to $challengeStardustTotal + $challengeElectricianStardust)]
    (if: $sendPhysicist)[(set: $challengeStardustTotal to $challengeStardustTotal + $challengePhysicistStardust)]
    (if: $challengeCrewCount > 0)[(set: $modifier to (floor: $challengeStardustTotal / $challengeCrewCount))]
    (else:)[(set: $modifier to 0)]
  TWINE
  [29, "Record Mission Participants", "1575,875", <<~'TWINE'],
    (if: $challengeMission is "Morning")[
      (if: $sendEngineer)[(set: $morningEngineerParticipated to true)]
      (if: $sendResearcher)[(set: $morningResearcherParticipated to true)]
      (if: $sendMedic)[(set: $morningMedicParticipated to true)]
      (if: $sendProgramer)[(set: $morningProgramerParticipated to true)]
      (if: $sendModeler)[(set: $morningModelerParticipated to true)]
      (if: $sendElectrician)[(set: $morningElectricianParticipated to true)]
      (if: $sendPhysicist)[(set: $morningPhysicistParticipated to true)]
    ]
    (else-if: $challengeMission is "Midday")[
      (if: $sendEngineer)[(set: $middayEngineerParticipated to true)]
      (if: $sendResearcher)[(set: $middayResearcherParticipated to true)]
      (if: $sendMedic)[(set: $middayMedicParticipated to true)]
      (if: $sendProgramer)[(set: $middayProgramerParticipated to true)]
      (if: $sendModeler)[(set: $middayModelerParticipated to true)]
      (if: $sendElectrician)[(set: $middayElectricianParticipated to true)]
      (if: $sendPhysicist)[(set: $middayPhysicistParticipated to true)]
    ]
    (else-if: $challengeMission is "Evening")[
      (if: $sendEngineer)[(set: $eveningEngineerParticipated to true)]
      (if: $sendResearcher)[(set: $eveningResearcherParticipated to true)]
      (if: $sendMedic)[(set: $eveningMedicParticipated to true)]
      (if: $sendProgramer)[(set: $eveningProgramerParticipated to true)]
      (if: $sendModeler)[(set: $eveningModelerParticipated to true)]
      (if: $sendElectrician)[(set: $eveningElectricianParticipated to true)]
      (if: $sendPhysicist)[(set: $eveningPhysicistParticipated to true)]
    ]
    (else:)[
      (if: $sendEngineer)[(set: $nightEngineerParticipated to true)]
      (if: $sendResearcher)[(set: $nightResearcherParticipated to true)]
      (if: $sendMedic)[(set: $nightMedicParticipated to true)]
      (if: $sendProgramer)[(set: $nightProgramerParticipated to true)]
      (if: $sendModeler)[(set: $nightModelerParticipated to true)]
      (if: $sendElectrician)[(set: $nightElectricianParticipated to true)]
      (if: $sendPhysicist)[(set: $nightPhysicistParticipated to true)]
    ]
  TWINE
  [30, "Apply Lead Damage", "1700,875", <<~'TWINE'],
    (if: $leadRole is "Engineer")[(set: $engineerStardust to (max:0,$engineerStardust - $damage))]
    (else-if: $leadRole is "Researcher")[(set: $researcherStardust to (max:0,$researcherStardust - $damage))]
    (else-if: $leadRole is "Medic")[(set: $medicStardust to (max:0,$medicStardust - $damage))]
    (else-if: $leadRole is "Programer")[(set: $programerStardust to (max:0,$programerStardust - $damage))]
    (else-if: $leadRole is "Modeler")[(set: $modelerStardust to (max:0,$modelerStardust - $damage))]
    (else-if: $leadRole is "Electrician")[(set: $electricianStardust to (max:0,$electricianStardust - $damage))]
    (else:)[(set: $physicistStardust to (max:0,$physicistStardust - $damage))]
  TWINE
]

html = File.read(story_path)
existing_positions = html.scan(/<tw-passagedata\b([^>]*)>/).each_with_object({}) do |(attributes), positions|
  name = CGI.unescapeHTML(attributes[/\bname="([^"]*)"/, 1].to_s)
  position = attributes[/\bposition="([^"]*)"/, 1]
  positions[name] = position if position
end

passage_html = passages.map do |pid, name, position, source, tags|
  position = existing_positions.fetch(name, position)
  local_source = source.rstrip.gsub("../images/", "#{local_image_base}/")
  %(<tw-passagedata pid="#{pid}" name="#{CGI.escapeHTML(name)}" tags="#{CGI.escapeHTML(tags || "")}" position="#{position}" size="100,100">#{CGI.escapeHTML(local_source)}</tw-passagedata>)
end.join

storydata = %(<tw-storydata name="testing" startnode="1" creator="Twine" creator-version="2.12.1" format="Harlowe" format-version="3.3.9" ifid="10515CCC-3933-4FCB-9F91-389CAD821D22" options="" tags="" zoom="1" hidden><style role="stylesheet" id="twine-user-stylesheet" type="text/twine-css">#{css}</style><script role="script" id="twine-user-script" type="text/twine-javascript"></script>#{passage_html}</tw-storydata>)

unless html.sub!(/<tw-storydata\b.*?<\/tw-storydata>/m, storydata)
  abort "Could not find the Twine story data block"
end

File.write(story_path, html)
puts "Built #{passages.length} passages into #{story_path}"

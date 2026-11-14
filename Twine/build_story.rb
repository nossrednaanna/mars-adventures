#!/usr/bin/env ruby

require "cgi"

story_path = File.join(__dir__, "Stories", "testing.html")
image_directory = File.expand_path("images", __dir__)
local_image_base = "file://#{image_directory.gsub(" ", "%20")}" 

css = <<~CSS
  tw-story { background: #050914; color: #f5f7ff; font-family: system-ui, sans-serif; }
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
    (set: $day to 1, $stage to "Morning", $missionStatus to "Station operations")
    (set: $morningComplete to ($morningFirstComplete and $morningSecondComplete))
    # Mission 1 — Morning

    <div class="schedule"><span class="current">Morning</span><span>Midday</span><span>Evening</span><span>Night</span></div>
    <div class="hud"><span>MORALE: $morale</span><span>SUPPLIES: $supplies</span><span>POWER: $stationPower</span><span>DISCOVERIES: $discoveries</span></div>

    All selected astronauts assemble in the entrance module. The morning mission is to restore life support and make the station safe enough to occupy.

    (if: not $morningFirstComplete)[<div class="action-link">(link: "Choose a crew for life-support restoration")[(set: $challengeDestination to "Morning Challenge", $challengeTitle to "Restore life support")(go-to: "Select Challenge Crew")]</div>]
    (if: false)[[Map route: life support->Morning Challenge]]
    (if: not $morningSecondComplete)[<div class="action-link">(link: "Choose a crew for the water-recycler repair")[(set: $challengeDestination to "Morning Second Challenge", $challengeTitle to "Repair the water recycler")(go-to: "Select Challenge Crew")]</div>]
    (if: false)[[Map route: water recycler->Morning Second Challenge]]
    (if: $morningComplete)[
      <div class="quest-card"><span class="success">Morning mission complete.</span> The team has returned to the mission hub.</div>
      [[Advance in time to the midday mission->Midday Mission]]
    ]
  TWINE
  [6, "Morning Challenge", "825,500", <<~'TWINE'],
    (set: $roll to (random:1,20), $modifier to (max:1,$challengeCrewCount), $dc to 12)
    (set: $total to $roll + $modifier, $morningFirstComplete to true)
    # Morning challenge — Restore life support
    (display: "Challenge Crew Display")

    The whole team works through frozen ducts, damaged controls, and emergency medical checks.

    <div class="roll-card">**Team check**<br>d20 **$roll** + teamwork **$modifier** = **$total** against DC **$dc**</div>

    (if: $total >= $dc)[
      (set: $stationPower to $stationPower + 2)
      <span class="success">Life support stabilizes and two station sectors receive power.</span>
      (set: $teamStardustChange to 1, $teamStardustReason to "Life support is restored safely. Every participating astronaut gains 1 Stardust.")
      (display: "Apply Team Stardust")
    ]
    (else:)[
      (set: $stationPower to $stationPower + 1, $supplies to (max:0,$supplies - 1))
      <span class="warning">The system runs at minimum capacity and consumes one supply unit.</span>
      (set: $teamStardustChange to -1, $teamStardustReason to "The dangerous repair exhausts the crew. Every participating astronaut loses 1 Stardust.")
      (display: "Apply Team Stardust")
    ]

    **Challenge depth 1 of 2**

    (set: $stardustReturn to "Morning Mission", $stardustFollowup to "Morning Follow-up")
    (if: false)[[Map return->Morning Mission]]
    (if: false)[[Map follow-up->Morning Follow-up]]
    (display: "Stardust Input")
  TWINE
  [7, "Morning Follow-up", "950,500", <<~'TWINE'],
    (set: $roll to (random:1,20), $modifier to $challengeCrewCount + $stationPower, $dc to 13)
    (set: $total to $roll + $modifier, $morningDeepComplete to true)
    # Morning follow-up — Trace the surge
    (display: "Challenge Crew Display")

    The astronauts follow the surge below the power room. This is the deepest branch of the morning mission.

    <div class="roll-card">**Team check**<br>d20 **$roll** + systems **$modifier** = **$total** against DC **$dc**</div>

    (if: $total >= $dc)[
      (set: $discoveries to $discoveries + 1)
      <span class="success">The team finds a hidden power conduit descending beneath the station.</span>
      (set: $teamStardustChange to 1, $teamStardustReason to "The discovery renews the team. Every participating astronaut gains 1 Stardust.")
      (display: "Apply Team Stardust")
    ]
    (else:)[
      (set: $morale to (max:0,$morale - 1))
      <span class="warning">The surge disappears before it can be traced. Morale falls.</span>
      (set: $teamStardustChange to -1, $teamStardustReason to "The failed search drains the team. Every participating astronaut loses 1 Stardust.")
      (display: "Apply Team Stardust")
    ]

    **Challenge depth 2 of 2 — no deeper challenge links.**

    (set: $stardustReturn to "Morning Mission", $stardustFollowup to "")
    (if: false)[[Map return->Morning Mission]]
    (display: "Stardust Input")
  TWINE
  [8, "Midday Mission", "1075,500", <<~'TWINE'],
    (set: $stage to "Midday")
    (set: $middayComplete to ($middayFirstComplete and $middaySecondComplete))
    # Mission 2 — Midday

    <div class="schedule"><span>Morning</span><span class="current">Midday</span><span>Evening</span><span>Night</span></div>
    <div class="hud"><span>MORALE: $morale</span><span>SUPPLIES: $supplies</span><span>POWER: $stationPower</span><span>DISCOVERIES: $discoveries</span></div>

    The full team begins a survey of the station's unexplored central level.

    (if: not $middayFirstComplete)[<div class="action-link">(link: "Choose a crew for the central-level survey")[(set: $challengeDestination to "Midday Challenge", $challengeTitle to "Survey the central level")(go-to: "Select Challenge Crew")]</div>]
    (if: false)[[Map route: central survey->Midday Challenge]]
    (if: not $middaySecondComplete)[<div class="action-link">(link: "Choose a crew to inspect the sealed laboratory")[(set: $challengeDestination to "Midday Second Challenge", $challengeTitle to "Inspect the sealed laboratory")(go-to: "Select Challenge Crew")]</div>]
    (if: false)[[Map route: sealed laboratory->Midday Second Challenge]]
    (if: $middayComplete)[
      <div class="quest-card"><span class="success">Midday mission complete.</span> The team has returned to the mission hub.</div>
      [[Advance in time to the evening mission->Evening Mission]]
    ]
  TWINE
  [9, "Midday Challenge", "1200,500", <<~'TWINE'],
    (set: $roll to (random:1,20), $modifier to (max:1,$challengeCrewCount), $dc to 13)
    (set: $total to $roll + $modifier, $middayFirstComplete to true)
    # Midday challenge — Survey the central level
    (display: "Challenge Crew Display")

    Together, the astronauts map unstable corridors, test the air, and recover fragments from the station archive.

    <div class="roll-card">**Team check**<br>d20 **$roll** + teamwork **$modifier** = **$total** against DC **$dc**</div>

    (if: $total >= $dc)[
      (set: $discoveries to $discoveries + 1)
      <span class="success">The survey reveals a sealed laboratory and a partial map.</span>
      (set: $teamStardustChange to 1, $teamStardustReason to "The successful survey inspires the team. Every participating astronaut gains 1 Stardust.")
      (display: "Apply Team Stardust")
    ]
    (else:)[
      (set: $supplies to (max:0,$supplies - 1))
      <span class="warning">A corridor collapse costs one supply unit, but the team completes the survey.</span>
      (set: $teamStardustChange to -1, $teamStardustReason to "The corridor collapse injures and exhausts the team. Every participating astronaut loses 1 Stardust.")
      (display: "Apply Team Stardust")
    ]

    **Challenge depth 1 of 2**

    (set: $stardustReturn to "Midday Mission", $stardustFollowup to "Midday Follow-up")
    (if: false)[[Map return->Midday Mission]]
    (if: false)[[Map follow-up->Midday Follow-up]]
    (display: "Stardust Input")
  TWINE
  [10, "Midday Follow-up", "1325,500", <<~'TWINE'],
    (set: $roll to (random:1,20), $modifier to $challengeCrewCount + $discoveries, $dc to 14)
    (set: $total to $roll + $modifier, $middayDeepComplete to true)
    # Midday follow-up — Decode the map
    (display: "Challenge Crew Display")

    The team combines every discipline to reconstruct the damaged station plan.

    <div class="roll-card">**Team check**<br>d20 **$roll** + research **$modifier** = **$total** against DC **$dc**</div>

    (if: $total >= $dc)[
      (set: $discoveries to $discoveries + 1)
      <span class="success">The map identifies a greenhouse and a deeper chamber with no recorded purpose.</span>
      (set: $teamStardustChange to 1, $teamStardustReason to "Solving the map restores confidence. Every participating astronaut gains 1 Stardust.")
      (display: "Apply Team Stardust")
    ]
    (else:)[
      <span class="warning">The map remains incomplete, but its greenhouse marker is readable.</span>
      (set: $teamStardustChange to -1, $teamStardustReason to "The long, unsuccessful analysis is draining. Every participating astronaut loses 1 Stardust.")
      (display: "Apply Team Stardust")
    ]

    **Challenge depth 2 of 2 — no deeper challenge links.**

    (set: $stardustReturn to "Midday Mission", $stardustFollowup to "")
    (if: false)[[Map return->Midday Mission]]
    (display: "Stardust Input")
  TWINE
  [11, "Evening Mission", "700,625", <<~'TWINE'],
    (set: $stage to "Evening")
    (set: $eveningComplete to ($eveningFirstComplete and $eveningSecondComplete))
    # Mission 3 — Evening

    <div class="schedule"><span>Morning</span><span>Midday</span><span class="current">Evening</span><span>Night</span></div>
    <div class="hud"><span>MORALE: $morale</span><span>SUPPLIES: $supplies</span><span>POWER: $stationPower</span><span>DISCOVERIES: $discoveries</span></div>

    An alarm calls the entire team to the greenhouse. Unknown growth is spreading into the ventilation system.

    (if: not $eveningFirstComplete)[<div class="action-link">(link: "Choose a crew for organism containment")[(set: $challengeDestination to "Evening Challenge", $challengeTitle to "Contain the growth")(go-to: "Select Challenge Crew")]</div>]
    (if: false)[[Map route: organism containment->Evening Challenge]]
    (if: not $eveningSecondComplete)[<div class="action-link">(link: "Choose a crew to decontaminate the vents")[(set: $challengeDestination to "Evening Second Challenge", $challengeTitle to "Decontaminate the ventilation system")(go-to: "Select Challenge Crew")]</div>]
    (if: false)[[Map route: decontaminate vents->Evening Second Challenge]]
    (if: $eveningComplete)[
      <div class="quest-card"><span class="success">Evening mission complete.</span> The team has returned to the mission hub.</div>
      [[Advance in time to the night mission->Night Mission]]
    ]
  TWINE
  [12, "Evening Challenge", "825,625", <<~'TWINE'],
    (set: $roll to (random:1,20), $modifier to (max:1,$challengeCrewCount), $dc to 12)
    (set: $total to $roll + $modifier, $eveningFirstComplete to true)
    # Evening challenge — Contain the growth
    (display: "Challenge Crew Display")

    Every astronaut contributes: sealing vents, monitoring health, analyzing the organism, and controlling the greenhouse systems.

    <div class="roll-card">**Team check**<br>d20 **$roll** + teamwork **$modifier** = **$total** against DC **$dc**</div>

    (if: $total >= $dc)[
      (set: $discoveries to $discoveries + 1)
      <span class="success">The growth is contained and a viable sample is secured.</span>
      (set: $teamStardustChange to 1, $teamStardustReason to "Safe containment strengthens the crew. Every participating astronaut gains 1 Stardust.")
      (display: "Apply Team Stardust")
    ]
    (else:)[
      (set: $supplies to (max:0,$supplies - 1), $morale to (max:0,$morale - 1))
      <span class="danger">The greenhouse is sealed permanently and the team loses supplies.</span>
      (set: $teamStardustChange to -2, $teamStardustReason to "Exposure during the failed containment harms the crew. Every participating astronaut loses 2 Stardust.")
      (display: "Apply Team Stardust")
    ]

    **Challenge depth 1 of 2**

    (set: $stardustReturn to "Evening Mission", $stardustFollowup to "Evening Follow-up")
    (if: false)[[Map return->Evening Mission]]
    (if: false)[[Map follow-up->Evening Follow-up]]
    (display: "Stardust Input")
  TWINE
  [13, "Evening Follow-up", "950,625", <<~'TWINE'],
    (set: $roll to (random:1,20), $modifier to $challengeCrewCount + $discoveries, $dc to 14)
    (set: $total to $roll + $modifier, $eveningDeepComplete to true)
    # Evening follow-up — Analyze the organism
    (display: "Challenge Crew Display")

    The full team conducts a rapid laboratory analysis before the sample degrades.

    <div class="roll-card">**Team check**<br>d20 **$roll** + research **$modifier** = **$total** against DC **$dc**</div>

    (if: $total >= $dc)[
      (set: $discoveries to $discoveries + 1)
      <span class="success">The organism is neither terrestrial nor Martian. It responds to the station's hidden signal.</span>
      (set: $teamStardustChange to 1, $teamStardustReason to "The breakthrough energizes the team. Every participating astronaut gains 1 Stardust.")
      (display: "Apply Team Stardust")
    ]
    (else:)[
      <span class="warning">The sample degrades before its origin can be confirmed.</span>
      (set: $teamStardustChange to -1, $teamStardustReason to "The lost sample leaves the crew depleted. Every participating astronaut loses 1 Stardust.")
      (display: "Apply Team Stardust")
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

    (if: not $nightFirstComplete)[<div class="action-link">(link: "Choose a crew to secure the habitat")[(set: $challengeDestination to "Night Challenge", $challengeTitle to "Secure the habitat")(go-to: "Select Challenge Crew")]</div>]
    (if: false)[[Map route: secure habitat->Night Challenge]]
    (if: not $nightSecondComplete)[<div class="action-link">(link: "Choose a crew for the perimeter patrol")[(set: $challengeDestination to "Night Second Challenge", $challengeTitle to "Patrol the station perimeter")(go-to: "Select Challenge Crew")]</div>]
    (if: false)[[Map route: perimeter patrol->Night Second Challenge]]
    (if: $nightComplete)[
      <div class="quest-card"><span class="success">Night mission complete.</span> The team has returned to the mission hub.</div>
      [[End Day 1->Day 1 Summary]]
    ]
  TWINE
  [15, "Night Challenge", "1200,625", <<~'TWINE'],
    (set: $roll to (random:1,20), $modifier to (max:1,$challengeCrewCount), $dc to 12)
    (set: $total to $roll + $modifier, $nightFirstComplete to true)
    # Night challenge — Secure the habitat
    (display: "Challenge Crew Display")

    The astronauts check seals, medical status, sensors, and power reserves as one team.

    <div class="roll-card">**Team check**<br>d20 **$roll** + teamwork **$modifier** = **$total** against DC **$dc**</div>

    (if: $total >= $dc)[
      (set: $morale to $morale + 1)
      <span class="success">The habitat is secure and the crew gains morale.</span>
      (set: $teamStardustChange to 1, $teamStardustReason to "A secure habitat lets the team recover. Every participating astronaut gains 1 Stardust.")
      (display: "Apply Team Stardust")
    ]
    (else:)[
      (set: $supplies to (max:0,$supplies - 1))
      <span class="warning">A failing seal consumes one supply unit before it is stabilized.</span>
      (set: $teamStardustChange to -1, $teamStardustReason to "The emergency seal repair exhausts the crew. Every participating astronaut loses 1 Stardust.")
      (display: "Apply Team Stardust")
    ]

    **Challenge depth 1 of 2**

    (set: $stardustReturn to "Night Mission", $stardustFollowup to "Night Follow-up")
    (if: false)[[Map return->Night Mission]]
    (if: false)[[Map follow-up->Night Follow-up]]
    (display: "Stardust Input")
  TWINE
  [16, "Night Follow-up", "1325,625", <<~'TWINE'],
    (set: $roll to (random:1,20), $modifier to $challengeCrewCount + $discoveries, $dc to 15)
    (set: $total to $roll + $modifier, $nightDeepComplete to true)
    # Night follow-up — The signal below
    (display: "Challenge Crew Display")

    The team descends one level and listens as the vibration resolves into a repeating coded signal.

    <div class="roll-card">**Team check**<br>d20 **$roll** + accumulated knowledge **$modifier** = **$total** against DC **$dc**</div>

    (if: $total >= $dc)[
      (set: $discoveries to $discoveries + 2)
      <span class="success">The signal is a response. Something below knows the astronauts have arrived.</span>
      (set: $teamStardustChange to 2, $teamStardustReason to "The extraordinary discovery fills the crew with resolve. Every participating astronaut gains 2 Stardust.")
      (display: "Apply Team Stardust")
    ]
    (else:)[
      (set: $morale to (max:0,$morale - 1))
      <span class="danger">The signal stops when the team approaches. Morale falls.</span>
      (set: $teamStardustChange to -2, $teamStardustReason to "The unsettling encounter shakes the crew. Every participating astronaut loses 2 Stardust.")
      (display: "Apply Team Stardust")
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
    (set: $d6Input to "")
    (set: $stardustTargetRole to $challengeCrewRoles's 1st)
    <div class="stardust-input">
    **Resolve Stardust with your physical d6**

    Choose an affected participating astronaut: (cycling-link: bind $stardustTargetRole, ...$challengeCrewRoles)

    Roll a d6 in the real world and enter the result: (input: bind $d6Input, "=XX=", "1–6")

    (if: $stardustFollowup is not "")[
      <span class="warning">A roll of 1–3 requires the follow-up challenge. A roll of 4–6 returns the crew to the mission.</span>
    ]

    (link: "Apply roll and continue")[
      (if: (a: "1", "2", "3", "4", "5", "6") contains $d6Input)[
        (set: $d6Roll to (num: $d6Input))
        (if: $d6Roll is 1)[(set: $stardustChange to -3)]
        (else-if: $d6Roll is 2)[(set: $stardustChange to -2)]
        (else-if: $d6Roll is 3)[(set: $stardustChange to -1)]
        (else-if: $d6Roll is 4)[(set: $stardustChange to 1)]
        (else-if: $d6Roll is 5)[(set: $stardustChange to 2)]
        (else:)[(set: $stardustChange to 3)]

        (if: $stardustTargetRole is "Engineer")[(set: $engineerStardust to (min: $stardustMax, (max: 0, $engineerStardust + $stardustChange)))]
        (else-if: $stardustTargetRole is "Researcher")[(set: $researcherStardust to (min: $stardustMax, (max: 0, $researcherStardust + $stardustChange)))]
        (else-if: $stardustTargetRole is "Medic")[(set: $medicStardust to (min: $stardustMax, (max: 0, $medicStardust + $stardustChange)))]
        (else-if: $stardustTargetRole is "Programer")[(set: $programerStardust to (min: $stardustMax, (max: 0, $programerStardust + $stardustChange)))]
        (else-if: $stardustTargetRole is "Modeler")[(set: $modelerStardust to (min: $stardustMax, (max: 0, $modelerStardust + $stardustChange)))]
        (else-if: $stardustTargetRole is "Electrician")[(set: $electricianStardust to (min: $stardustMax, (max: 0, $electricianStardust + $stardustChange)))]
        (else:)[(set: $physicistStardust to (min: $stardustMax, (max: 0, $physicistStardust + $stardustChange)))]
        (if: $stardustFollowup is not "" and $d6Roll <= 3)[
          (go-to: $stardustFollowup)
        ]
        (else:)[
          (go-to: $stardustReturn)
        ]
      ]
      (else:)[(alert: "Enter a whole number from 1 to 6.")]
    ]
    </div>
  TWINE
  [21, "Apply Team Stardust", "1450,750", <<~'TWINE'],
    (if: $sendEngineer)[(set: $engineerStardust to (min: $stardustMax, (max: 0, $engineerStardust + $teamStardustChange)))]
    (if: $sendResearcher)[(set: $researcherStardust to (min: $stardustMax, (max: 0, $researcherStardust + $teamStardustChange)))]
    (if: $sendMedic)[(set: $medicStardust to (min: $stardustMax, (max: 0, $medicStardust + $teamStardustChange)))]
    (if: $sendProgramer)[(set: $programerStardust to (min: $stardustMax, (max: 0, $programerStardust + $teamStardustChange)))]
    (if: $sendModeler)[(set: $modelerStardust to (min: $stardustMax, (max: 0, $modelerStardust + $teamStardustChange)))]
    (if: $sendElectrician)[(set: $electricianStardust to (min: $stardustMax, (max: 0, $electricianStardust + $teamStardustChange)))]
    (if: $sendPhysicist)[(set: $physicistStardust to (min: $stardustMax, (max: 0, $physicistStardust + $teamStardustChange)))]

    <div class="quest-card">
    (if: $teamStardustChange > 0)[<span class="success">✦ (print: $teamStardustReason)</span>]
    (else:)[<span class="danger">✦ (print: $teamStardustReason)</span>]
    </div>
  TWINE
  [22, "Morning Second Challenge", "700,875", <<~'TWINE'],
    (set: $roll to (random:1,20), $modifier to (max:1,$challengeCrewCount), $dc to 13)
    (set: $total to $roll + $modifier, $morningSecondComplete to true)
    # Morning challenge — Repair the water recycler
    (display: "Challenge Crew Display")

    The chosen astronauts enter the frozen utility bay to restart the station's damaged water recycler.

    <div class="roll-card">**Crew check**<br>d20 **$roll** + participating crew **$modifier** = **$total** against DC **$dc**</div>

    (if: $total >= $dc)[
      (set: $supplies to $supplies + 1)
      <span class="success">Clean water begins flowing and the station gains one supply.</span>
      (set: $teamStardustChange to 1, $teamStardustReason to "The successful repair restores the participants. Every participating astronaut gains 1 Stardust.")
      (display: "Apply Team Stardust")
    ]
    (else:)[
      (set: $supplies to (max:0,$supplies - 1))
      <span class="warning">The recycler works, but a coolant leak costs one supply.</span>
      (set: $teamStardustChange to -1, $teamStardustReason to "The coolant leak exhausts the participants. Every participating astronaut loses 1 Stardust.")
      (display: "Apply Team Stardust")
    ]

    **Challenge depth 1 of 2 — no deeper branch.**
    (set: $stardustReturn to "Morning Mission", $stardustFollowup to "")
    (if: false)[[Map return->Morning Mission]]
    (display: "Stardust Input")
  TWINE
  [23, "Midday Second Challenge", "825,875", <<~'TWINE'],
    (set: $roll to (random:1,20), $modifier to (max:1,$challengeCrewCount), $dc to 14)
    (set: $total to $roll + $modifier, $middaySecondComplete to true)
    # Midday challenge — Inspect the sealed laboratory
    (display: "Challenge Crew Display")

    The chosen astronauts breach the laboratory carefully and catalogue its unstable equipment.

    <div class="roll-card">**Crew check**<br>d20 **$roll** + participating crew **$modifier** = **$total** against DC **$dc**</div>

    (if: $total >= $dc)[
      (set: $discoveries to $discoveries + 1)
      <span class="success">The team recovers an intact experiment log.</span>
      (set: $teamStardustChange to 1, $teamStardustReason to "The recovered log encourages the participants. Every participating astronaut gains 1 Stardust.")
      (display: "Apply Team Stardust")
    ]
    (else:)[
      <span class="warning">A chemical alarm forces a hurried retreat after the inspection.</span>
      (set: $teamStardustChange to -1, $teamStardustReason to "The chemical exposure weakens the participants. Every participating astronaut loses 1 Stardust.")
      (display: "Apply Team Stardust")
    ]

    **Challenge depth 1 of 2 — no deeper branch.**
    (set: $stardustReturn to "Midday Mission", $stardustFollowup to "")
    (if: false)[[Map return->Midday Mission]]
    (display: "Stardust Input")
  TWINE
  [24, "Evening Second Challenge", "950,875", <<~'TWINE'],
    (set: $roll to (random:1,20), $modifier to (max:1,$challengeCrewCount), $dc to 13)
    (set: $total to $roll + $modifier, $eveningSecondComplete to true)
    # Evening challenge — Decontaminate the vents
    (display: "Challenge Crew Display")

    The chosen astronauts crawl through the ventilation network, removing spores before they reach the habitat.

    <div class="roll-card">**Crew check**<br>d20 **$roll** + participating crew **$modifier** = **$total** against DC **$dc**</div>

    (if: $total >= $dc)[
      (set: $morale to $morale + 1)
      <span class="success">The vents are clean and the habitat is protected.</span>
      (set: $teamStardustChange to 1, $teamStardustReason to "Completing the decontamination strengthens the participants. Every participating astronaut gains 1 Stardust.")
      (display: "Apply Team Stardust")
    ]
    (else:)[
      (set: $supplies to (max:0,$supplies - 1))
      <span class="danger">The vents are sealed, but contaminated equipment must be discarded.</span>
      (set: $teamStardustChange to -2, $teamStardustReason to "The contamination harms the participants. Every participating astronaut loses 2 Stardust.")
      (display: "Apply Team Stardust")
    ]

    **Challenge depth 1 of 2 — no deeper branch.**
    (set: $stardustReturn to "Evening Mission", $stardustFollowup to "")
    (if: false)[[Map return->Evening Mission]]
    (display: "Stardust Input")
  TWINE
  [25, "Night Second Challenge", "1075,875", <<~'TWINE'],
    (set: $roll to (random:1,20), $modifier to (max:1,$challengeCrewCount), $dc to 14)
    (set: $total to $roll + $modifier, $nightSecondComplete to true)
    # Night challenge — Patrol the station perimeter
    (display: "Challenge Crew Display")

    The chosen astronauts cross the dark Martian surface to inspect the station's exterior sensors and airlocks.

    <div class="roll-card">**Crew check**<br>d20 **$roll** + participating crew **$modifier** = **$total** against DC **$dc**</div>

    (if: $total >= $dc)[
      (set: $stationPower to $stationPower + 1)
      <span class="success">The patrol restores an exterior sensor array and finds no breach.</span>
      (set: $teamStardustChange to 1, $teamStardustReason to "The safe patrol reassures the participants. Every participating astronaut gains 1 Stardust.")
      (display: "Apply Team Stardust")
    ]
    (else:)[
      (set: $morale to (max:0,$morale - 1))
      <span class="danger">A dust surge separates the patrol briefly before they regain the airlock.</span>
      (set: $teamStardustChange to -2, $teamStardustReason to "The dangerous dust surge harms the participants. Every participating astronaut loses 2 Stardust.")
      (display: "Apply Team Stardust")
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

    Select any subset of the available mission roster. A larger group provides a larger teamwork modifier, but only participating astronauts receive this challenge's Stardust effects.

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

      (if: $challengeCrewCount > 0)[(go-to: $challengeDestination)]
      (else:)[(alert: "Select at least one astronaut for this challenge.")]
    ]
  TWINE
  [27, "Challenge Crew Display", "1325,875", <<~'TWINE'],
    <div class="quest-card"><strong>PARTICIPATING CREW:</strong>(for: each _challengeName, ...$challengeCrewNames)[<span>(verbatim-print: _challengeName)</span>]</div>
  TWINE
]

passage_html = passages.map do |pid, name, position, source, tags|
  local_source = source.rstrip.gsub("../images/", "#{local_image_base}/")
  %(<tw-passagedata pid="#{pid}" name="#{CGI.escapeHTML(name)}" tags="#{CGI.escapeHTML(tags || "")}" position="#{position}" size="100,100">#{CGI.escapeHTML(local_source)}</tw-passagedata>)
end.join

storydata = %(<tw-storydata name="testing" startnode="1" creator="Twine" creator-version="2.12.1" format="Harlowe" format-version="3.3.9" ifid="10515CCC-3933-4FCB-9F91-389CAD821D22" options="" tags="" zoom="1" hidden><style role="stylesheet" id="twine-user-stylesheet" type="text/twine-css">#{css}</style><script role="script" id="twine-user-script" type="text/twine-javascript"></script>#{passage_html}</tw-storydata>)

html = File.read(story_path)
unless html.sub!(/<tw-storydata\b.*?<\/tw-storydata>/m, storydata)
  abort "Could not find the Twine story data block"
end

File.write(story_path, html)
puts "Built #{passages.length} passages into #{story_path}"

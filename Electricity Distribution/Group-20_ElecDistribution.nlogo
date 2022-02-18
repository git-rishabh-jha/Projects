extensions [array]
globals [
  power-plant-xcor
  power-plant-ycor
  rural-center-xcor
  rural-center-ycor
  distribution-center-xcor
  distribution-center-ycor
  urban-center-prev-xcor
  urban-center-prev-ycor
  organization-xcor
  organization-ycor
  to-change-xcor
  government-xcor
  government-ycor
  urban-center-xcor
  urban-center-ycor
  is-power-plant-connected-to-dc
  mean-index-rc
  mean-index-uc
  energy-requirement-mean-rc
  energy-allocated-mean-rc
  energy-requirement-mean-uc
  energy-allocated-mean-uc
]
breed [rural-centers rural-center]
breed [urban-centers urban-center]
breed [governments government]
breed [organizations organization]
breed [power-plants power-plant]
breed [distribution-centers distribution-center]
directed-link-breed [ pipes pipe ]

urban-centers-own [posh population energy-requirement no-of-household in-contract-with-distribution-center energy-in energy-requirement-per-12min energy-allocated-uc]
rural-centers-own [farming population energy-requirement no-of-household in-contract-with-distribution-center energy-in energy-requirement-per-12min energy-allocated-rc]
governments-own [budget-allocated]
organizations-own [budget budget-for-coal budget-for-maintenance under-government budget-allocated total-energy-generated]
power-plants-own [budget energy-generated in-contract-with-distribution-center in-contract-with-organization budget-for-maintenance energy-allocated]
distribution-centers-own [energy-distribution-ratio energy-requirement energy-got energy-in energy-allocated-dc]

to setup
  clear-all
  set urban-center-prev-xcor 4
  set urban-center-prev-ycor -13
  set to-change-xcor true
  set rural-center-xcor []
  set rural-center-ycor []
  set distribution-center-xcor [0 0]
  set distribution-center-ycor [4 -4]
  set power-plant-xcor [-5 -10 -10 -2 0]
  set power-plant-ycor  [14 -14 -10 -8 10]
  set organization-xcor  [-6 -8]
  set organization-ycor  [8 -3]
  set government-xcor [-12]
  set government-ycor [13]
  set urban-center-xcor []
  set urban-center-ycor []
  repeat number-urban-centers[
    let uc-xcor 2 + random 13
    let uc-ycor 0 - random 15
    set urban-center-xcor insert-item 0 urban-center-xcor uc-xcor
    set urban-center-ycor insert-item 0 urban-center-ycor uc-ycor
  ]
  repeat number-rural-centers[
    let rc-xcor 2 + random 15
    let rc-ycor 1 + random 14
    set rural-center-xcor insert-item 0 rural-center-xcor rc-xcor
    set rural-center-ycor insert-item 0 rural-center-ycor rc-ycor
  ]
  set is-power-plant-connected-to-dc n-values length power-plant-xcor [0]
  build-network
  reset-ticks
end

to build-network
  build-government
  build-organizations
  build-distribution-centers
  build-power-plants
  build-rural-centers
  build-urban-centers
  set-energy-generated-at-power-plant
  set-budget-at-organization
  ask patches [
    set pcolor white
  ]
end

to build-rural-centers
  create-rural-centers number-rural-centers
    (foreach sort [who] of rural-centers
    rural-center-xcor
    rural-center-ycor
     [
      [n x y] ->
      ask (rural-center n) [
        set population rural-population + random rural-population
        set xcor x
        set ycor y
        set farming 20 + random 81
        set no-of-household floor (population / (4 + random 3))
        set shape "house"
        set size 2
        set color red
        set label-color green - 3
        set in-contract-with-distribution-center random length distribution-center-xcor
        let distribution-xcor item in-contract-with-distribution-center distribution-center-xcor
        let distribution-ycor item in-contract-with-distribution-center distribution-center-ycor
        let breed-to self
        let breed-from "d"
        ask distribution-centers [
          if xcor = distribution-xcor and ycor = distribution-ycor [
            set breed-from self
          ]
        ]

        ask breed-from [ create-pipe-to breed-to [
          set color blue
          set thickness 0.01
          ]
        ]
      ]
  ])
  let max-population max [population] of rural-centers
  let max-farming max [farming] of rural-centers
   (foreach sort [who] of rural-centers
     [
      [n] ->
      ask (rural-center n) [
         set energy-requirement ((2 + 1.25 * ((population / (2 * max-population)) + random-float (population / (2 * max-population)))) + 1.5 * ((farming / (2 * max-farming)) + random-float (farming / (2 * max-farming)))) * no-of-household
        set energy-requirement energy-requirement * 30
        set energy-requirement-per-12min energy-requirement / 3600
        let distribution-xcor item in-contract-with-distribution-center distribution-center-xcor
        let distribution-ycor item in-contract-with-distribution-center distribution-center-ycor
        let breed-from "d"
        ask distribution-centers [
          if xcor = distribution-xcor and ycor = distribution-ycor [
            set breed-from self
          ]
        ]
        let selff self
        ask breed-from [
          set energy-requirement energy-requirement + [energy-requirement] of selff
          set energy-got energy-requirement
        ]
       ]
  ])
end

to set-energy-requirement-rural-center
   (foreach sort [who] of rural-centers
     [
      [n] ->
      ask (rural-center n) [
          (ifelse energy-requirement < 1000[
            set energy-requirement energy-requirement + 1000
          ][
            let op random 2
            (
              ifelse op = 0 [set energy-requirement energy-requirement + 1000][set energy-requirement energy-requirement - 1000]
            )
           ]
          )
        set energy-requirement-per-12min energy-requirement / 3600
        ;set energy-allocated-rc 0
        set energy-in 0
       ]
  ])
end
to build-urban-centers
  create-urban-centers number-urban-centers
    (foreach sort [who] of urban-centers
    urban-center-xcor
    urban-center-ycor
    [
      [n x y] ->
      ask (urban-center n) [
        set xcor x
        set ycor y
        set population urban-population + random urban-population
        set posh 20 + random 81
        set no-of-household floor (population / (2 + random 3))
        set shape "house two story"
        set size 2
        set color red
        set label-color green - 3
        set in-contract-with-distribution-center random length distribution-center-xcor
        let distribution-xcor item in-contract-with-distribution-center distribution-center-xcor
        let distribution-ycor item in-contract-with-distribution-center distribution-center-ycor
        let breed-to self
        let breed-from "d"
        ask distribution-centers [
          if xcor = distribution-xcor and ycor = distribution-ycor [
            set breed-from self
          ]
        ]
        ask breed-from [ create-pipe-to breed-to [
          set color blue
          set thickness 0.01
          ]
        ]
      ]
  ])
 let max-population max [population] of urban-centers
  let max-posh max [posh] of urban-centers
   (foreach sort [who] of urban-centers
     [
      [n] ->
      ask (urban-center n) [
        set energy-requirement ((2.5 + 1.5 * ((population / (2 * max-population)) + random-float (population / (2 * max-population)))) + 2 * ((posh / (2 * max-posh)) + random-float (posh / (2 * max-posh)))) * no-of-household
        set energy-requirement energy-requirement * 30
        set energy-requirement-per-12min energy-requirement / 3600
        let distribution-xcor item in-contract-with-distribution-center distribution-center-xcor
        let distribution-ycor item in-contract-with-distribution-center distribution-center-ycor
        let breed-from "d"
        ask distribution-centers [
          if xcor = distribution-xcor and ycor = distribution-ycor [
            set breed-from self
          ]
        ]
        let selff self
        ask breed-from [
          set energy-requirement energy-requirement + [energy-requirement] of selff
          set energy-got energy-requirement
        ]
       ]
  ])
end

to set-energy-requirement-urban-center
(foreach sort [who] of urban-centers
     [
      [n] ->
      ask (urban-center n) [
          (ifelse energy-requirement < 1000[
            set energy-requirement energy-requirement + 1000
          ][
            let op random 2
            (
              ifelse op = 0 [set energy-requirement energy-requirement + 1000][set energy-requirement energy-requirement - 1000]
            )
           ]
          )
        set energy-requirement-per-12min energy-requirement / 3600
        ;set energy-allocated-uc 0
        set energy-in 0
       ]
  ])
end
to build-government
  create-governments 1
  (foreach sort [who] of governments
    government-xcor
    government-ycor
    [0] [
      [n x y f] ->
      ask (government n) [
        set budget-allocated govt-budget
        set xcor x
        set ycor y
        set shape "house two story"
        set size 7
        set color green
        set label-color green - 3
      ]
  ])
end

to build-power-plants
  create-power-plants 5
  (foreach sort [who] of power-plants
    power-plant-xcor
    power-plant-ycor
    [0 0 0 0 0] [
      [n x y f] ->
      ask (power-plant n) [
        set xcor x
        set ycor y
        set shape "pentagon"
        set size 3
        set color blue
        set label-color green - 3
        ;connect-to-distribution-center
       ; let at-max-connected-to random length distribution-center-xcor
        let at-max-connected-to 0
        if at-max-connected-to = 0 [set at-max-connected-to 1]
        set in-contract-with-distribution-center []
        pd repeat at-max-connected-to [
          let to-which random length distribution-center-xcor
          set in-contract-with-distribution-center insert-item 0 in-contract-with-distribution-center to-which
          let dc-xxcor item to-which distribution-center-xcor
          let dc-yycor item to-which distribution-center-ycor
          let breed-from self
          let breed-to "f"
          ask distribution-centers [
            if xcor = dc-xxcor and ycor = dc-yycor [
              set breed-to self
            ]
          ]
           ask breed-from [ create-pipe-to breed-to [
            set color red
            set thickness 0.01
            ]
          ]

        ]
        ;connect-to-organization
        let to-which random length organization-xcor
        set in-contract-with-organization to-which
        let org-xcor item to-which organization-xcor
        let org-ycor item to-which organization-ycor
        let breed-from "f"
        let breed-to self
        ask organizations [
          if xcor = org-xcor and ycor = org-ycor[
            set breed-from self
          ]
        ]
        ask breed-from [create-pipe-to breed-to[
             set color green

          ]
        ]
      ]
  ])

end

to build-organizations
  create-organizations 2
  (foreach sort [who] of organizations
    organization-xcor
    organization-ycor
    [0 0] [
      [n x y f] ->
      ask (organization n) [
        set xcor x
        set ycor y
        set shape "house two story"
        set size 4
        set color pink
        set label-color green - 3
        set under-government 0
        let breed-from "breed-from"
        let breed-to self
        ask governments [
          set breed-from self
        ]
        ask breed-from [create-pipe-to breed-to[
             set color orange

          ]
        ]
      ]
  ])
end

to build-distribution-centers
  create-distribution-centers 2
  (foreach sort [who] of distribution-centers
    distribution-center-xcor
    distribution-center-ycor
    [0 9] [
      [n x y f] ->
      ask (distribution-center n) [
        set xcor x
        set ycor y
        set shape "pentagon"
        set size 3
        set color orange
        set label-color green - 3
      ]
  ])
end

to  set-energy-generated-at-power-plant
  ask distribution-centers[
  set energy-got energy-requirement]
  (foreach sort [who] of power-plants
    power-plant-xcor
    power-plant-ycor
    [0 0 0 0 0] [
      [n x y f] ->
      ask (power-plant n) [
        (foreach in-contract-with-distribution-center [
          [idx] ->
          let min-energy-generated 100
          let dc-xcor item idx distribution-center-xcor
          let dc-ycor item idx distribution-center-ycor
          let dc "none"
          ask distribution-centers [
            if xcor = dc-xcor and ycor = dc-ycor[
              set dc self
            ]
          ]
          let to-be-generated 0
          (ifelse [energy-got] of dc < 100
            [
              set to-be-generated ([energy-got] of dc)
              ask dc[set energy-got energy-got - to-be-generated]
            ]
            [
                 set to-be-generated 100 + random (([energy-got] of dc) - random ([energy-got] of dc))
                 ask dc[set energy-got energy-got - to-be-generated]
            ]
          )
          set energy-generated to-be-generated
          set label precision energy-generated 2
          set budget (coal-price / 8) * energy-generated ; energy-generated budget
          set budget-for-maintenance budget / 50 ;main

          ]
        )
      ]
  ])
  ask distribution-centers[
    if energy-got != 0 [
      let dc-asking self
      let min-energy-generated 999999999999999
      let min-energy-generated-by "from"
      ask power-plants [
        (foreach in-contract-with-distribution-center [
          [idx] ->
          let dc-xcor item idx distribution-center-xcor
          let dc-ycor item idx distribution-center-ycor
          let dc "none"
          ask distribution-centers [
            if xcor = dc-xcor and ycor = dc-ycor[
              set dc self
            ]
          ]
          if dc = dc-asking[
            if energy-generated <= min-energy-generated [
              set min-energy-generated energy-generated
              set min-energy-generated-by self
            ]
          ]
          ]
        )
      ]
      if min-energy-generated-by != "from"[
        ask min-energy-generated-by [
          (foreach in-contract-with-distribution-center [
            [idx] ->
            set energy-generated energy-generated + ([energy-got] of dc-asking)
            set label precision energy-generated 2
            let extra ((coal-price / 8) * ([energy-got] of dc-asking))
            set budget budget + extra ; energy-generated budget
            set budget-for-maintenance extra / 50 ;main
            ask dc-asking[set energy-got 0]
            ]
          )
        ]
      ]
    ]
  ]
end


to set-budget-at-organization
  (foreach sort [who] of power-plants[
      [n] ->
      ask (power-plant n) [
        let org-xcor item in-contract-with-organization organization-xcor
        let org-ycor item in-contract-with-organization organization-ycor
        let org "none"
        ask organizations [
          if xcor = org-xcor and ycor = org-ycor[
            set org self
          ]
        ]
        let here-budget budget
        ask org [
        set budget-for-coal budget + here-budget
        set budget-for-maintenance budget-for-maintenance + ([budget-for-maintenance] of myself)
        set budget budget-for-coal + budget-for-maintenance
        ]

      ]
  ])
end

to go ; 12 min=1 tick ==> 1hour = 5 tick => 1day = 120 tick => 30days = 3600 tick
  distribute-budget-at-org
  distribute-energy-at-power-plant
  energy-flow-from-pp-to-dc
  if ticks mod 3600 = 0 [
    set-energy-generated-at-power-plant
    set-energy-requirement-urban-center
    set-energy-requirement-rural-center

  ]
  energy-flow-from-dc-urban-centers
  energy-flow-from-dc-rural-centers
  mean-energy-allocated-rc
  mean-energy-allocated-uc
 ; requirement-vs-allocated-rc
  ;requirement-vs-allocated-uc
  tick
end

to energy-flow-from-pp-to-dc
  ask power-plants [
    let t-energy-allocated energy-allocated / 10
    let dc-c item 0 in-contract-with-distribution-center
    let self-plant self
    let dc-to "o"
    let dc-c-xcor item dc-c distribution-center-xcor
    let dc-c-ycor item dc-c distribution-center-ycor
    ask distribution-centers [
      if xcor = dc-c-xcor and ycor = dc-c-ycor[
        set dc-c self
      ]
    ]
    let connected-pipe one-of my-out-links
    let pipe-length 0
    ask connected-pipe[
      set pipe-length link-length
    ]
    let energy-loss-per-unit-of-wire 0.01
    set label precision energy-allocated 2
    let total-energy-loss pipe-length * energy-loss-per-unit-of-wire
    if t-energy-allocated = 0 [
      set total-energy-loss 0
    ]
   ; ask connected-pipe [
    ;  set label-color black
     ; set label total-energy-loss
    ;]
    ask dc-c [
      set energy-allocated-dc energy-allocated-dc + (t-energy-allocated - total-energy-loss)
      set label precision energy-allocated-dc 2
    ]
    set energy-allocated energy-allocated - t-energy-allocated
  ]
end

to  energy-flow-from-dc-urban-centers
  (foreach reverse (sort-on [posh] urban-centers)[
    [u-c] -> ask u-c[
      let idx in-contract-with-distribution-center
      let dc-xcor item idx distribution-center-xcor
      let dc-ycor item idx distribution-center-ycor
      let dc-from "here"
      ask distribution-centers [
        if xcor = dc-xcor and ycor = dc-ycor[
          set dc-from self
        ]
      ]
      let energy-gott 0
     let connected-pipe one-of my-in-links
    let pipe-length 0
    ask connected-pipe[
      set pipe-length link-length
    ]
    let energy-loss-per-unit-of-wire 0.01
    let total-energy-loss pipe-length * energy-loss-per-unit-of-wire
      ask dc-from [
        ifelse energy-allocated-dc > ([energy-requirement-per-12min] of myself + total-energy-loss)[
          set energy-gott ([energy-requirement-per-12min] of myself - total-energy-loss)
          set energy-allocated-dc energy-allocated-dc - ([energy-requirement-per-12min] of myself + total-energy-loss)
        ][
          if energy-allocated-dc = 0[
            set total-energy-loss 0
          ]
          ifelse (energy-allocated-dc - total-energy-loss) < 0
          [set energy-gott 0 ]
          [set energy-gott  (energy-allocated-dc - total-energy-loss)]

           set energy-allocated-dc 0
        ]
      ]
      set energy-allocated-uc energy-allocated-uc + energy-gott
      set label precision energy-allocated-uc 2
      set label-color yellow

    ]
    ]
  )
end

to  energy-flow-from-dc-rural-centers

  (foreach reverse (sort-on [farming] rural-centers)[
    [r-c] -> ask r-c[
      let idx in-contract-with-distribution-center
      let dc-xcor item idx distribution-center-xcor
      let dc-ycor item idx distribution-center-ycor
      let dc-from "o"
      ask distribution-centers [
        if xcor = dc-xcor and ycor = dc-ycor[
          set dc-from self
        ]
      ]
      let energy-gott 0
     let connected-pipe one-of my-in-links
    let pipe-length 0
    ask connected-pipe[
      set pipe-length link-length
    ]
    let energy-loss-per-unit-of-wire 0.01
    let total-energy-loss pipe-length * energy-loss-per-unit-of-wire
      ask dc-from [
        ifelse energy-allocated-dc > ([energy-requirement-per-12min] of myself + total-energy-loss)[
          set energy-gott ([energy-requirement-per-12min] of myself - total-energy-loss)
          set energy-allocated-dc energy-allocated-dc - ([energy-requirement-per-12min] of myself + total-energy-loss)
        ][
          if energy-allocated-dc =  0[
            set total-energy-loss 0
          ]
          ifelse (energy-allocated-dc - total-energy-loss) < 0
          [set energy-gott 0 ]
          [set energy-gott  (energy-allocated-dc - total-energy-loss)]
           set energy-allocated-dc 0
        ]
      ]
      set energy-allocated-rc energy-allocated-rc + energy-gott
      set label precision energy-allocated-rc 2
      set label-color yellow

    ]
    ]
  )
end

to distribute-budget-at-org
  let org-budget sum [budget] of organizations
  ask organizations[
    set budget-allocated (budget / org-budget) * govt-budget
    set total-energy-generated (8 * budget-allocated) / coal-price
  ]
end

to distribute-energy-at-power-plant
  ask organizations[
    let total-energy 0
    ask power-plants[
      let idx in-contract-with-organization
      let org-xcor item idx organization-xcor
      let org-ycor item idx organization-ycor
      let connected-from "x"
      ask organizations[
        if xcor = org-xcor and ycor = org-ycor[
          set connected-from self
        ]
      ]
      if connected-from = myself[
        set total-energy total-energy + energy-generated
      ]
    ]
    ask power-plants[
      let idx in-contract-with-organization
      let org-xcor item idx organization-xcor
      let org-ycor item idx organization-ycor
      let connected-from "x"
      ask organizations[
        if xcor = org-xcor and ycor = org-ycor[
          set connected-from self
        ]
      ]
      if connected-from = myself[
        set energy-allocated (energy-generated / total-energy) * ([total-energy-generated] of myself)
      ]
    ]

  ]
end

to mean-energy-allocated-rc
  let mean-sum 0
  if ticks > 0[
    ask rural-centers[
      set mean-sum mean-sum + energy-allocated-rc / (energy-requirement-per-12min * (ticks + 1))
    ]
  ]
  set mean-index-rc (mean-sum / (count rural-centers))
end
to mean-energy-allocated-uc
  let mean-sum 0
  if ticks > 0[
    ask urban-centers[
      set mean-sum mean-sum + energy-allocated-uc / (energy-requirement-per-12min * (ticks + 1))
    ]
  ]
  set mean-index-uc (mean-sum / (count urban-centers))
end
to requirement-vs-allocated-rc
  let t-energy-requirement-mean-rc 0
  let t-energy-allocated-mean-rc 0
  ask rural-centers[
    set t-energy-requirement-mean-rc t-energy-requirement-mean-rc + energy-requirement
    set t-energy-allocated-mean-rc t-energy-allocated-mean-rc + energy-allocated-rc
  ]
  set energy-requirement-mean-rc  (t-energy-requirement-mean-rc / (count rural-centers)) / 10000
  set energy-allocated-mean-rc (t-energy-allocated-mean-rc / (count rural-centers)) / 10000
end

to  requirement-vs-allocated-uc
  let t-energy-requirement-mean-uc 0
  let t-energy-allocated-mean-uc 0
  ask urban-centers[
    set t-energy-requirement-mean-uc t-energy-requirement-mean-uc + energy-requirement
    set t-energy-allocated-mean-uc t-energy-allocated-mean-uc + energy-allocated-uc
  ]
  set energy-requirement-mean-uc (t-energy-requirement-mean-uc / (count urban-centers)) / 10000
  set energy-allocated-mean-uc (t-energy-allocated-mean-uc / (count urban-centers)) / 10000
end

to-report index-uc
  report mean-index-uc
end
to-report index-rc
  report mean-index-rc
end
@#$#@#$#@
GRAPHICS-WINDOW
211
10
648
448
-1
-1
13.0
1
10
1
1
1
0
0
0
1
-16
16
-16
16
1
1
1
ticks
30.0

BUTTON
74
40
137
73
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
671
15
845
48
number-urban-centers
number-urban-centers
0
5
2.0
1
1
NIL
HORIZONTAL

SLIDER
673
68
845
101
number-rural-centers
number-rural-centers
0
5
5.0
1
1
NIL
HORIZONTAL

SLIDER
671
118
843
151
rural-population
rural-population
500
10000
8000.0
500
1
NIL
HORIZONTAL

SLIDER
670
162
842
195
urban-population
urban-population
500
10000
6500.0
500
1
NIL
HORIZONTAL

SLIDER
670
204
844
237
govt-budget
govt-budget
100000
10000000
1100000.0
500000
1
NIL
HORIZONTAL

SLIDER
670
252
842
285
coal-price
coal-price
2800
7600
4200.0
400
1
NIL
HORIZONTAL

BUTTON
29
110
92
143
NIL
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
117
112
180
145
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
975
36
1068
81
mean-index-rc
mean-index-rc
17
1
11

MONITOR
1082
36
1177
81
mean-index-uc
mean-index-uc
17
1
11

PLOT
938
107
1233
277
mean-index
NIL
NIL
0.0
10.0
0.0
1.0
true
true
"" ""
PENS
"mean-index-rc" 1.0 0 -15040220 true "" "plot mean-index-rc"
"mean-index-uc" 1.0 0 -955883 true "" "plot mean-index-uc"

@#$#@#$#@
## WHAT IS IT?

This model is used to structure the electricity generation, usage and distribution from a power plant to the household with the Government proving a budget for the power plant to generate electricity.

## HOW IT WORKS

In this electricity distribution model, we have the government which assigns a budget to the organization which own a number of power plant(s). The power plant(s) generate electricity at a specified cost and there will be some maintenance cost for each power plant depending upon it's generation capacity. The power plant supplies the electricity to a distribution center which in turn distributes it to the urban and rural centers. This electricity supply will also lead to some power loss for the distribution.


### Types of Agents


* PIPES as links, with a certain length (defining the size of the wire expanding the network from one agent to another)
	* associated with a set loss of 0.01 per unit length
* GOVERNMENT as agents with:
	* budget-allocated
* ORGANIZATIONS as agents with:
	* budget
	* budget-for-coal
	* budget-for-maintenance
	* under-government
	* budget-allocated
	* total-energy-generated
* POWER-PLANTS, defined for energy generation (0.1 per tick) with:
	* budget
	* energy-generated
	* in-contract-with-distribution-center
	* in-contract-with-organization
	* budget-for-maintenance
	* energy-allocated
* DISTRIBUTION-CENTERS in charge with distributing of the energy ahead with:
	* energy-distribution-ratio 
	* energy-requirement
	* energy-got
	* energy-in
	* energy-allocated-dc
* URBAN and RURAL CENTERS representing the energy consumers:
	* posh/farming
	* population
	* energy-requirement
	* no-of-household
	* in-contract-with-distribution-center
	* energy-in energy-requirement-per-12min
	* energy-allocated-uc

Initially the organization-powerplant-distributioncenter connection is build randomly.

There are 6 types of agents (breeds): GOVERNMENT, ORGANIZATIONS, POWER-PLANT, DISTRIBUTION-CENTERS, URBAN CENTERS, RURAL-CENTERS. The energy-distribution-network is defined by lists defining for each agent breed:

* its spatial position (x, y coordinates)
* its connection to the network:
	* the energy flow in the pipe
	* generation/distribution/participation in the system

### Simulation time step
In this Agent - Based Model we have used 1 tick to be equivalent to 12minutes in real time, so we can say that 5 ticks will be 1 hour, 120 ticks will be 24 hours. So, we get a complete cycle i.e. 30 days to be completed in 3600 ticks.

### Government behavior
GOVERNMENT has a budget-alloted attribute which is distributed among the organizations based on the energy-distribution by respective organizations.


### Organizations behavior
* Each ORGANIZATION tries to maintain its budget-expenditure to meet the coal requirements and maintenance, from the budget allocated by the Government.

* Each ORGANIZATION is contracted with a number of power plants (possibly 0?), thus keeps the account of energy-generation and distribution.


### Power-Plants behavior
* Each Power-Plant is connected with an Organization and a Distribution-center and keeps a budget-distribution for maintenance.

* Each Power-Plant:
	* generates energy at 0.1 per tick
	* keeps account of energy generated


### Distribution-centers behavior
* Each Distribution-center keeps tabs on:
	* energy-recieved
	* energy-allocated
	* energy-requirement
	* energy-distribution-ratio

Acting as the medium/connection between Urban and Rural centers and the Organizations.


### Urban & Rural Centers behavior
Each of these centers representes the consumers of energy in our society.

* For Urban-centers:


	* population = urban-population + random urban-population


	* posh 20 + random 81 {denoting the energy consumption unit}


	* no-of-household = floor (population / (2 + random 3)) {representing the number of households under the center }


	* energy-requirement  = ((2.5 + 1.5 * ((population / (2 * max-population)) + random-float (population / (2 * max-population)))) + 2 * ((posh / (2 * max-posh)) + random-float (posh / (2 * max-posh)))) * no-of-household


* For Rural-centers:


	* population = rural-population + random rural-population


	* farming 20 + random 81 {denoting the energy consumption unit}


	* no-of-household = floor (population / (2 + random 3)) {representing the number of households under the center }


	* energy-requirement = ((2 + 1.25 * ((population / (2 * max-population)) + random-float (population / (2 * max-population)))) + 1.5 * ((farming / (2 * max-farming)) + random-float (farming / (2 * max-farming)))) * no-of-household


## HOW TO USE IT

Here, we have a type of a map or a distribution diagram  of the electricity flow. We have the following sliders:
1. Number of urban centers.
2. Number of rural centers.
3. The rural population.
4. The urban population.
5. Coal Price / Electricity generation price.
6. Government Budget.

## THINGS TO NOTICE

The user see the electricity generated at each power plant in the form of a label, the part of the electricity flow from the plant to the distribution center, the electricity loss during the flow, the energy reaching the urban/rural centers.

## THINGS TO TRY

We can change the number of urban centers / rural centers, popuation in each center, cost of coal, the government budget. We can also get various configurations for power plant - distribution center pairs as we have a random selector for each distribution center.

## EXTENDING THE MODEL

We can add a user input(slider) for the number of power plants and distribution centers as to create a more complex model and one may also specify the power plant - distribution center pairs so as to check a particular configuration and we can also change the variable we have used for energy loss. In our model we supply electricity from the power plant to the distribution center at a particular rate and not all at once, one may also modify this to get a better electricity flow.
In our model we have given priority to urban centers first and then subsequent priority to how posh the household is, instead one should make a priority as first to get the most post household of the urban center, supply electricity to them then one should get the rural household which has the most farming used and then supply electricity and henceforth.

## NETLOGO FEATURES

* FOREACH is used to generate the network. In order to show the distribution happening FOREACH is used.

* REPORT is used in order to return the values.

* Behavior-State-Experiments is used to retrieve the values in the experiment.


## RELATED MODELS

No similar model could be identified in the library.
This energy distribution system is made from scratch by the developers themselves.

## CREDITS AND REFERENCES

This model has been developed by:

* Ashar Siddiqui


* Rishabh Jha


* Priyanshu Mishra


* Chinmay Lohani

In the scope of the Agent Based Modelling and Simulation Course offered at IIIT Sri City, Chittoor.


The following references show contributions of Agent Based Modeling to think and orientate the energy transition:

The following references show contributions of Agent Based Modeling to think and orientate the energy transition:

* <a href="http://ccl.northwestern.edu/netlogo/models/community/ReseauChaleur_HeatNetwork_v1"> Agent-based model for Heat Network</a>


* <a href="https://www.comses.net/codebases/5903/releases/1.10.0/"> Agent-based Renewables model for Integrated Sustainable Energy (ARISE)</a>


@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

house two story
false
0
Polygon -7500403 true true 2 180 227 180 152 150 32 150
Rectangle -7500403 true true 270 75 285 255
Rectangle -7500403 true true 75 135 270 255
Rectangle -16777216 true false 124 195 187 256
Rectangle -16777216 true false 210 195 255 240
Rectangle -16777216 true false 90 150 135 180
Rectangle -16777216 true false 210 150 255 180
Line -16777216 false 270 135 270 255
Rectangle -7500403 true true 15 180 75 255
Polygon -7500403 true true 60 135 285 135 240 90 105 90
Line -16777216 false 75 135 75 180
Rectangle -16777216 true false 30 195 93 240
Line -16777216 false 60 135 285 135
Line -16777216 false 255 105 285 135
Line -16777216 false 0 180 75 180
Line -7500403 true 60 195 60 240
Line -7500403 true 154 195 154 255

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.2.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="experiment" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <exitCondition>ticks = 10000</exitCondition>
    <metric>ticks</metric>
    <metric>index-rc</metric>
    <metric>index-uc</metric>
    <enumeratedValueSet variable="urban-population">
      <value value="3000"/>
      <value value="6000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="coal-price">
      <value value="4200"/>
      <value value="7200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-urban-centers">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="govt-budget">
      <value value="2100000"/>
      <value value="7600000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rural-population">
      <value value="6500"/>
      <value value="8500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-rural-centers">
      <value value="5"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@

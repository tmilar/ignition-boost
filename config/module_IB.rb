module IB

  #-------------------------------------------------------------------------------
  #  DEFINE GAME VARIABLES
  #-------------------------------------------------------------------------------

  #-------------------------------------------------------------------------------
  # **** WEAPONS ****
  #-------------------------------------------------------------------------------

  LAZOR_WEAPON = {
      name: "lazor",         # weapon name (also lazor image '.png' name)
      type: "lazor",          # weapon type // IGNORAR esto por ahora, no hace nada //
      stats: {
          damage: 1,              # bullet damage
          speed: 5,               # bullet speed
          cooldown: 5,            # time to wait before shooting again
      },
      direction: [0, -1],     # Initial direction for bullets [x, -y]
      SE: ["Attack2",80,150], # sound when shooting
      level: 1,               # starting weapon level (optional, default 1)
  }

  BALL_WEAPON = {
      name: "lazor_ball",         # weapon name (also lazor image '.png' name)
      type: "ball",           # weapon type // IGNORAR esto por ahora, no hace nada //
      stats: {
          damage: 1,              # bullet damage
          speed: 7,               # bullet speed
          cooldown: 7,
      },
      direction: [0, -1],     # Initial direction for bullets [x, -y]
      level: 1,               # starting weapon level (optional)
      SE: ["Heal5",80,160]
  }

  #-------------------------------------------------------------------------------
  # **** PLAYER SHIPS ****
  #-------------------------------------------------------------------------------

  # default config for base PLAYER ship
  NAVE_BASE1 = {
      name: "player_ship",          #
      stats: {
          power: 1,
          speed: 5,
          hp: 40,
          collide_damage: 99,
          collide_resistance: 0,
          shoot_freq: 0,             ## TODO por ahora esto remplazara la @difficulty
          nuke_power: 99            # Damage caused by nuke
      },
      weapon: LAZOR_WEAPON
  }

  #-------------------------------------------------------------------------------
  # **** ENEMIES ****
  #-------------------------------------------------------------------------------


  # basic enemy ship config
  ENEMIGO1 = {
      name: "alien1",
      stats: {
          power: 1,
          speed: 1,
          hp: 2,
          collide_damage: 4,
          shoot_freq: 6,             ## TODO por ahora esto remplazara la @difficulty
      },
      weapon: {
          name: "elazor1",
          type: "lazor",
          stats: {
              damage: 1,              # bullet damage
              speed: 5,               # bullet speed
          },
          SE: ["Attack2",80,110],
          direction: [0, 1],     # Initial direction for bullets [x, -y]
      },
      DSE: ["Fire3",90,150], # "SE_Name",volume,pitch - SE for enemy dying
      # movement: linear_movement #### TODO! DEFINIR BIEN los MOVEMENT STYLES
  }

  # basic enemy ship config
  ENEMIGO2 = {
      name: "alien2",
      stats: {
          power: 1,
          speed: 1,
          hp: 6,
          collide_damage: 4,
          shoot_freq: 10,             ## TODO por ahora esto remplazara la @difficulty
      },
      weapon: {
          name: "elazor2",
          type: "lazor",
          stats: {
              damage: 1,              # bullet damage
              speed: 5,               # bullet speed
          },
          SE: ["Attack2",80,110],
          direction: [0, 1],     # Initial direction for bullets [x, -y]
      },
      DSE: ["Fire2",90,150], # "SE_Name",volume,pitch - SE for enemy dying
  }

  ENEMIGO3 = {
      name: "alien3",
      stats: {
          power: 1,
          speed: 0.6,
          hp: 10,
          collide_damage: 6,
          shoot_freq: 15,
      },
      weapon: {
          name: "elazor",
          type: "lazor",
          stats: {
              damage: 3,              # bullet damage
              speed: 3,               # bullet speed
          },
          level: 2,
          SE: ["Attack2",80,110],
          direction: [0, 1],     # Initial direction for bullets [x, -y]
      },
      DSE: ["Fire2",90,150], # "SE_Name",volume,pitch - SE for enemy dying
  }

  BOSS1 = {
      name: "boss1",
      stats: {
          power: 5,
          speed: 0.5,
          hp: 200,
          collide_damage: 9999,
          collide_resistance: 9999,
          shoot_freq: 18,
      },
      weapon: {
          name: "lazor_ball",
          type: "ball",
          stats: {
              damage: 3,              # bullet damage
              speed: 0.8,               # bullet speed
          },
          level: 5,
          direction: [0, 1],     # Initial direction for bullets [x, -y]
      },
      limits: {
          x: [0.0, 1.0],
          y: [-1.0, 1.1]
      }
  }

  #-------------------------------------------------------------------------------
  # **** PUPS  **** //TODO define  & include in Levels
  #-------------------------------------------------------------------------------

  ### EXAMPLES ###
  # PowerUps.
  # Los powerUp multiplican o suman a un stat. Si el valor es +ENTERO o -ENTERO, sera suma/resta.
  # Si es DECIMAL (con "punto" - de 0.0 en adelante) es un factor que se MULTIPLICA. Ej. 0.1, 1.5, 2.0, etc..
  # Por ahora, ademas, lo que puede cambiar es>
  # >>> del JUEGO ->  spawn_cooldown  ; y  stats de naves
  REPAIR_PUP = {
      name: "powerup0",     # PowerUp name, also must match image name
      target: "player",     # Target : "player", o "enemies" . DEFAULT: "player"
      stats: {              # stats that will change
          hp: +100          # increase hp
      },
      frequency: 20         # [Optional] frequency pup will appear. Default: powerup spawner frequency
  }

  WEAPON_UP = {
      name: "powerup1",
      target: "player",
      weapon: {
          level: +1
      }
  }

  #### MORE EXAMPLES ###
  SPEED_UP = {
      name: "speed_pup",
      stats: {
          speed: +1
      },
  }

  HP_DOWN = {
      name: "hp_down_pup",
      stats: {
          hp: -1
      }
  }

  SLOW_ENEMY_PUP = {
      name: "slower_enemies_pup",
      target: "enemies",
      stats: {
          speed: -1
      },
  }


  ### RESET_PUP > baja la frecuencia de aparicion y disparos enemigos...
  RESET_PUP = {
      name: "powerup999",
      target: "level",
      difficulty: 0.5
  }

  # Items are also a kind of powerup but with some key "effect" to distinguish
  # TODAVIA NO FUNCA
  NUKEALL_ITEM = {
      name: "item_nuke",
      target: "player",
      hold: true,
      effect: "nuke"    # keyword for item type
  }

  # Weapon change power up. Will change current weapon with other one...
  BALL_WEAPON_CHANGE_PUP = {
      name: "powerup2",
      target: "player",
      weapon: BALL_WEAPON # Weapon to change. If weapon is repeated, level will go up +1 instead.
  }

  # Weapon change power up. Will change current weapon with other one...
  LAZOR_WEAPON_CHANGE_PUP = {
      target: "player",
      name: "powerup4",
      weapon: LAZOR_WEAPON
  }

  #-------------------------------------------------------------------------------
  # **** LEVELS ****
  #-------------------------------------------------------------------------------


  NIVEL0 = {
      name: 'first level',
      backdrop: 'backdrop',
      spawner: {
          spawn_cooldown: 50,
          spawn_decrement_freq: 100,
          spawn_decrement_amount: 1,
          phases: {
              1 => {
                  enemies: [ENEMIGO1, ENEMIGO2],
                  start: 0,             #time phase can start spawning enemies
              },
              2 => {
                  enemies: [ENEMIGO3],
                  start: 5,
                  end: 10,
                  BGM: ["Battle1", 60, 110] #BGM to be played when this phase starts
              },
              3 => {
                  enemies: [BOSS1],
                  start: 20,
                  max_spawn: 1,
                  BGM: ["Battle3", 60, 110]
              }
          }
      },
      powerup_spawner: {
          frequency: 5,                                  # DEFAULT "base" powerup frequency. 0 equals no pups (EXCEPT those that specify other number)
          phases: {                                       # Powerup spawner can also have phases!
              1 => {                                      # phase 1 (can define others, with propertis such as "start", "end", "max_spawn" & "BGM")
                  powerups: [REPAIR_PUP, WEAPON_UP, BALL_WEAPON_CHANGE_PUP, LAZOR_WEAPON_CHANGE_PUP, SPEED_UP],
              },
              2 => {
                  powerups: [RESET_PUP],
                  timer: 10,                # set a constant timer in seconds for phase, ignoring spawner 'frequency'
                  timer_increment: 1        # optional (default 0): set an increment for the next timer each time it downs to 0
              },
          },
          # destructible?: false                            # Can pups can be destroyed by bullets? (default: false)
      },
      BGM: ["Battle2", 60, 110],
      target_score: 200
  }



  MY_POWERUP_LEVEL = {
      backdrop: 'backdrop',           # FONDO imagen .jpg
      name: 'first_level',            # Level name - Solo estetico.
      BGM: ['Battle2', 60, 110],
      target_score: 100,
      spawner: {
          spawn_cooldown: 100,            # Default 100 (mismo que Galv SPAWN_SPEED)
          spawn_decrement_amount: 1,      # Default 1 (mismo que Galv.. antes no era modificable)
          spawn_decrement_freq: 100,      # Default 100 (mismo que Galv.. antes no era modificable)
          phases: {
              1 => {
                  enemies: [ENEMIGO1, ENEMIGO2],
                  start: 15, # time when phase can start spawning enemies
              },
              2 => {
                  enemies: [ENEMIGO2],
                  start: 20         # time when phase can start spawning enemies
              }
          }
      },
      powerup_spawner: {
          frequency: 45,               # DEFAULT "base" powerup frequency. 0 equals no pups (EXCEPT those that specify other number)
          phases: {                    # Powerup spawner can also have phases!
              1 => {                     # phase 1
                 powerups: [SPEED_UP, WEAPON_UP, REPAIR_PUP],
              }
          },
          destructible?: false         # Can pups can be destroyed by bullets?
      }
  }

  TEST_MECHANICS_LEVEL = {
      backdrop: 'backdrop',           # FONDO imagen .jpg
      name: 'test_level',            # Level name - Solo estetico.
      BGM: ['Battle2', 60, 110],
      target_score: 100,
      spawner: {
          spawn_cooldown: 100,            # Default 100 (mismo que Galv SPAWN_SPEED)
          phases: {
              1 => {
                  enemies: [BOSS1],
                  max_spawn: 1,
                  start: 0, # time when phase can start spawning enemies
              },
          }
      },
      powerup_spawner: {
          # frequency: 10,               # DEFAULT "base" powerup frequency. 0 equals no pups (EXCEPT those that specify other number)
          # phases: {                    # Powerup spawner can also have phases!
          #                              1 => {                     # phase 1
          #                                                         powerups: [SPEED_UP, WEAPON_UP, HP_DOWN, REPAIR_PUP],
          #                              }
          # },
      }
  }

  TEST_STRESS_LEVEL = {
      name: 'STRESS level',
      backdrop: 'backdrop',
      spawner: {
          spawn_cooldown: 1,
          phases: {
              1 => {
                  enemies: [ENEMIGO1, ENEMIGO2],
                  start: 0,             #time phase can start spawning enemies
              },
              2 => {
                  enemies: [ENEMIGO2],
                  start: 0,
                  end: 10,
                  BGM: ["Battle1", 60, 110] #BGM to be played when this phase starts
              },
              3 => {
                  enemies: [BOSS1],
                  start: 4,
                  max_spawn: 5,
                  BGM: ["Battle3", 60, 110]
              }
          }
      },
      powerup_spawner: {
          frequency: 100,                                  # DEFAULT "base" powerup frequency. 0 equals no pups (EXCEPT those that specify other number)
          phases: {                                       # Powerup spawner can also have phases!
              1 => {                                      # phase 1 (can define others, with propertis such as "start", "end", "max_spawn" & "BGM")
                powerups: [REPAIR_PUP, WEAPON_UP, BALL_WEAPON_CHANGE_PUP, LAZOR_WEAPON_CHANGE_PUP, SPEED_UP], #blabla
              }
          },
      },
      BGM: ["Battle2", 60, 110],
      target_score: 100
  }

  TEST_STRESS_SHIP = {
      name: "player_ship",
      stats: {
          power: 1,
          speed: 5,
          hp: 1000,
          collide_damage: 99,
          collide_resistance: 0,
          shoot_freq: 0,
          nuke_power: 99            # Damage caused by nuke
      },
      weapon: LAZOR_WEAPON
  }

  #-------------------------------------------------------------------------------
  #  OTHER CONFIG
  #-------------------------------------------------------------------------------

  GRAPHICS_ROOT = "Graphics/Invaders/"

  BGM = ["Battle2", 50, 110] #musica de fondo: ["BGM_Name",volume,pitch]
  ME_WIN = ["Victory2", 100, 110]
  ME_LOSS = ["Gameover2", 100, 110]

  DSE = ["Fire3",90,150]  # "SE_Name",volume,pitch - SE for enemy dying

  SCORE_VAR = 100         # Variable id to keep track of score
  HIGH_SCORE_VAR = 101    # Variable id to keep track of highest score

  SOUND_TIMER = 5       # Prevent enemy lazor sound spam by increasing this

  DEBUG = {
      # borders: true  ## draw rectangle borders
      logger_level: 5 # 0 NONE, 1 ERROR, 2 WARN, 3 INFO (recommended), 4 DEBUG, 5 TRACE
  }
  #-------------------------------------------------------------------------------
  #  BUILD GAME
  #-------------------------------------------------------------------------------


  CURRENT_LEVEL = NIVEL0 ## TEST_MECHANICS_LEVEL #TEST_STRESS_LEVEL #TEST_MECHANICS_LEVEL #NIVEL0 #MY_POWERUP_LEVEL
  PLAYER_SHIP = NAVE_BASE1 #NAVE_BASE1 #TEST_STRESS_SHIP

end

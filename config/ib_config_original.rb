module IB

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
      SE: ["laser1",80,150], # sound when shooting
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
      SE: ["esfera",80,160]
  }

  ## arma de los enemigos por default (uso siempre la misma ) - se pueden definir otras distintas!
  ALIEN_WEAPON_BASIC = {
      name: "elazor1",
      type: "lazor",
      stats: {
          damage: 1,              # bullet damage
          speed: 5,               # bullet speed
      },
      SE: ["laser1",80,110],
      direction: [0, 1],     # no tocar - Initial direction for bullets [x, -y]
  }

  #-------------------------------------------------------------------------------
  # **** PLAYER SHIPS ****
  #-------------------------------------------------------------------------------

  # NAVE_BASE, NAVE_TERRESTRE, NAVE_CAPITAN
  NAVE_BASE = {
      name: "player",
      stats: {
          power: 1,
          speed: 4,
          hp: 15,
          collide_damage: 99,
          collide_resistance: 0,
          shoot_freq: 0,
          nuke_power: 99            # Damage caused by nuke
      },
      weapon: LAZOR_WEAPON
  }

  NAVE_TERRESTRE = {
      name: "player2",
      stats: {
          power: 1,
          speed: 7,
          hp: 6,
          collide_damage: 99,
          collide_resistance: 0,
          shoot_freq: 0,
          nuke_power: 99            # Damage caused by nuke
      },
      weapon: LAZOR_WEAPON
  }

  NAVE_CAPITAN = {
      name: "player3",
      stats: {
          power: 1,
          speed: 7,
          hp: 10,
          collide_damage: 99,
          collide_resistance: 0,
          shoot_freq: 0,
          nuke_power: 99            # Damage caused by nuke
      },
      weapon: LAZOR_WEAPON
  }


  #-------------------------------------------------------------------------------
  # **** ENEMY SHIPS ****
  #-------------------------------------------------------------------------------
  ALIEN1 = {
      name: "alien1",
      stats: {
          power: 1,
          speed: 1,
          hp: 1,
          collide_damage: 2,
          shoot_freq: 6,
      },
      weapon: ALIEN_WEAPON_BASIC,
  }

  ALIEN2 = {
      name: "alien2",
      stats: {
          power: 1,
          speed: 1,
          hp: 2,
          collide_damage: 2,
          shoot_freq: 6,
      },
      weapon: ALIEN_WEAPON_BASIC,
  }

  ALIEN2_DURO = {
      name: "alien2",
      stats: {
          power: 1,
          speed: 1,
          hp: 3,
          collide_damage: 2,
          shoot_freq: 6,
      },
      weapon: ALIEN_WEAPON_BASIC,
  }

  ALIEN3 = {
      name: "alien3",
      stats: {
          power: 1,
          speed: 1,
          hp: 10,
          collide_damage: 2,
          shoot_freq: 6,
      },
      weapon: {
          name: "elazor1",
          type: "lazor",
          stats: {
              damage: 1,              # bullet damage
              speed: 5,               # bullet speed
          },
          SE: ["laser1",80,110],
          direction: [0, 1],     # Initial direction for bullets [x, -y]
      },
  }

  NAVE_TIERRA1 = {
      name: "nave01",
      stats: {
          power: 1,
          speed: 1,
          hp: 2,
          collide_damage: 2,
          shoot_freq: 6,
      },
      weapon: ALIEN_WEAPON_BASIC,
  }

  NAVE_TIERRA2 = {
      name: "nave02",
      stats: {
          power: 1,
          speed: 1,
          hp: 4,
          collide_damage: 2,
          shoot_freq: 6,
      },
      weapon: ALIEN_WEAPON_BASIC,
  }

  NAVE_TIERRA3 = {
      name: "nave03",
      stats: {
          power: 1,
          speed: 1,
          hp: 10,
          collide_damage: 2,
          shoot_freq: 6,
      },
      weapon: ALIEN_WEAPON_BASIC,
  }


  ENEMIGO1_FACIL = {
      name: "enemigo1",
      stats: {
          power: 1,
          speed: 1,
          hp: 1,
          collide_damage: 2,
          shoot_freq: 6,
      },
      weapon: ALIEN_WEAPON_BASIC,
  }

  ENEMIGO2_FACIL  = {
      name: "enemigo2",
      stats: {
          power: 1,
          speed: 1,
          hp: 3,
          collide_damage: 2,
          shoot_freq: 6,
      },
      weapon: ALIEN_WEAPON_BASIC,
  }

  ENEMIGO3_FACIL  = {
      name: "enemigo3",
      stats: {
          power: 1,
          speed: 1,
          hp: 10,
          collide_damage: 2,
          shoot_freq: 6,
      },
      weapon: ALIEN_WEAPON_BASIC,
  }

  ENEMIGO1_MEDIO  = {
      name: "enemigo1",
      stats: {
          power: 1,
          speed: 1,
          hp: 2,
          collide_damage: 2,
          shoot_freq: 6,
      },
      weapon: ALIEN_WEAPON_BASIC,
  }

  ENEMIGO2_MEDIO  = {
      name: "enemigo2",
      stats: {
          power: 1,
          speed: 1,
          hp: 4,
          collide_damage: 2,
          shoot_freq: 6,
      },
      weapon: ALIEN_WEAPON_BASIC,
  }

  ENEMIGO3_MEDIO  = {
      name: "enemigo3",
      stats: {
          power: 1,
          speed: 1,
          hp: 10,
          collide_damage: 2,
          shoot_freq: 6,
      },
      weapon: ALIEN_WEAPON_BASIC,
  }


  ENEMIGO1_DIFICIL = {
      name: "enemigo1",
      stats: {
          power: 1,
          speed: 1,
          hp: 3,
          collide_damage: 2,
          shoot_freq: 6,
      },
      weapon: ALIEN_WEAPON_BASIC,
  }

  ENEMIGO2_DIFICIL = {
      name: "enemigo2",
      stats: {
          power: 1,
          speed: 1,
          hp: 5,
          collide_damage: 2,
          shoot_freq: 6,
      },
      weapon: ALIEN_WEAPON_BASIC,
  }

  ENEMIGO3_DIFICIL = {
      name: "enemigo3",
      stats: {
          power: 1,
          speed: 1,
          hp: 12,
          collide_damage: 2,
          shoot_freq: 6,
      },
      weapon: ALIEN_WEAPON_BASIC,
  }


  BOSS1 = {

  }



  #-------------------------------------------------------------------------------
  # **** POWERUPS  ****
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

  NUKE_PUP = {
      name: "powerup3",
      target: "player",
      item: {
          hold: true,
          bitmap: "item_nuke",
          name: "nuke",
          SE: ["Explosion3",120,100],
          target: ["enemies", "level"],
          difficulty: 0.75,
          stats: {
              hp: -30,  ## enough to kill most of them
          },
      }
  }

  #### EXAMPLE ### (unused)
  SPEED_UP = {
      name: "speed_pup",
      stats: {
          speed: +1
      },
  }

  #### EXAMPLE ### (unused)
  HP_DOWN = {
      name: "hp_down_pup",
      stats: {
          hp: -1
      }
  }

  #### EXAMPLE ### (unused)
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
  # **** POWERUP SPAWNERS ****
  #-------------------------------------------------------------------------------


  ## NIVEL 1 (pag 1) ----------------------------------------------------------
  LEVEL_1 = {
      name: 'primer level',
      backdrop: 'backdrop',
      player_ship: NAVE_BASE,
      spawner: {
          spawn_cooldown: 50,
          phases: {
              1 => {
                  enemies: [ALIEN1],
                  start: 0,             #time phase can start spawning enemies
              },
              2 => {
                  enemies: [ALIEN2],
                  start: 20,
                  BGM: ["Battle1", 60, 110] #BGM to be played when this phase starts
              },
              3 => {
                  enemies: [ALIEN3],
                  start: 50,
                  BGM: ["Battle3", 60, 110]
              }
          }
      },
      powerup_spawner: {
          frequency: 5,
          phases: {
              1 => {
                  powerups: [REPAIR_PUP, BALL_WEAPON_CHANGE_PUP, LAZOR_WEAPON_CHANGE_PUP, NUKE_PUP],
              },
              2 => {
                  powerups: [RESET_PUP],
                  timer: 300
              }
          },
      },
      BGM: ["Battle2", 60, 110],
      target_score: 150
  }


  ## NIVEL 2 (pag 4) ----------------------------------------------------------

  LEVEL_2 = {
      name: 'segundo level',
      backdrop: 'backdrop',
      player_ship: NAVE_BASE,
      spawner: {
          spawn_cooldown: 50,
          phases: {
              1 => {
                  enemies: [ALIEN1],
                  start: 0,             #time phase can start spawning enemies
              },
              2 => {
                  enemies: [ALIEN2_DURO],
                  start: 20,
                  BGM: ["Battle1", 60, 110] #BGM to be played when this phase starts
              },
              3 => {
                  enemies: [ALIEN3],
                  start: 50,
                  BGM: ["Battle3", 60, 110]
              }
          }
      },
      powerup_spawner: {
          frequency: 3,
          phases: {
              1 => {
                  powerups: [REPAIR_PUP, BALL_WEAPON_CHANGE_PUP, LAZOR_WEAPON_CHANGE_PUP, NUKE_PUP],
              },
              2 => {
                  powerups: [RESET_PUP],
                  timer: 200
              }
          },
      },
      BGM: ["Battle2", 60, 110],
      target_score: 220
  }


  ## NIVEL 3 (pag 7) ----------------------------------------------------------

  LEVEL_3 = {
      name: 'tercer level',
      backdrop: 'backdrop',
      player_ship: NAVE_BASE,
      spawner: {
          spawn_cooldown: 50,
          phases: {
              1 => {
                  enemies: [NAVE_TIERRA1],
                  start: 0,             #time phase can start spawning enemies
              },
              2 => {
                  enemies: [NAVE_TIERRA2],
                  start: 20,
                  BGM: ["Battle1", 60, 110] #BGM to be played when this phase starts
              },
              3 => {
                  enemies: [NAVE_TIERRA3],
                  start: 50,
                  BGM: ["Battle3", 60, 110]
              }
          }
      },
      powerup_spawner: {
          frequency: 3,
          phases: {
              1 => {
                  powerups: [REPAIR_PUP, BALL_WEAPON_CHANGE_PUP, LAZOR_WEAPON_CHANGE_PUP, NUKE_PUP],
              },
              2 => {
                  powerups: [RESET_PUP],
                  timer: 100
              }
          },
      },
      BGM: ["Battle2", 60, 110],
      target_score: 300
  }

  ## NIVEL 4 (pag 9) ----------------------------------------------------------

  LEVEL_4 = {
      name: 'cuarto level',
      backdrop: 'TIERRA',
      player_ship: NAVE_BASE,
      spawner: {
          spawn_cooldown: 50,
          phases: {
              1 => {
                  enemies: [NAVE_TIERRA1],
                  start: 0,             #time phase can start spawning enemies
              },
              2 => {
                  enemies: [NAVE_TIERRA2],
                  start: 20,
                  BGM: ["Battle1", 60, 110] #BGM to be played when this phase starts
              },
              3 => {
                  enemies: [NAVE_TIERRA3],
                  start: 50,
                  BGM: ["Battle3", 60, 110]
              }
          }
      },
      powerup_spawner: {
          frequency: 3,
          phases: {
              1 => {
                  powerups: [REPAIR_PUP, BALL_WEAPON_CHANGE_PUP, LAZOR_WEAPON_CHANGE_PUP, NUKE_PUP],
              },
              2 => {
                  powerups: [RESET_PUP],
                  timer: 100
              }
          },
      },
      BGM: ["Battle2", 60, 110],
      target_score: 350
  }

  ## NIVEL 5 (pag 13) ----------------------------------------------------------

  LEVEL_5 = {
      name: 'quinto level',
      backdrop: 'TIERRA2',
      player_ship: NAVE_TERRESTRE,
      spawner: {
          spawn_cooldown: 50,
          phases: {
              1 => {
                  enemies: [NAVE_TIERRA1],
                  start: 0,             #time phase can start spawning enemies
              },
              2 => {
                  enemies: [NAVE_TIERRA2],
                  start: 20,
                  BGM: ["Battle1", 60, 110] #BGM to be played when this phase starts
              },
              3 => {
                  enemies: [NAVE_TIERRA3],
                  start: 50,
                  BGM: ["Battle3", 60, 110]
              }
          }
      },
      powerup_spawner: {
          frequency: 3,
          phases: {
              1 => {
                  powerups: [REPAIR_PUP, BALL_WEAPON_CHANGE_PUP, LAZOR_WEAPON_CHANGE_PUP, NUKE_PUP],
              },
              2 => {
                  powerups: [RESET_PUP],
                  timer: 100
              }
          },
      },
      BGM: ["Battle2", 60, 110],
      target_score: 380
  }

  ## NIVEL 6 (pag 15) ----------------------------------------------------------

  LEVEL_6 = {
      name: 'sexto level',
      backdrop: 'SPACIO',
      player_ship: NAVE_TERRESTRE,
      spawner: {
          spawn_cooldown: 50,
          phases: {
              1 => {
                  enemies: [NAVE_TIERRA1],
                  start: 0,             #time phase can start spawning enemies
              },
              2 => {
                  enemies: [NAVE_TIERRA2],
                  start: 20,
                  BGM: ["Battle1", 60, 110] #BGM to be played when this phase starts
              },
              3 => {
                  enemies: [NAVE_TIERRA3],
                  start: 50,
                  BGM: ["Battle3", 60, 110]
              }
          }
      },
      powerup_spawner: {
          frequency: 3,
          phases: {
              1 => {
                  powerups: [REPAIR_PUP, BALL_WEAPON_CHANGE_PUP, LAZOR_WEAPON_CHANGE_PUP, NUKE_PUP],
              },
              2 => {
                  powerups: [RESET_PUP],
                  timer: 100
              }
          },
      },
      BGM: ["Battle2", 60, 110],
      target_score: 400
  }

  ## NIVEL 7 (pag q2, pag 1) ----------------------------------------------------------

  LEVEL_7 = {
      name: 'septimo level',
      backdrop: 'backdrop',
      player_ship: NAVE_BASE,
      spawner: {
          spawn_cooldown: 2,
          phases: {
              1 => {
                  enemies: [ENEMIGO1_MEDIO],
                  start: 0,             #time phase can start spawning enemies
              },
              2 => {
                  enemies: [ENEMIGO2_MEDIO],
                  start: 20,
                  BGM: ["Battle1", 60, 110] #BGM to be played when this phase starts
              },
              3 => {
                  enemies: [ENEMIGO3_MEDIO],
                  start: 50,
                  BGM: ["Battle3", 60, 110]
              }
          }
      },
      powerup_spawner: {
          frequency: 4,
          phases: {
              1 => {
                  powerups: [REPAIR_PUP, BALL_WEAPON_CHANGE_PUP, LAZOR_WEAPON_CHANGE_PUP, NUKE_PUP],
              },
              2 => {
                  powerups: [RESET_PUP],
                  timer: 90
              }
          },
      },
      BGM: ["Battle2", 60, 110],
      target_score: 520,
      ### La configuracion "pre_config" de abajo se realiza antes de empezar el nivel.
      ## Sirve para hacer mini-configuraciones particulares de un nivel,
      ## sin tener que volver a definir completamente una Nave entera por ejemplo.
      pre_config: lambda {
        IB::NAVE_BASE[:stats][:speed] = 5
        IB::NAVE_BASE[:stats][:hp] = 15
      }
  }


  ## NIVEL 8 (pag q2, pag 5) ----------------------------------------------------------

  LEVEL_8 = {
      name: 'octavo level',
      backdrop: 'spacio2',
      player_ship: NAVE_CAPITAN,
      spawner: {
          spawn_cooldown: 2,
          phases: {
              1 => {
                  enemies: [ENEMIGO1_FACIL],
                  start: 0,             #time phase can start spawning enemies
              },
              2 => {
                  enemies: [ENEMIGO2_FACIL],
                  start: 20,
                  BGM: ["Battle1", 60, 110] #BGM to be played when this phase starts
              },
              3 => {
                  enemies: [ENEMIGO3_FACIL],
                  start: 50,
                  BGM: ["Battle3", 60, 110]
              }
          }
      },
      powerup_spawner: {
          frequency: 3,
          phases: {
              1 => {
                  powerups: [REPAIR_PUP, BALL_WEAPON_CHANGE_PUP, LAZOR_WEAPON_CHANGE_PUP, NUKE_PUP],
              },
              2 => {
                  powerups: [RESET_PUP],
                  timer: 90
              }
          },
      },
      BGM: ["Battle2", 60, 110],
      target_score: 350
  }

  ## NIVEL 9 (pag q2, pag 7) ----------------------------------------------------------

  LEVEL_9 = {
      name: 'noveno level',
      backdrop: 'backdrop',
      player_ship: NAVE_CAPITAN,
      spawner: {
          spawn_cooldown: 2,
          phases: {
              1 => {
                  enemies: [ENEMIGO1_FACIL],
                  start: 0,             #time phase can start spawning enemies
              },
              2 => {
                  enemies: [ENEMIGO2_FACIL],
                  start: 20,
                  BGM: ["Battle1", 60, 110] #BGM to be played when this phase starts
              },
              3 => {
                  enemies: [ENEMIGO3_FACIL],
                  start: 50,
                  BGM: ["Battle3", 60, 110]
              }
          }
      },
      powerup_spawner: {
          frequency: 3,
          phases: {
              1 => {
                  powerups: [REPAIR_PUP, BALL_WEAPON_CHANGE_PUP, LAZOR_WEAPON_CHANGE_PUP, NUKE_PUP],
              },
              2 => {
                  powerups: [RESET_PUP],
                  timer: 90
              }
          },
      },
      BGM: ["Battle2", 60, 110],
      target_score: 400,
      ### La configuracion "pre_config" de abajo se realiza antes de empezar el nivel.
      ## Sirve para hacer mini-configuraciones particulares de un nivel,
      ## sin tener que volver a definir completamente una Nave entera por ejemplo.
      pre_config: lambda {
        IB::NAVE_CAPITAN[:stats][:hp] = 8
        IB::NAVE_CAPITAN[:stats][:speed] = 5
      }
  }


  ## NIVEL 10 (poseidon, nivel 1 de 3)

  LEVEL_10 = {
      name: 'decimo level',
      backdrop: 'spacio',
      player_ship: NAVE_BASE,
      spawner: {
          spawn_cooldown: 50,
          phases: {
              1 => {
                  enemies: [ALIEN1],
                  start: 0,             #time phase can start spawning enemies
              },
              2 => {
                  enemies: [ALIEN2_DURO],
                  start: 20,
                  BGM: ["Battle1", 60, 110] #BGM to be played when this phase starts
              },
              3 => {
                  enemies: [ALIEN3],
                  start: 50,
                  BGM: ["Battle3", 60, 110]
              }
          }
      },
      powerup_spawner: {
          frequency: 5,
          phases: {
              1 => {
                  powerups: [REPAIR_PUP, BALL_WEAPON_CHANGE_PUP, LAZOR_WEAPON_CHANGE_PUP, NUKE_PUP],
              },
              2 => {
                  powerups: [RESET_PUP],
                  timer: 90
              }
          },
      },
      BGM: ["Battle2", 60, 110],
      target_score: 9999, ## infinito (modo survival),
      ### La configuracion "pre_config" de abajo se realiza antes de empezar el nivel.
      ## Sirve para hacer mini-configuraciones particulares de un nivel,
      ## sin tener que volver a definir completamente una Nave entera por ejemplo.
      pre_config: lambda {
        IB::NAVE_BASE[:stats][:speed] = 6
      }
  }


  ## NIVEL 11 (poseidon, nivel 2 de 3) ----------------------------------------------------------

  LEVEL_11 = {
      name: 'onceavo level',
      backdrop: 'backdrop',
      player_ship: NAVE_BASE,
      spawner: {
          spawn_cooldown: 50,
          phases: {
              1 => {
                  enemies: [NAVE_TIERRA1],
                  start: 0,             #time phase can start spawning enemies
              },
              2 => {
                  enemies: [NAVE_TIERRA2],
                  start: 20,
                  BGM: ["Battle1", 60, 110] #BGM to be played when this phase starts
              },
              3 => {
                  enemies: [NAVE_TIERRA3],
                  start: 50,
                  BGM: ["Battle3", 60, 110]
              }
          }
      },
      powerup_spawner: {
          frequency: 5,
          phases: {
              1 => {
                  powerups: [REPAIR_PUP, BALL_WEAPON_CHANGE_PUP, LAZOR_WEAPON_CHANGE_PUP, NUKE_PUP],
              },
              2 => {
                  powerups: [RESET_PUP],
                  timer: 90
              }
          },
      },
      BGM: ["Battle2", 60, 110],
      target_score: 9999, ## infinito (modo survival)
      ### La configuracion "pre_config" de abajo se realiza antes de empezar el nivel.
      ## Sirve para hacer mini-configuraciones particulares de un nivel,
      ## sin tener que volver a definir completamente una Nave entera por ejemplo.
      pre_config: lambda {
        IB::NAVE_BASE[:stats][:speed] = 4
      }

  }


  ## NIVEL 12 (poseidon, nivel 3 de 3) ----------------------------------------------------------


  LEVEL_12 = {
      name: 'doceavo level',
      backdrop: 'tierra',
      player_ship: NAVE_CAPITAN,
      spawner: {
          spawn_cooldown: 50,
          phases: {
              1 => {
                  enemies: [ENEMIGO1_DIFICIL],
                  start: 0,             #time phase can start spawning enemies
              },
              2 => {
                  enemies: [ENEMIGO2_DIFICIL],
                  start: 20,
                  BGM: ["Battle1", 60, 110] #BGM to be played when this phase starts
              },
              3 => {
                  enemies: [ENEMIGO3_DIFICIL],
                  start: 50,
                  BGM: ["Battle3", 60, 110]
              }
          }
      },
      powerup_spawner: {
          frequency: 5,
          phases: {
              1 => {
                  powerups: [REPAIR_PUP, BALL_WEAPON_CHANGE_PUP, LAZOR_WEAPON_CHANGE_PUP, NUKE_PUP],
              },
              2 => {
                  powerups: [RESET_PUP],
                  timer: 90
              }
          },
      },
      BGM: ["Battle2", 60, 110],
      target_score: 9999, ## infinito (modo survival)
      ### La configuracion "pre_config" de abajo se realiza antes de empezar el nivel.
      ## Sirve para hacer mini-configuraciones particulares de un nivel,
      ## sin tener que volver a definir completamente una Nave entera por ejemplo.
      pre_config: lambda {
        IB::NAVE_CAPITAN[:stats][:speed] = 6
        IB::NAVE_CAPITAN[:stats][:hp] = 5
      }

  }

  ## Los niveles se sacaron en orden de:
  # pagina quests: (primera)
  # 1,4 , 7, 9, 13, 15
  # pagina q2:
  # 1, 5, 7
  #
  # ventana base poseidon
  # pagina 6 -> 3 niveles mas

  ##OPCION 1 - DEFINICION BASE DE TOD0 ------------------------------------------
  # (elegida actualmente, todos los niveles se han definido arriba)

  #OPCION 2 - DEFINIR PUNTUALMENTE CADA MODIFICACION PARTICULAR -----------------
  # (se eligio la OPCION 1, pero esto igual se puede hacer en los campos
  #   de cada nivel "pre_config" y tambien puede agregarse "post_config" por ej.
  #   para volver atras algun cambio del nivel particular)

  # IB::NAVE_BASE[:stats][:speed] = 4
  # IB::NAVE_BASE[:stats][:hp] = 12
  # IB::NAVE_BASE[:weapon][:cooldown] = 12
  # IB::LAZOR_WEAPON[:stats][:speed] = 20
  # IB::ENEMIGO1[:hp] = 1
  # IB::ENEMIGO2[:hp] = 3
  # IB::ENEMIGO3[:hp] = 10
  # IB::CURRENT_LEVEL[:powerup_spawner][:frequency] = 3

  #-------------------------------------------------------------------------------
  #  OTHER CONFIG
  #-------------------------------------------------------------------------------

  GRAPHICS_ROOT = "Graphics/Invaders/"

  BGM = ["Battle2", 50, 110] #musica de fondo: ["BGM_Name",volume,pitch]
  ME_WIN = ["Victory2", 100, 110]
  ME_LOSS = ["Gameover2", 100, 110]

  DSE = ["Fire3",90,150]  # "SE_Name",volume,pitch - SE for enemy dying

  SCORE_VAR = 55         # Variable id to keep track of score
  HIGH_SCORE_VAR = 56    # Variable id to keep track of highest score

  SOUND_TIMER = 5       # Prevent enemy lazor sound spam by increasing this

  # DEBUG = {
  #     # borders: true  ## draw rectangle borders
  #     logger_level: 5, # 0 NONE, 1 ERROR, 2 WARN, 3 INFO (recommended), 4 DEBUG, 5 TRACE
  #     console: false,   # show console with log messages
  #     test_levels: true,
  #     logger_toggle_key: :F9
  # }

  #-------------------------------------------------------------------------------
  #  BUILD GAME
  #-------------------------------------------------------------------------------

  ### LEVELS: Conjunto de niveles disponibles.
  # solo figuran como disponibles los niveles que aqui aparecen, se pueden agregar, sacar, o reordenar aqui mismo.
  # Lo importante es que el nombre sea igual que el que se uso para definirlo por primera vez, mas arriba.
  LEVELS = [LEVEL_1, LEVEL_2, LEVEL_3, LEVEL_4, LEVEL_5, LEVEL_6, LEVEL_7, LEVEL_8, LEVEL_9, LEVEL_10, LEVEL_11, LEVEL_12]

  CURRENT_LEVEL_VAR = 50 # Variable id con referencia al numero de nivel a elegir (empieza a contar desde 1)
  LEVEL_RESULT_VAR = 60 ## Variable id donde se guarda el resultado del nivel ("win", "loss" o "incomplete", por ahora)

end
#------------------------------------------------------------------------------#
#  SCRIPT CALL:
#------------------------------------------------------------------------------#
#  SceneManager.call(Scene_Invaders_Boss)       # Starts the minigame.
#  v1.0.0
#------------------------------------------------------------------------------#

# Boss game script, once called, launches a level with a fight against
# a configured boss.

module IB_BOSS

  #------------------------------------------------------------------------------#
  #  SCRIPT SETTINGS
  #------------------------------------------------------------------------------#


  #----------------#
  # BOSS OPTIONS   #
  #----------------#

  BOSS_HP = 20
  BOSS_SPEED = 2


  BOSS_DIFFICULTY_INCREASE_INTERVAL = 20 # Tiempo cada cuanto se incrementa la probabilidad de disparo del jefe
  BOSS_DIFFICULTY_INCREASE_AMOUNT = 1 # Valor en que se aumenta la probabilidad de disparos del jefe terminado el intervalo

  BOSS_INITIAL_DIFFICULTY = 5 # Dificultad inicial

  BOSS_GUNS_MIN = 1 # minimum number of bullets boss can shoot
  BOSS_GUNS_MAX = 5 # maximum number of bullets boss can shoot

  BOSS_LAZOR_SPEED = 5

  BOSS_MAX_Y = 0.5  # Boss maximum height "y"  (en porcentaje de altura del mapa)
  BOSS_MIN_Y = 0.3 # boss minimum height "y"

  # TIME_BOSS_DOWN = 90 #tiempo maximo que el boss estara abajo (random de 1 a N) POR AHORA NO FUNCA
  # TIME_BOSS_UP = 90 #tiempo maximo que el boss estara arriba (random de 1 a N) POR AHORA NO FUNCA

  #----------------#
  # PLAYER OPTIONS #
  #----------------#

  PLAYER_SHIELDS = 30  # Hits player can take before game over

  SHOOTING_COOLDOWN = 5 #cooldown entre cada tiro
  MAX_SHOTS = 10    # Maxium number of shots player can have on screen at a time
  MAX_GUN_LEVEL = 5 # Max gun powerup level (5 is the highest)

  SE = ["Attack2",80,150]  # "SE_Name",volume,pitch - SE for player laser
  SE1 = ["Heal5",80,160]  # "SE_Name",volume,pitch - SE for player lazorball
  NSE = ["Explosion3",120,100]  # "SE_Name",volume,pitch - SE for nuke

  PSE = ["Damage5",90,150]  # "SE_Name",volume,pitch - SE when player damaged
  KSE = ["Explosion7",100,100]  # "SE_Name",volume,pitch - SE when destroyed

  BSE = ["Down4",120,150]  # "SE_Name",volume,pitch - SE when bonus shield gain
  PUSE = ["Item1",80,150]  # "SE_Name",volume,pitch - SE when get powerup

  SHIP_SPEED = 5        # Speed at which player can move ship left and right
  LAZOR_SPEED = 5       # Speed the lazor fires


  #---------------#
  # ENEMY OPTIONS #
  #---------------#


  SPAWN_SPEED = 100    # Lower means faster spawn. Higher is slower spawn.

  LEVEL2 = 20          # Seconds until level 2 ships can start spawning
  LEVEL3 = 50         # Seconds until level 3 ships can start spawning
  LEVEL4 = 80         # Seconds until level 3 ships can start spawning

  LEVEL1_HP = 1        # Level 1 enemies have this much hp
  LEVEL2_HP = 3        # Level 2 enemies have this much hp
  LEVEL3_HP = 6        # Level 3 enemies have this much hp
  LEVEL4_HP = 12       # Level 4 enemies have this much hp

  ELAZOR_SPEED = 5     # Enemy lazor speed

  ASE = ["Attack2",80,110]  # "SE_Name",volume,pitch - SE for enemy shooting
  DSE = ["Fire3",90,150]  # "SE_Name",volume,pitch - SE for enemy dying


  #---------------#
  # OTHER OPTIONS #
  #---------------#

  SCORE_VAR = 100         # Variable id to keep track of score
  HIGH_SCORE_VAR = 101    # Variable id to keep track of highest score

  AVAILABLE_PUPS = [0,1,2] #  Available pups on map. 0 heal  1 lazor  2 lazerball  3 nuke  999 reset

  POWERUP_FREQUENCY = 2   # Frecuencia en la q aparecen pups,
  # entre mayor numero, mayor PROBABILIDAD de que aparezca.
  # si es 0 entonces no aparece ninguno.

  RESET_PUP = 40        # Seconds between reset powerup spawns. If the
  # player manages to get this, the enemy spawn rate is
  # reset and has a chance to earn more points!
  RESET_AMOUNT = 0.5    # Ratio of difficulty when reset powerup is obtained

  SOUND_TIMER = 5       # Prevent enemy lazor sound spam by increasing this

  DESTROY_PUPS = false      # Can destroy powerups true or false

  LAZOR_DAMAGE = 1      # Damage done when ENEMY lazors hit player
  COLLIDE_DAMAGE = 2    # Damage done when collide with enemy


  BGM = ["Battle2", 150, 110] #musica de fondo: ["BGM_Name",volume,pitch]
  ME_WIN = ["Victory2", 100, 110]
  ME_LOSS = ["Gameover2", 100, 110]

  GRAPHICS_ROOT = "Graphics/Invaders/"

  #Nombre de las imagenes, no incluir la terminacion .png
  FONDO = "backdrop"

  NAVE_PLAYER = "player"

  NAVE_ENEMIGO = "alien" #debe haber un tipo único por nivel (por
  #ej "alien", esto se puede redefinir), y en el directorio, los 3
  #empezar con el mismo nombre, y los 3 terminar
  #con 0, 1 o 2, por ej. "alien0.jpg",
  #"alien1.png", "alien2.jpg".


  #------------------------------------------------------------------------------#
  #  END OF SCRIPT SETTINGS
  #------------------------------------------------------------------------------#
end


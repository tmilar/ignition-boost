module IB

  #-------------------------------------------------------------------------------
  #  DEFINE GAME VARIABLES
  #-------------------------------------------------------------------------------

  #-------------------------------------------------------------------------------
  # **** WEAPONS ****
  #-------------------------------------------------------------------------------

    #TODO definir :phases , evolucion de las armas con pups - u otras condiciones
    #TODO definir :type & :subtype
  WEAPON1 = {
      name: "lazor1",         # weapon name (also lazor image '.png' name)
      type: "lazor",          # weapon type // por ahora no hace nada //
      stats: {
          damage: 1,              # bullet damage
          speed: 5,               # bullet speed
      },
      direction: [0, -1],     # Initial direction for bullets [x, -y]
      cooldown: 5,            # time to wait before shooting again
      SE: ["Attack2",80,150], # sound when shooting
      # level: 1,             # starting weapon level (optional, default 1)
  }

  WEAPON2 = {
      name: "lazor2",         # weapon name (also lazor image '.png' name)
      type: "ball",
      stats: {
          damage: 1,              # bullet damage
          speed: 5,               # bullet speed
      },
      direction: [0, -1],     # Initial direction for bullets [x, -y]
      level: 1, # starting weapon level (optional)
      cooldown: 5,
      SE: ["Heal5",80,160]
  }

  #-------------------------------------------------------------------------------
  # **** SHIPS ****
  #-------------------------------------------------------------------------------

  # default config for base PLAYER ship
  NAVE_BASE = {
      :name => "player_ship",
      :stats => {
          :power => 1,
          :speed => 5,
          :hp => 5,
          :collide_damage => 99,
          :collide_resistance => 0,
          :shoot_freq => 0,             ## TODO por ahora esto remplazara la @difficulty
          :nuke_power => 99            # Damage caused by nuke
      },
      :weapon => WEAPON1
  }

  #-------------------------------------------------------------------------------
  # **** ENEMIES ****
  #-------------------------------------------------------------------------------


  # basic enemy ship config
  ENEMIGO1 = {
      :name => "alien1",
      :stats => {
          :power => 1,
          :speed => 1,
          :hp => 2,
          :collide_damage => 4,
          :shoot_freq => 6,             ## TODO por ahora esto remplazara la @difficulty
      },
      :weapon => {
          name: "elazor1",
          :type => "elazor",
          stats: {
              damage: 1,              # bullet damage
              speed: 5,               # bullet speed
          },
          :SE => ["Attack2",80,110],
          :direction => [0, 1],     # Initial direction for bullets [x, -y]
      },
      :DSE => ["Fire3",90,150], # "SE_Name",volume,pitch - SE for enemy dying
      # :movement => :linear_movement #### TODO! DEFINIR BIEN los MOVEMENT STYLES
  }

  # basic enemy ship config
  ENEMIGO2 = {
      :name => "alien2",
      :stats => {
          :power => 1,
          :speed => 1,
          :hp => 3,
          :collide_damage => 4,
          :shoot_freq => 10,             ## TODO por ahora esto remplazara la @difficulty
      },
      :power => 1,
      :speed => 1,
      :hp => 3,
      :weapon => {
          name: "elazor2",
          :type => "elazor",
          stats: {
              damage: 1,              # bullet damage
              speed: 5,               # bullet speed
          },
          :SE => ["Attack2",80,110],
          :direction => [0, 1],     # Initial direction for bullets [x, -y]
      },
      :DSE => ["Fire2",90,150], # "SE_Name",volume,pitch - SE for enemy dying
  }

  BOSS1 = {
      :name => "boss1",
      :stats => {
          :power => 1,
          :speed => 1,
          :hp => 3,
          :collide_damage => 9999,
          :collide_resistance => 9999,
          :shoot_freq => 15,             ## TODO por ahora esto remplazara la @difficulty
      },
      :weapon => {
          :type => "elazor",
          stats: {
              damage: 2,              # bullet damage
              speed: 6,               # bullet speed
          },
          :direction => [0, 1],     # Initial direction for bullets [x, -y]
      },
      :position => {
          max_y: 0.5,
          min_y: 0.3
      }
  }

  #-------------------------------------------------------------------------------
  # **** LEVELS ****
  #-------------------------------------------------------------------------------


  LEVEL1 = {
      name: 'first level',
      backdrop: 'backdrop',
      spawner: {
          spawn_cooldown: 50,
          phases: {
              1 => {
                  enemies: [ENEMIGO1, ENEMIGO2],
                  start: 0,             #time phase can start spawning enemies
              },
              2 => {
                  enemies: [ENEMIGO2],
                  start: 4,
                  end: 10,
                  BGM: ["Battle1", 60, 110] #BGM to be played when this phase starts
              },
              3 => {
                  enemies: [BOSS1],
                  start: 8,
                  max_spawn: 1,
                  BGM: ["Battle3", 60, 110]
              }
          }
      },
      BGM: ["Battle2", 60, 110],
      target_score: 50
  }

  ### EXAMPLES ###
  # PowerUps.
  # Los powerUp multiplican o suman a un stat. Si el valor es +ENTERO o -ENTERO, sera suma/resta.
  # Si es DECIMAL (con "punto" - de 0.0 en adelante) es un factor que se MULTIPLICA. Ej. 0.1, 1.5, 2.0, etc..
  # Por ahora ademas, lo que puede cambiar es>
  # >>> del JUEGO ->  spawn_cooldown  ; y  stats de naves
  RESET_PUP = {
      name: "powerup4",
      target: "enemies",
      spawn_cooldown: 0.5, # Factor to multiply current spawner "spawn_cooldown"
      stats: {
          shoot_freq: 0.5     # Factor to multiply current level ALL enemies "shoot_freq"
      },
  }
  REPAIR_PUP = {
      name: "powerup0",     # PowerUp name, also must match image name
      target: "player",     # Target : "player", o "enemies" . DEFAULT: "player"
      stats: {              # stats that will change
          hp: +100
      },
      frequency: 20         # [Optional] frequency pup will appear. Default: upper spawner frequency
  }
  WEAPON_UP = {
      name: "powerup1",
      target: "player",
      weapon: {
          level: +1
      }
  }

  MY_POWERUP_LEVEL = {
      backdrop: 'backdrop',           # FONDO imagen .jpg
      name: 'first_level',            # Level name - Solo estetico.
      BGM: ['Battle2', 60, 110],
      target_score: 50,
      spawner: {
          spawn_cooldown: 100,            # Default 100 (mismo que Galv SPAWN_SPEED)
          spawn_decrement_amount: 1,      # Default 1 (mismo que Galv.. antes no era modificable)
          spawn_decrement_freq: 100,      # Default 100 (mismo que Galv.. antes no era modificable)
          phases: {
              1 => {
                  enemies: [ENEMIGO1, ENEMIGO2],
                  start: 0, # time when phase can start spawning enemies
                  spawn_cooldown: 150, # phases can use different spawn_cooldowns
                  spawn_decrement_amount: 1,
                  spawn_decrement_freq: 60
              },
              2 => {
                  enemies: [ENEMIGO2],
                  start: 15         # time when phase can start spawning enemies
              }
          }
      },
      powerup_spawner: {
          frequency: 15,               # DEFAULT "base" powerup frequency. 0 equals no pups (EXCEPT those that specify other number)
          phases: {                    # Powerup spawner can also have phases!
              1 => {
                  powerups: [REPAIR_PUP, WEAPON_UP],
              }
          },
          destructible?: false         # Can pups can be destroyed by bullets?
      }
  }

  #### MORE EXAMPLES ###
  SPEED_UP = {
      name: "speed_pup",
      stats: {
          speed: +1
      },
  }

  SLOW_ENEMY_PUP = {
      name: "slower_enemies_pup",
      target: "enemies",
      stats: {
          speed: -1
      },
  }

  # Items are also a kind of powerup but with some key "effect" to distinguish
  NUKEALL_ITEM = {
      name: "item_nuke",
      target: "player",
      hold: true,
      effect: "nuke"    # keyword for item type
  }

  # Weapon change power up. Will change current weapon with other one...
  WEAPON2_CHANGE_PUP = {
      name: "powerup2",
      target: "player",
      weapon: WEAPON2      # Weapon to change. If weapon is repeated, level will go up +1 instead.
  }

  WEAPON1_CHANGE_PUP = {
      target: "player",
      name: "powerup3",
      weapon: WEAPON1
  }





  #-------------------------------------------------------------------------------
  # **** PUPS  **** //TODO define  & include in Levels
  #-------------------------------------------------------------------------------

  #-------------------------------------------------------------------------------
  #  OTHER CONFIG
  #-------------------------------------------------------------------------------

  GRAPHICS_ROOT = "Graphics/Invaders/"

  ## TODO use Sound handler hash, for sounds/music definitions?
  BGM = ["Battle2", 50, 110] #musica de fondo: ["BGM_Name",volume,pitch]
  ME_WIN = ["Victory2", 100, 110]
  ME_LOSS = ["Gameover2", 100, 110]

  DSE = ["Fire3",90,150]  # "SE_Name",volume,pitch - SE for enemy dying

  SCORE_VAR = 100         # Variable id to keep track of score
  HIGH_SCORE_VAR = 101    # Variable id to keep track of highest score

  SOUND_TIMER = 5       # Prevent enemy lazor sound spam by increasing this

  #-------------------------------------------------------------------------------
  #  BUILD GAME
  #-------------------------------------------------------------------------------

  CURRENT_LEVEL = LEVEL1
  PLAYER_SHIP = NAVE_BASE

end

class Main_IB < Scene_Base

  @@game_time = 0
  @@frames_in_second = 0

  def start
    $game_system.save_bgm
    super
    SceneManager.clear
    Graphics.freeze
    initialize_game
  end

  def initialize_game
    configure
    init_variables
    init_screen
    start_level
  end


  def configure
    Cache.relative_path(IB::GRAPHICS_ROOT)
    Sprite.setup_viewport(@viewport1)
  end

  def init_variables
    @@game_time = 0
    @@start_time = Time.now
    @@old_second = -1
    @@current_second = @@start_time.sec
    @@frames_in_second = 0
  end

  def init_screen
    @screen = Screen.new(@viewport1)
  end


  def start_level
    Logger.info("Starting new level: #{IB::CURRENT_LEVEL[:name]}")
    @level = Level.new(IB::CURRENT_LEVEL, IB::PLAYER_SHIP)
    @level.screen_observe(@screen)
    Logger.debug("Configured level >> #{@level}")
  end

  def update
    super
    @@game_time += 1
    update_frames_in_second

    update_level
    update_screen
    check_exit
  end

  def update_frames_in_second
    @current_second = Time.now.sec
    @@frames_in_second = 0 if @old_second != @current_second
    @@frames_in_second += 1
    @old_second = @current_second
  end

  def check_exit
    if Input.trigger?(:B)
      SceneManager.goto(Scene_Map)
    end
  end

  def update_screen
    @screen.update
  end

  def update_level
    @level.update
  end


  def terminate
    super
    SceneManager.snapshot_for_background
    dispose_graphics
    $game_system.replay_bgm
  end

  def dispose_graphics
    @level.dispose
    @screen.dispose
    Logger.info( "<< FAKE >> all graphics disposed!!")
  end


  def self.game_time
    @@game_time / 60
  end

  def self.elapsed_time
    ((Date.now - @@start_time)*1000.0).to_i
  end


  def self.frames_in_second
    @@frames_in_second
  end

end

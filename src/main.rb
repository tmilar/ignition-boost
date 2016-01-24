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
      type: "lazor",          # weapon name (also image '.png' name)
      damage: 1,              # bullet damage
      speed: 5,               # bullet speed
      cooldown: 5,            # time to wait before shooting again
      SE: ["Attack2",80,150]  # sound when shooting
      #level: 1,              # starting weapon level (optional, default 1)

  }

  WEAPON2 = {
      type: "ball",
      damage: 1,
      level: 1, # starting weapon level (optional)
      speed: 5,
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
          :speed => 1,
          :hp => 5,
          :collide_damage => 99,
          :collide_resistance => 0,
          :shoot_freq => 0,             ## TODO por ahora esto remplazara la @difficulty
          :nuke_power => 99            # Damage caused by nuke
      },
      :weapon => {
          type: "lazor",
          damage: 1,
          level: 1, # starting weapon level (optional)
          speed: 5,
          cooldown: 5,
          SE: ["Heal5",80,160]
      },
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
          :shoot_freq => 0,             ## TODO por ahora esto remplazara la @difficulty
      },
      :weapon => {
          :type => "elazor",
          :damage => 1,
          :speed => 5,
          :SE => ["Attack2",80,110]
      },
      :DSE => ["Fire3",90,150], # "SE_Name",volume,pitch - SE for enemy dying
      :shoot_freq => 2, ## TODO por ahora esto remplazara la @difficulty
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
          :shoot_freq => 0,             ## TODO por ahora esto remplazara la @difficulty
      },
      :power => 1,
      :speed => 1,
      :hp => 3,
      :weapon => {
          :type => "elazor",
          :damage => 2,
          :speed => 5,
          :SE => ["Attack2",80,110]
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
          :shoot_freq => 3,             ## TODO por ahora esto remplazara la @difficulty
      },
      :weapon => {
          :type => "elazor",
          :damage => 2,
          :speed => 5
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
      spawn_speed: 100,
      phases: {
          1 => {
              enemies: [ENEMIGO1],
              start: 0          #time phase can start spawning enemies
          },
          2 => {
              enemies: [ENEMIGO2],
              start: 3,
              end: 10,
              BGM: ["Battle1", 60, 110] #BGM to be played when this phase starts
          },
          3 => {
              enemies: [BOSS1],
              start: 7,
              max_spawn: 1,
              BGM: ["Battle3", 60, 110]
          }
      },
      BGM: ["Battle2", 60, 110]
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

    update_level
    update_screen
    check_exit
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
    Logger.info( "<< FAKE >> all graphics disposed!!")
  end


  def self.game_time
    @@game_time / 60
  end

end

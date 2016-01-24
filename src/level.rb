class Level
  include Subject

  # basic enemy ship config
  DEFAULT_ENEMY1 = {
      :name => 'alien1',
      :stats => {
          :power => 1,
          :speed => 1,
          :hp => 2,
          :collide_damage => 4,
          :shoot_freq => 0,             ## TODO por ahora esto remplazara la @difficulty
      },
      :weapon => {
          :name => 'elazor',
          :type => 'elazor',
          :damage => 1,
          :speed => 5,
          :SE => ['Attack2', 80, 110]
      },
      :DSE => ['Fire3', 90, 150], # "SE_Name",volume,pitch - SE for enemy dying
      # :movement => :linear_movement #### TODO! DEFINIR BIEN los MOVEMENT STYLES
  }

  # basic enemy ship config
  DEFAULT_ENEMY2 = {
      :name => 'alien2',
      :stats => {
          :power => 1,
          :speed => 1,
          :hp => 3,
          :collide_damage => 4,
          :shoot_freq => 0,             ## TODO por ahora esto remplazara la @difficulty
      },
      :weapon => {
          :name => 'elazor',
          :type => 'elazor',
          :damage => 2,
          :speed => 5,
          :SE => ['Attack2', 80, 110]
      },
      :DSE => ['Fire2', 90, 150], # "SE_Name",volume,pitch - SE for enemy dying
  }

  DEFAULTS = {
      backdrop: 'backdrop',
      spawn_speed: 100,
      name: 'first_level',
      phases: {
          1 => {
              enemies: [DEFAULT_ENEMY1],
              start: 0          # time when phase can start spawning enemies
          },
          2 => {
              enemies: [DEFAULT_ENEMY2],
              start: 35         # time when phase can start spawning enemies
          }
          # 3 => {
          #     enemies: [BOSS1],
          #     start: 100,
          #     max_spawn: 1,
          #     BGM: ["Battle3", 60, 110]
          # }
      },
      BGM: ['Battle2', 60, 110],
      target_score: 50
  }

  attr_reader :player


  def initialize(level_options = {}, player_ship = {})
    #config setup
    level_options[:player_ship] = player_ship
    Logger.trace("starter level opts: #{level_options}")
    Logger.start('level', level_options, DEFAULTS)
    @config = DEFAULTS.merge(level_options).deep_clone

    Logger.trace("initializing level with config: #{@config}")

    super(@config)
    play_bgm
    init_level_graphics
    init_game_helpers
  end

  def play_bgm
    Sound.bgm(@config[:BGM])
  end

  def init_game_helpers
    @spawner = Spawner.new(@config[:spawn_speed], @config[:phases])
    @spawner.add_observer(self)
    @collider = Collider.new
  end

  def init_level_graphics
    Logger.trace("strating lvl graphics...  opts: #{@config}")
    @backdrop = Backdrop.new(@config[:backdrop])
    Logger.trace("Conf for player ... #{@config[:player_ship]}")
    @player = Player.new(@config[:player_ship])
    @player.level_observe(self)
    @enemies = []
    @plazors = []
    @elazors = []
  end

  def update
    @backdrop.update
    @spawner.update

    update_enemies
    update_player
    update_plazors
    update_elazors


    # @collider.update TODO fix collider
  end

  def update_elazors
    @elazors.delete_if { |el|
      el.update
      el.disposed?
    }
  end

  def update_plazors
    @plazors.delete_if { |pl|
      pl.update
      pl.disposed?
    }
  end

  def update_enemies
    @enemies.delete_if { |enemy|  
      # next true if enemy.disposed?
      enemy.update
      enemy.disposed?
    }
  end

  def update_player
    @player.update
  end

  def finished?
    'loss' if @player.nil? || @player.destroyed?
    'win' if @player.score >= @config[:target_score]
    false
  end


  def enemies_update
    @enemies.each { |enemy|  enemy.update }
  end

  def notified(msg, data={})
    reactions = {
        'new_enemy' => lambda { |enemy| add_new_enemy(enemy) }
    }
    reactions[msg].call(data)
  end

  def add_new_enemy(enemy)
    raise 'New enemy is nil!' if enemy.nil?
    Logger.debug("New enemy #{enemy.name} entered level #{@config[:name]}.")
    @enemies << enemy
  end

end
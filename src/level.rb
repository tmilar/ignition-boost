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

  def notified(msg, data={})
    reactions = {
        'new_enemy' => lambda { |enemy| add_new_enemy(enemy) },
        'new_lazors' => lambda { |lazors| add_new_lazors(lazors)},
        'enemy_hit' => lambda { |enemy| check_enemy_hp(enemy)},
        'player_hit' => lambda { |_| check_player_hp },
        'player_disposed' => lambda { |_| init_game_over("loss")},
        'enemy_disposed' => lambda { |enemy| handle_enemy_disposed(enemy)}

    }
    reactions[msg].call(data)
  end

  def handle_enemy_disposed(enemy)
    @player.score += enemy.stats[:mhp]
    notify_observers("game-over", "win") if @player.score >= @config[:target_score]
  end

  def check_player_hp
    @player.dispose if @player.stats[:hp] <= 0
  end

  def check_enemy_hp(enemy)
    enemy.dispose if enemy.stats[:hp] <= 0
  end

  def init_game_over(result)
    @screen.init_game_over(result)
  end


  def add_new_enemy(enemy)
    raise 'New enemy is nil!' if enemy.nil?
    Logger.debug("New enemy #{enemy.name} entered level #{@config[:name]}.")
    Logger.trace("Enemy is... #{enemy}. Ancestors: #{enemy.class.ancestors}")
    enemy.level_observe(self)
    @enemies << enemy
  end

  def add_new_lazors(data)
    raise 'Lazor(s) are empty or nil!' if data[:lazors].nil_empty?
    Logger.trace("New lazors were shooted!!! data received: #{data}")
    case data[:data][:shooter]
      when 'player' then @plazors.push(*data[:lazors])
      when 'enemy'  then @elazors.push(*data[:lazors])
    end

    Logger.trace("Level lazors present: Plazors > #{@plazors} | Elazors > #{@elazors}")
  end

  def dispose
    @backdrop.dispose
    @player.dispose
  end

  def screen_observe(screen)
    @player.add_observer(screen)
    self.add_observer(screen)
  end

end
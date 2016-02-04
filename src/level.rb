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
          :shoot_freq => 0,               # Start shooting frequency for enemy
          :shoot_increment => 1,          # Shooting frequency increment - cada cierto tiempo se suma esta cantidad
          :shoot_increment_rate => 100    # Cada cuanto tiempo se aplica el SHOOT_INCREMENT al SHOOT_FREQ
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
          :shoot_increment => 1,
          :shoot_increment_freq => 100
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
                  enemies: [DEFAULT_ENEMY1],
                  start: 0, # time when phase can start spawning enemies
                  spawn_cooldown: 150, # phases can use different spawn_cooldowns
                  spawn_decrement_amount: 1,
                  spawn_decrement_freq: 100
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
      },
      powerup_spawner: {
          frequency: 50,              # DEFAULT "base" powerup frequency. 0 equals no pups (EXCEPT those that specify other number)
          destructible?: false,       # Can pups can be destroyed by bullets?
          phases: {                   # PowerUp spawner can also be divided in Phases (or use one only)
              # 1 => {
              #     powerups: []
              # }
          }
      }
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
    init_spawners
  end

  def play_bgm
    Sound.bgm(@config[:BGM])
  end

  def init_spawners
    spawner_config = @config[:spawner]

    @enemy_spawner = Spawner.new(spawner_config)
    @enemy_spawner.add_observer(self)
    @pup_spawner = PowerUpSpawner.new(@config[:powerup_spawner])
    @pup_spawner.add_observer(self)
  end

  def init_level_graphics
    Logger.trace("strating lvl graphics...  opts: #{@config}")
    @backdrop = Backdrop.new(@config[:backdrop])
    Logger.trace("Conf for player ... #{@config[:player_ship]}")
    @player = Player.new(@config[:player_ship])
    @player.level_observe(self)
    @player.update
    @enemies = []
    @plazors = []
    @elazors = []
    @explosions = []
    @pups = [] << PowerUp.new({
                                  name: "powerup1",
                                  target: "player",
                                  weapon: {
                                      level: +1
                                  }
                              })
  end

  def update
    @backdrop.update
    @enemy_spawner.update

    update_enemies
    update_player
    update_plazors
    update_elazors
    update_explosions
    update_pups
    update_pup_spawner
  end

  def update_pup_spawner
    @pup_spawner.update
  end

  def update_pups
    @pups.each_with_index { |pup,i|
      if pup.disposed?
        @pups.delete_at(i)
        next
      end
      pup.update
      Collider.check_pup(pup, @player)
    }
  end

  def update_explosions
    @explosions.each_with_index { |e,i|
      if e.disposed?
        @explosions.delete_at(i)
        next
      end
      e.update
    }
  end

  def update_elazors
    @elazors.each_with_index { |el,i|
      if el.disposed?
        @elazors.delete_at(i)
        next
      end
      el.update
      Collider.check_lazor(el, @player)
    }
  end

  def update_plazors
    @plazors.each_with_index { |pl,i|
      # return true if pl.disposed?
      if pl.disposed?
        @plazors.delete_at(i)
        next
      end
      pl.update
    }
  end

  def update_enemies
    @enemies.each_with_index { |enemy,i|
      if enemy.disposed?
        @enemies.delete_at(i)
        next
      end
      enemy.update
      Collider.check_enemy_player(enemy, @player)
      Collider.check_enemy_plazors(enemy, @plazors)
    }
  end

  def update_player
    @player.update unless @player.disposed?
  end

  def notified(msg, data={})
    reactions = {
        'new_enemy' => lambda { |enemy| add_new_enemy(enemy) },
        'new_lazors' => lambda { |lazors| add_new_lazors(lazors)},
        'new_powerup' => lambda { |pup| add_new_powerup(pup)},
        'player_destroyed' => lambda { |_| init_game_over("loss")},
        'enemy_destroyed' => lambda { |enemy| handle_enemy_destroyed(enemy)},
        'player_hit' => lambda { |elazor| elazor.dispose },
        'enemy_hit' => lambda { |lazor| lazor.dispose },
        'score' => lambda { |_| check_score_win },
        'powerup_grabbed' => lambda { |pup| apply_powerup(pup)},
    }
    Logger.trace("Level received notification '#{msg}', with data #{data}... #{"But is not considered." unless reactions.key?(msg)}")
    reactions[msg].call(data) if reactions.key?(msg)
  end

  def add_new_powerup(pup)
    raise 'New enemy is nil!' if pup.nil?
    Logger.debug("New enemy #{pup.name} #{pup} entered level #{@config[:name]}.")
    @pups << pup
  end

  def apply_powerup(pup)
    pup_effect = pup.effect
    target = pup.target
    case target
      when "player" then @player.apply_pup(pup_effect)
      when "enemies" then @enemies.each { |e| e.apply_pup(pup_effect) }
    end
  end


  def check_score_win
    init_game_over("win") if @player.score >= @config[:target_score]
  end

  def handle_enemy_destroyed(ship_data)
    @explosions << Explosion.new(ship_data)
    @player.score += ship_data[:ship].stats[:mhp]
  end

  def init_game_over(result)
    @enemy_spawner.stop
    notify_observers("game_over", result)
  end


  def add_new_enemy(enemy)
    raise 'New enemy is nil!' if enemy.nil?
    Logger.debug("New enemy #{enemy.name} #{enemy} entered level #{@config[:name]}. Ancestors: #{enemy.class.ancestors}")
    enemy.level_observe(self)
    @enemies << enemy
  end

  def add_new_lazors(data)
    raise 'Lazor(s) are empty or nil!' if data[:lazors].nil_empty?
    Logger.trace("New lazors were shooted!!! data received: #{data}")
    case data[:data][:shooter]
      when 'player' then @plazors.push(*data[:lazors]) unless @plazors.nil?
      when 'enemy'  then @elazors.push(*data[:lazors]) unless @elazors.nil?
    end

    # Logger.trace("Level lazors present: Plazors > #{@plazors} | Elazors > #{@elazors}")
  end

  def dispose
    @backdrop.dispose unless @backdrop.disposed?
    @player.dispose unless @player.disposed?
    @enemies.each { |obj| obj.dispose unless obj.disposed? }
    @plazors.each { |obj| obj.dispose unless obj.disposed? }
    @elazors.each { |obj| obj.dispose  unless obj.disposed? }
    @enemies.each { |obj| obj.dispose  unless obj.disposed? }
    @explosions.each { |obj| obj.dispose  unless obj.disposed? }
    @pups.each { |obj| obj.dispose  unless obj.disposed? }
  end

  def screen_observe(screen)
    @player.add_observer(screen)
    self.add_observer(screen)
  end

end
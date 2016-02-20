class Level
  include Subject
  include Powerupeable

  DEFAULTS = {
      backdrop: 'backdrop',           # FONDO imagen .jpg
      name: 'DEFAULT_LEVEL_NAME',            # Level name - Solo estetico.
      BGM: ['Battle2', 60, 110],
      target_score: 50,
      spawner: {
          spawn_cooldown: 100,            # Default 100 (mismo que Galv SPAWN_SPEED)
          spawn_decrement_amount: 1,      # Default 1 (mismo que Galv.. antes no era modificable)
          spawn_decrement_freq: 100,      # Default 100 (mismo que Galv.. antes no era modificable)
          phases: {
              # 1 => {
              #     enemies: [DEFAULT_ENEMY1],
              #     start: 0, # time when phase can start spawning enemies
              #     spawn_cooldown: 150, # phases can use different spawn_cooldowns
              #     spawn_decrement_amount: 1,
              #     spawn_decrement_freq: 100
              # },
              # 2 => {
              #     enemies: [DEFAULT_ENEMY2],
              #     start: 15         # time when phase can start spawning enemies
              # }
              # 3 => {
              #     enemies: [BOSS1],
              #     start: 100,
              #     max_spawn: 1,
              #     BGM: ["Battle3", 60, 110]
              # }
          },
      },
      powerup_spawner: {
          # frequency: 0,              # DEFAULT "base" powerup frequency. 0 equals no pups (EXCEPT those that specify other number)
          # destructible?: false,       # Can pups can be destroyed by bullets?
          # phases: {                   # PowerUp spawner can also be divided in Phases (or use one only)
              # 1 => {
              #     powerups: []
              # }
          # }
      }
  }

  attr_accessor :backdrop, :enemy_spawner, :powerup_spawner, :player, :enemies, :plazors, :elazors, :powerups, :explosions

  def initialize(level_options = {})
    #config setup
    clean_level_result
    Logger.trace("starter level opts: #{level_options}")
    Logger.start('level', level_options, DEFAULTS)
    @config = DEFAULTS.deep_merge(level_options).deep_clone

    Logger.trace("initializing level with config: #{@config}")

    super(@config)
    play_bgm
    init_level_graphics
    init_spawners
  end

  def clean_level_result
    $game_variables[IB::LEVEL_RESULT_VAR] = "incomplete" unless $game_variables.nil?
  end

  def play_bgm
    Sound.bgm(@config[:BGM])
  end

  def init_spawners
    self.enemy_spawner = Spawner.new(@config[:spawner])
    self.enemy_spawner.add_observer(self)

    self.powerup_spawner = PowerUpSpawner.new(@config[:powerup_spawner])
    self.powerup_spawner.add_observer(self)
  end

  def init_level_graphics
    Logger.trace("strating lvl graphics...  opts: #{@config}")
    self.backdrop = Backdrop.new(@config[:backdrop])
    Logger.trace("Conf for player ... '#{@config[:player_ship]}'")
    self.player = Player.new(@config[:player_ship])
    self.player.level_observe(self)
    self.player.update
    self.enemies = []
    self.plazors = []
    self.elazors = []
    self.explosions = []
    self.powerups = []
  end

  def update
    self.backdrop.update
    self.enemy_spawner.update

    update_enemies
    update_player
    update_plazors
    update_elazors
    update_explosions
    update_pups
    update_pup_spawner
  end


  def update_pup_spawner
    self.powerup_spawner.update
  end

  def update_pups
    self.powerups.each_with_index { |pup,i|
      if pup.disposed?
        self.powerups.delete_at(i)
        next
      end
      pup.update
      Collider.check_pup(pup, self.player)
    }
  end

  def update_explosions
    self.explosions.each_with_index { |e,i|
      if e.disposed?
        self.explosions.delete_at(i)
        next
      end
      e.update
    }
  end

  def update_elazors
    self.elazors.each_with_index { |el,i|
      if el.disposed?
        self.elazors.delete_at(i)
        next
      end
      el.update
      Collider.check_lazor(el, self.player)
    }
  end

  def update_plazors
    self.plazors.each_with_index { |pl,i|
      # return true if pl.disposed?
      if pl.disposed?
        self.plazors.delete_at(i)
        next
      end
      pl.update
    }
  end

  def update_enemies
    self.enemies.each_with_index { |enemy,i|
      if enemy.disposed?
        self.enemies.delete_at(i)
        next
      end
      enemy.update
      Collider.check_enemy_player(enemy, self.player)
      Collider.check_enemy_plazors(enemy, self.plazors)
    }
  end

  def update_player
    self.player.update unless self.player.disposed?
  end


  def difficulty
    self.enemy_spawner.difficulty
  end

  def difficulty=(difficulty)
    self.enemy_spawner.difficulty = difficulty
    self.enemies.each {|e| e.difficulty = difficulty }
  end

  def notified(msg, data={})
    reactions = {
        'new_enemy' => lambda { |enemy| add_new_enemy(enemy) },
        'new_lazors' => lambda { |lazors| add_new_lazors(lazors)},
        'new_powerup' => lambda { |pup| add_new_powerup(pup)},
        'player_destroyed' => lambda { |_| init_game_over("loss")},
        'enemy_destroyed' => lambda { |enemy| handle_enemy_destroyed(enemy)},
        'ship_exploded' => lambda { |ship| handle_ship_exploded(ship) },
        'player_hit' => lambda { |elazor| elazor.dispose },
        'enemy_hit' => lambda { |lazor| lazor.dispose },
        'score' => lambda { |_| check_score_win },
        'powerup_grabbed' => lambda { |pup| apply_effect(pup)},
        'item_activate' => lambda { |item| apply_effect(item)},
        'player_weapon_changed' => lambda { |weapon| observe_new_weapon(weapon)}
    }
    return unless reactions.key?(msg)
    Logger.trace("Level received notification '#{msg}', with data #{data}... ") ###{"But is not considered." unless }")
    reactions[msg].call(data)
  end

  def observe_new_weapon(weapon)
    weapon.add_observer(self)
  end

  def add_new_powerup(pup)
    raise 'New powerup is nil!' if pup.nil?
    Logger.debug("#{self} New powerup #{pup.name} #{pup} entered level #{@config[:name]}.")
    pup.add_observer(@collider)
    self.powerups << pup
  end

  def apply_effect(pup)
    pup_effect = pup.effect
    targets = (pup.target ? [pup.target] : pup.targets).flatten

    targets.each { |target|
      case target
        when "player" then self.player.apply_pup(pup_effect)
        when "enemies" then self.enemies.each { |e| e.apply_pup(pup_effect) }
        when "level" then self.apply_pup(pup_effect)
        else raise "Invalid target '#{target}' for effect #{pup_effect} "
      end
    }

  end

  def check_score_win
    init_game_over("win") if self.player.score >= @config[:target_score]
  end

  def handle_enemy_destroyed(ship_data)
    self.player.score += ship_data[:ship].stats[:mhp]
  end

  def handle_ship_exploded(explosion_data)
    self.explosions << Explosion.new(explosion_data)
  end

  def init_game_over(result)
    self.enemy_spawner.stop

    if result == "win"
      self.elazors.each { |el|
        el.dispose unless el.disposed?
      }

      self.enemies.each { |e|
        e.explode
        e.dispose unless e.disposed?
      }
    end

    if result == "loss"
      self.plazors.each { |pl| pl.dispose unless pl.disposed? }
    end

    result = "completed" if IB::last_level? && result == "win"
    Logger.info("game over! result: #{result}")
    self.result = result

    notify_observers("game_over", result)
  end

  def result=(result)
    @result = result
    $game_variables[IB::LEVEL_RESULT_VAR] = result
  end


  def add_new_enemy(enemy)
    raise 'New enemy is nil!' if enemy.nil?
    Logger.debug("#{self} New enemy #{enemy.name} #{enemy} entered level #{@config[:name]}. Ancestors: #{enemy.class.ancestors}")
    enemy.level_observe(self)
    self.enemies << enemy
  end

  def add_new_lazors(data)
    raise 'Lazor(s) are empty or nil!' if data[:lazors].nil_empty?
    Logger.trace("#{self} New lazors were shooted!!! data received: #{data}")
    case data[:data][:shooter]
      when 'player' then self.plazors.push(*data[:lazors]) unless self.plazors.nil?
      when 'enemy'  then self.elazors.push(*data[:lazors]) unless self.elazors.nil?
    end

    # Logger.trace("Level lazors present: Plazors > #{@plazors} | Elazors > #{@elazors}")
  end

  def dispose
    self.backdrop.dispose unless self.backdrop.disposed?
    self.player.dispose unless self.player.disposed?
    self.enemies.each { |obj| obj.dispose unless obj.disposed? }
    self.plazors.each { |obj| obj.dispose unless obj.disposed? }
    self.elazors.each { |obj| obj.dispose  unless obj.disposed? }
    self.explosions.each { |obj| obj.dispose  unless obj.disposed? }
    self.powerups.each { |obj| obj.dispose  unless obj.disposed? }
  end

  def screen_observe(screen)
    self.player.add_observer(screen)
    self.add_observer(screen)
  end

  def to_s
    "<#{self.class}>"
  end

  def self.pre_config(level_config)
    return unless level_config.key?(:pre_config)
    Logger.debug("pre-configuring level #{level_config[:name]}")
    level_config[:pre_config].call
    Logger.debug("pre-configured level #{level_config[:name]}!")
  end

  def self.post_config(level_config)
    return unless level_config.key?(:post_config)
    Logger.debug("post-configuring level #{level_config[:name]}")
    level_config[:post_config].call
    Logger.debug("post-configured level #{level_config[:name]}!")
  end
end
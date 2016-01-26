# Factory for spawning new enemies whenever available
class Spawner
  include Subject

  DEFAULTS = {
      spawn_cooldown: 100,
      spawn_decrement_amount: 1,
      spawn_decrement_freq: 100,
      phases: []
  }
  def initialize(config)
    super(config)

    Logger.start('@enemy_spawner', config, DEFAULTS)
    @config = DEFAULTS.merge(config).deep_clone

    @spawn_cooldown = @config[:spawn_cooldown]
    @spawn_timer = 0

    @enemy_phases = @config[:phases].values
    @enemy_phases.each { |p| p[:spawned] = 0 }

    @current_phases = []
    @next_phases = []
    check_phases
  end

  def update
    @spawn_timer -= 1
    try_spawn
  end


  def try_spawn
    return if @spawn_timer > 0

    check_phases if @current_phases.any? || @next_phases.any?
    return if @current_phases.empty?

    # Restart spawn timer to configured speed
    refresh_cooldown
    spawn
  end

  def refresh_cooldown
    @spawn_timer = 50 + rand(@spawn_cooldown) / 2 ##- @spawn_decrement_amount ## TODO GET DIFFICULTY
  end

  def check_phases
    old_phases = @current_phases

    # Find phases that are started, separate from 'next_phases'
    @current_phases, @next_phases = @enemy_phases.partition {
        |phase|
      Main_IB.game_time >= phase[:start]
    }


    @finished_phases, @current_phases = @current_phases.partition {
        |phase|
      (phase[:max_spawn] && phase[:spawned] >= phase[:max_spawn]) ||
          (phase[:end] && Main_IB.game_time >= phase[:end] )
    }

    Logger.trace("checking phases.... \nCurrent phases: #{@current_phases}. \nNext phases: #{@next_phases}. \nFinished: #{@finished_phases}. SpawnTimer: #{@spawn_timer},\nGame time: #{Main_IB.game_time})")

    new_phases = @current_phases - old_phases

    if new_phases.any?
      enemies = []
      new_phases.each { |np|
        self.bgm = np[:BGM] if np.key?(:BGM)
        self.spawn_cooldown = (np[:spawn_cooldown] if np.key?(:spawn_cooldown)) || @config[:spawn_cooldown]
        np[:enemies].each { |e| enemies << e[:name] }
      }
      Logger.debug("New phase(s) started! #{new_phases}. With new enemy(es): #{enemies}.")

    end

  end

  def spawn_cooldown=(new_spawn_cooldown)
    @spawn_cooldown = new_spawn_cooldown
    Logger.debug("Base spawn speed been changed from default #{@config[:spawn_cooldown]} to #{self.spawn_cooldown}.") if @config[:spawn_cooldown] != self.spawn_cooldown
  end

  def spawn_cooldown
    @spawn_cooldown
  end

  # spawn a random spawnable enemy
  def spawn
    # LOG current available phases enemies
    Logger.trace("Checking enemies for current phases : #{@current_phases} \n Game time: #{Main_IB.game_time}")

    # LOG current spawnable enemies names
    spawnable_enemies_names = []
    @current_phases.each { |phase|
      spawnable_enemies_names << phase[:enemies].map { |e| e[:name] }
    }
    Logger.trace("spawnable_enemies... #{spawnable_enemies_names}")

    # Pick random spawnable
    new_enemy = pick_spawnable_enemy(@current_phases)
    Logger.info("Spawning enemy: #{new_enemy}\n.#{" Observers notified >> #{observers.map { |o| o.class.name }}" if !observers.empty?}")

    # Create spawnee and notify
    spawned_enemy = Enemy.new(new_enemy)
    notify_observers('new_enemy', spawned_enemy)
  end


  def pick_spawnable_enemy(spawnable_phases_enemies)
    rand_phase = spawnable_phases_enemies.sample

    rand_phase[:spawned] += 1
    rand_phase[:enemies].sample
  end

  def stop
    @spawn_timer = Float::INFINITY
  end

  def bgm=(new_bgm)
    @bgm = new_bgm
    Sound.bgm(@bgm)
    Logger.debug("Spawner #{self} changed BGM to #{@bgm}... Playing music...")
  end
end
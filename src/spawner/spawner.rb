# Factory for spawning new enemies whenever available
class Spawner
  include Subject

  DEFAULTS = {
      spawn_cooldown: 100,
      spawn_decrement_amount: 1,      # DEFAULT 1, cantidad en que se reduce el cooldown base
      spawn_decrement_freq: 100,      # DEFAULT 100, tiempo que tarda en reducirse el cd
      phases: {}
  }
  def initialize(config)
    super(config)

    Logger.start('@enemy_spawner', config, DEFAULTS)
    @config = DEFAULTS.merge(config).deep_clone

    @spawn_timer = 0

    @phases = @config[:phases].values
    @phases.each { |p| p[:spawned] = 0 }

    @current_phases = []
    @next_phases = []
    check_phases
  end

  def init_cooldown
    @spawn_cooldown = @config[:spawn_cooldown]
    @cooldown_decrement_cooldown = @config[:spawn_decrement_freq]
    @cooldown_decrement_amount = @config[:spawn_decrement_amount]
    @cooldown_decrement_timer = @cooldown_decrement_cooldown
  end

  def update
    @spawn_timer -= 1
    update_cooldown
    try_spawn
  end

  def update_cooldown
    return unless @config.key?(:spawn_decrement_freq) &&
        @config.key?(:spawn_decrement_amount) &&
        !@cooldown_decrement_cooldown.nil? &&
         @cooldown_decrement_cooldown > 0

    @cooldown_decrement_timer -= 1
    if @cooldown_decrement_timer < 0
      @spawn_cooldown -= @cooldown_decrement_amount
    end
  end



  def try_spawn
    if (@spawn_timer > 0) || !check_spawn_condition
      return
    end

    check_phases if @current_phases.any? || @next_phases.any?
    return if @current_phases.empty?

    # Restart spawn timer to configured speed
    @spawn_timer = calculate_cooldown
    spawn
  end

  ## Should OVERRIDE
  def check_spawn_condition
    true
  end

  def calculate_cooldown
    50 + rand(@spawn_cooldown) / 2 ##- @spawn_decrement_amount ## TODO GET DIFFICULTY
  end

  def check_phases
    old_phases = @current_phases

    # Find phases that are started, separate from 'next_phases'
    @current_phases, @next_phases = @phases.partition {
        |phase|
      Main_IB.game_time >= (phase[:start] || 0)
    }


    @finished_phases, @current_phases = @current_phases.partition {
        |phase|
      (phase[:max_spawn] && phase[:spawned] >= phase[:max_spawn]) ||
          (phase[:end] && Main_IB.game_time >= phase[:end] )
    }

    # Logger.trace("checking phases.... \nCurrent phases: #{@current_phases}. \nNext phases: #{@next_phases}. \nFinished: #{@finished_phases}. SpawnTimer: #{@spawn_timer},\nGame time: #{Main_IB.game_time})")

    new_phases = @current_phases - old_phases

    if new_phases.any?
      enemies = []
      new_phases.each { |np|
        self.bgm = np[:BGM] if np.key?(:BGM)
        self.spawn_cooldown = (np[:spawn_cooldown] if np.key?(:spawn_cooldown)) || @config[:spawn_cooldown]
        spawns(np).each { |e| enemies << e[:name] }
        @cooldown_decrement_cooldown = np[:spawn_decrement_freq] if np.key?(:spawn_decrement_freq)
        @cooldown_decrement_amount = np[:spawn_decrement_amount] if np.key?(:spawn_decrement_amount)
        @cooldown_decrement_timer = @cooldown_decrement_cooldown if np.key?(:spawn_decrement_freq)
        @frequency = np[:frequency] if np.key?(:frequency)
      }
      Logger.debug("New phase(s) started! #{new_phases}. With new spanw(s): #{enemies}.")

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
      spawnable_enemies_names << spawns(phase).map { |e| e[:name] }
    }
    return Logger.warn('No enemies defined for current phases!') if spawnable_enemies_names.empty?

    Logger.trace("spawnable_enemies... #{spawnable_enemies_names}")

    # Pick random spawnable
    new_enemy = pick_spawnable(@current_phases)
    Logger.info("Spawning enemy: #{new_enemy}\n.#{" Observers notified >> #{observers.map { |o| o.class.name }}" unless observers.empty?}")

    # Create spawnee and notify
    emit_spawnee(new_enemy)
  end

  def spawns(phase)
    phase[:enemies]
  end

  def emit_spawnee(config)
    spawned_enemy = Enemy.new(config)
    notify_observers('new_enemy', spawned_enemy)
  end


  def pick_spawnable(spawnable_phases)
    rand_phase = spawnable_phases.sample

    rand_phase[:spawned] += 1
    spawns(rand_phase).sample
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
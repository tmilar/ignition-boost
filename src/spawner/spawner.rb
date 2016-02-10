# Factory for spawning new enemies whenever available
class Spawner
  include Subject

  DEFAULTS = {
      # cooldown: [100, 1, 100],        # spawn cooldown | increment amount | increment frequency
      spawn_cooldown: 100,
      spawn_decrement_amount: 1,      # DEFAULT 1, cantidad en que se reduce el cooldown base
      spawn_decrement_freq: 100,      # DEFAULT 100, tiempo que tarda en reducirse el cd
      phases: {}
  }
  def initialize(config)
    super(config)

    Logger.start('@enemy_spawner', config, DEFAULTS)
    @config = DEFAULTS.merge(config).deep_clone
    @elapsed_time_spawner = 0
    cooldown_init
    phases_init
    # check_phases
  end

  def phases_init
    @phases = []
    @config[:phases].each {
        |id, phase_config|
      phase_config[:number] = id
      config = DEFAULTS.except(:phases).merge(phase_config)
      @phases << Phase.new(config) ### TODO REMOVE PhaseFactory.create(config)
      # @phases << Phase.new(phase_config, DEFAULTS)
    }
  end

  def phases(state_class)
    @phases.select { |p| p.state.is_a?( state_class )}
  end

  def cooldown_init
    @spawn_timer = 0
    @spawn_cooldown = @config[:spawn_cooldown]
    @cooldown_decrement_freq = @config[:spawn_decrement_freq]
    @cooldown_decrement_amount = @config[:spawn_decrement_amount]
  end

  def update
    @spawn_timer -= 1
    @elapsed_time_spawner += 1

    update_phases
    try_spawn
  end

  def update_phases
    @phases.each { |p| p.update(@elapsed_time_spawner)}
  end

  ## On RESET or NUKE, modify elapsed_time by [factor] to go back or forward in difficulty time.
  def modify_difficulty(factor)
    @elapsed_time_spawner *= factor
    Logger.debug("Spawner difficulty has been reduced by #{1 - factor}%! (elapsed_time been modified)")
  end


  def try_spawn
    if @spawn_timer > 0 #|| !check_spawn_condition
      return
    end

    # check_phases if @opened_phases.any? || @next_phases.any?
    return if phases(Phase::OpenedPhaseState).empty?

    # Restart spawn timer to configured speed
    @spawn_timer = calculate_cooldown
    spawn
  end

  ### TODO remove... las phases se updatean y actualizan su estado solas...
  # def check_phases
  #   old_phases = @opened_phases
  #
  #   # Find phases that are started, separate from 'next_phases'
  #   # @opened_phases, @next_phases = @phases.partition {
  #   #     |phase|
  #   #   Main_IB.game_time >= (phase[:start] || 0)
  #   # }
  #
  #   opened_phases = phases(:opened)
  #   next_phases = phases(:next)
  #   finished_phases = phases(:finished)
  #
  #
  #   # Separate finished_phases from @opened_phases
  #   # @finished_phases, @opened_phases = @opened_phases.partition {
  #   #     |phase|
  #   #   (phase[:max_spawn] && phase[:spawned] >= phase[:max_spawn]) ||
  #   #       (phase[:end] && Main_IB.game_time >= phase[:end] )
  #   # }
  #
  #   # Logger.trace("checking phases.... \nCurrent phases: #{@@opened_phases}. \nNext phases: #{@next_phases}. \nFinished: #{@finished_phases}. SpawnTimer: #{@spawn_timer},\nGame time: #{Main_IB.game_time})")
  #
  #
  #   new_phases = @opened_phases - old_phases
  #
  #   if new_phases.any?
  #     enemies = []
  #     new_phases.each { |np|
  #       # TODO remove... esto lo hace sola la phase al ser nueva...
  #       # self.bgm = np[:BGM] if np.key?(:BGM)
  #       # self.spawn_cooldown = (np[:spawn_cooldown] if np.key?(:spawn_cooldown)) || @config[:spawn_cooldown]
  #       # spawns(np).each { |e| enemies << e[:name] }
  #
  #       ## TODO remove - cada phase tiene una copia del default del cooldown...
  #       # @cooldown_decrement_freq = np[:spawn_decrement_freq] if np.key?(:spawn_decrement_freq)
  #       # @cooldown_decrement_amount = np[:spawn_decrement_amount] if np.key?(:spawn_decrement_amount)
  #       # @cooldown_decrement_timer = @cooldown_decrement_freq if np.key?(:spawn_decrement_freq)
  #       # @frequency = np[:frequency] if np.key?(:frequency)
  #       # @timer = np[:timer] if np.key?(:timer)
  #     }
  #     Logger.debug("New phase(s) started! #{new_phases}. With new spanw(s): #{enemies}.")
  #
  #   end
  # end


  ## Should OVERRIDE

  # TODO remove, movido a SpawnStrategy...
  # def check_spawn_condition
  #   true
  # end

  ## Should OVERRIDE
  def calculate_cooldown
    50 + rand(@spawn_cooldown) / 2 + spawn_decrement
  end

  ## Decrement depends on spawner elapsed_time, which can be modified for getting future or past difficulty
  def spawn_decrement
    - (@elapsed_time_spawner / @cooldown_decrement_freq) * @cooldown_decrement_amount
  end



  # def spawn_cooldown=(new_spawn_cooldown)
  #   @spawn_cooldown = new_spawn_cooldown
  # end
  #
  # def spawn_cooldown
  #   @spawn_cooldown
  # end

  # spawn a random spawnable enemy
  def spawn

    # LOG current available phases enemies
    opened_phases = phases(Phase::OpenedPhaseState)
    Logger.trace("Checking enemies for current phases : #{opened_phases} \n Game time: #{Main_IB.game_time}")

    # LOG current spawnable enemies names
    spawnable_enemies_names = []
    opened_phases.each { |phase|
      spawnable_enemies_names << phase.spawns.map { |e| e[:name] }
    }
    return Logger.warn('No enemies defined for current phases!') if spawnable_enemies_names.empty?

    Logger.trace("spawnable_enemies... #{spawnable_enemies_names}")

    # Pick random spawnable
    new_enemy = pick_spawnable(opened_phases)
    Logger.info("Spawning enemy: #{new_enemy}\n.#{" Observers notified >> #{observers.map { |o| o.class.name }}" unless observers.empty?}")

    # Create spawnee and notify
    emit_spawnee(new_enemy)
    # # LOG current available phases enemies
    # Logger.trace("Checking enemies for current phases : #{@opened_phases} \n Game time: #{Main_IB.game_time}")
    #
    # # LOG current spawnable enemies names
    # spawnable_enemies_names = []
    # @opened_phases.each { |phase|
    #   spawnable_enemies_names << spawns(phase).map { |e| e[:name] }
    # }
    # return Logger.warn('No enemies defined for current phases!') if spawnable_enemies_names.empty?
    #
    # Logger.trace("spawnable_enemies... #{spawnable_enemies_names}")
    #
    # # Pick random spawnable
    # new_enemy = pick_spawnable(@opened_phases)
    # Logger.info("Spawning enemy: #{new_enemy}\n.#{" Observers notified >> #{observers.map { |o| o.class.name }}" unless observers.empty?}")
    #
    # # Create spawnee and notify
    # emit_spawnee(new_enemy)

  end

  # def spawns(phase)
  #   phase[:enemies]
  # end

  def emit_spawnee(config)
    spawned_enemy = Enemy.new(config)
    notify_observers('new_enemy', spawned_enemy)
  end


  # Pick a random spanwable from a random Current phase
  def pick_spawnable(spawnable_phases)
    rand_phase = spawnable_phases.sample

    # rand_phase[:spawned] += 1
    # spawns(rand_phase).sample
    rand_phase.pick_spawnee
  end

  def stop
    @spawn_timer = Float::INFINITY
  end

  # def bgm=(new_bgm)
  #   @bgm = new_bgm
  #   Sound.bgm(@bgm)
  #   Logger.debug("Spawner #{self} changed BGM to #{@bgm}... Playing music...")
  # end

  def to_s
    "<Enemies Spawner>"
  end
end
# Factory for spawning new enemies whenever available
class Spawner
  include Subject

  DEFAULTS_ENEMIES_SPAWNER = {
      # cooldown: [100, 1, 100],        # spawn cooldown | increment amount | increment frequency
      spawn_cooldown: 100,
      spawn_decrement_amount: 1,      # DEFAULT 1, cantidad en que se reduce el cooldown base
      spawn_decrement_freq: 100,      # DEFAULT 100, tiempo que tarda en reducirse el cd
      phases: {}
  }

  attr_accessor :elapsed_time

  def initialize(config)
    super(config)

    Logger.start("@#{self.class.to_s.uncapitalize}", config, DEFAULTS_ENEMIES_SPAWNER)
    @config = DEFAULTS_ENEMIES_SPAWNER.merge(config).deep_clone
    @elapsed_time = 0
    cooldown_init
    phases_init
  end

  def phases_init
    @phases = []
    @config[:phases].each {
        |id, phase_config|
      phase_config[:number] = id
      config = DEFAULTS_ENEMIES_SPAWNER.except(:phases).merge(phase_config)
      @phases << Phase.new(config)
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
    @elapsed_time += 1

    update_phases
    try_spawn
  end

  def update_phases
    @phases.each { |p| p.update(@elapsed_time)}
  end

  ## On RESET or NUKE, modify elapsed_time by [factor] to go back or forward in difficulty time.
  def modify_difficulty(factor)
    @elapsed_time_spawner *= factor
    Logger.debug("Spawner difficulty has been reduced by #{1 - factor}%! (elapsed_time been modified)")
  end


  def try_spawn
    check_ready_phases
    check_opened_phases
  end

  def check_opened_phases
    opened_phases = phases(Phase::OpenedPhaseState)
    return if  @spawn_timer > 0 || opened_phases.empty?

    Logger.trace("Spawn timer is #{@spawn_timer}, opened phases #{opened_phases}. Calculating cd...")

    # Restart spawn timer to configured speed
    @spawn_timer = calculate_cooldown
    Logger.trace("#{self} New spawn cooldown timer is #{@spawn_timer}")
    spawn(opened_phases)
  end

  def check_ready_phases
    phases(Phase::ReadyPhaseState).each { |rp|
      Logger.trace("Spawning from ready phase #{rp}...")
      spawn([rp])
    }
  end

  ### TODO remove... las phases se updatean y actualizan su estado solas...
  # def check_phases
  #   new_phases = phases(Phase::NewPhaseState)
  #
  #   if new_phases.any?
  #     enemies = []
  #     new_phases.each { |np|
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
  def calculate_cooldown
    50 + rand(@spawn_cooldown) / 2 + spawn_decrement
  end

  ## Decrement depends on spawner elapsed_time, which can be modified for getting future or past difficulty
  def spawn_decrement
    - (@elapsed_time / @cooldown_decrement_freq) * @cooldown_decrement_amount
  end

  # param [available_phases] array,  pick a random phase and emit spawnee
  def spawn(available_phases)

    # LOG current available phases
    Logger.trace("Checking #{type} for current phases : #{available_phases} \n Game time: #{Main_IB.game_time}")

    # LOG current spawnable #{type} names
    spawnable_names = []
    available_phases.each { |phase|
      spawnable_names << phase.spawns.map { |e| e[:name] }
    }
    return Logger.warn("No #{type} defined for current available phases!") if spawnable_names.empty?

    Logger.trace("spawnable_#{type}... #{spawnable_names}")

    # Pick random spawnable
    new_spawn = pick_spawnable(available_phases)
    Logger.info("Spawning: #{new_spawn}.#{" Observers notified >> #{observers.map { |o| o.class.name }}." unless observers.empty?}..")

    # Create spawnee and notify
    emit_spawnee(new_spawn)
  end

  ## OVERRIDE this
  def emit_spawnee(config)
    config[:elapsed_time] = @elapsed_time
    spawned_enemy = Enemy.new(config)
    notify_observers('new_enemy', spawned_enemy)
  end

  # Pick a random spanwable from a random Current phase
  def pick_spawnable(spawnable_phases)
    spawnable_phases.sample.pick_spawnee
  end

  def stop
    @spawn_timer = Float::INFINITY
  end

  def type
    "enemies"
  end

  def to_s
    "<#{type} Spawner>"
  end
end
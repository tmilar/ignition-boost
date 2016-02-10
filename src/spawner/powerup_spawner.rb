class PowerUpSpawner < Spawner


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

  DEFAULTS = {
      frequency: 0,
      spawn_cooldown: 100,
      spawn_decrement_amount: -0,     # DEFAULT 0, cantidad en que se reduce el cooldown base
      spawn_decrement_freq: 100,      # DEFAULT 100, tiempo que tarda en reducirse el cd
      phases: {
          # 1 => {
          #     powerups: [REPAIR_PUP, WEAPON_UP],
          # }
      },
      destructible?: false         # Can pups can be destroyed by bullets?
  }

  def initialize(config={})
    Logger.start('@pup_spawner', config, DEFAULTS)
    @config = DEFAULTS.merge(config).deep_clone
    super(@config)
  end

  def cooldown_init
    # @spawn_freq = @config[:spawn_cooldown]
    difficulty_factor = @config[:spawn_cooldown]
    @base_cd = Math::log(0.995-difficulty_factor.fdiv(1000), 0.01).to_i
  end

  # # @OVERRIDE
  # def check_spawn_condition
  #   spawn = rand(1000) > (1000 - @spawn_freq)
  #   Logger.trace("About to spawn item at freq #{@spawn_freq}!") if spawn
  #   spawn
  # end
  #
  # # @OVERRIDE
  # def calculate_cooldown
  #   -1  ## DON'T use THIS cooldown
  # end

  def calculate_cooldown
    rand(@base_cd)
  end

  # OVERRIDE spawns
  def spawns(phase)
    phase[:powerups]
  end

  # Pick a random spanwable from a random Current phase
  def pick_spawnable(_)
    return if check_timed_phases

    phases(Phase::OpenedPhaseState).sample.pick_spawnee
  end

  def check_timed_phases
    ## TODO move up to Spawner::spawn method? so it will ignore spawn_timer?
    ready_timed_phase = phases(Phase::ReadyTimedPhase).sample
    ready_timed_phase.spawn if ready_timed_phase
  end


  def emit_spawnee(pup_config)
    Logger.trace("pup config is #{pup_config}, self is #{@config}")
    pup_config[:destructible?] ||= @config[:destructible?]
    spawned_pup = PowerUp.new(pup_config)
    notify_observers('new_powerup', spawned_pup)
  end
end
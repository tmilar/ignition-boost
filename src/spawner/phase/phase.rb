class Phase
  include Subject

  ### TODO Remove
  # class PhaseFactory
  #   ## cada phase tiene su estrategia para contar el tiempo de cooldown - segun su config
  #   def self.create(config)
  #     return Phase.new(config, TimedStrat) if config.key?(:timer)
  #     return Phase.new(config, CooldownStrat) if config.key?(:cooldown) || config.key?(:spawn_cooldown)
  #     raise "Attempted to create invalid type of Phase! Check phase or spawner config, current is #{config}."
  #   end
  # end

  ####////////////////////////////////////////////////////////
  ## Phase States
  ####////////////////////////////////////////////////////////
  class NextPhaseState
    def initialize(phase)
      @phase = phase
      Logger.trace("Initialized state Next phase #{@phase}")
    end
    def update(elapsed_time)
      @phase.new_state(NewPhaseState) if @phase.start >= elapsed_time
    end
  end

  class NewPhaseState
    def initialize(phase)
      @phase = phase
      @phase.play_bgm
      Logger.debug("New phase started! #{@phase}. With new spanw(s): #{@phase.spawns}.")
      @phase.new_state(OpenedPhaseState)
      @phase.update
    end
    def update(_)
      raise "NotImplementedError, :new phase #{@phase} can't be updated! Should be Opened..."
    end
  end

  class OpenedPhaseState
    def initialize(phase)
      @phase = phase
      Logger.trace("Initialized state Opened phase #{@phase}")
    end
    def update(elapsed_time)
      if @phase.end >= elapsed_time || @phase.spawn_count >= @phase.max_spawn
        @phase.new_state(FinishedPhaseState)
      end
    end
  end

  class FinishedPhaseState
    def initialize(phase)
      @phase = phase
      Logger.trace("Initialized state Finished phase #{@phase}")
    end
    def update(_)
      raise "NotImplementedError, :finished phase #{@phase} can't be updated! Is over..."
    end
  end

  # STATES:
  # New
  # Finished
  # Opened
  # Next

  # NEXT -> NEW -> OPENED -> FINISHED

  ####////////////////////////////////////////////////////////
  ## Spawning Strategies - TODO DELETE THIS... decided by spawner now.
  ####////////////////////////////////////////////////////////

  # class CooldownStrat
  #   def initialize(config)
  #     @spawn_timer = 0
  #     @spawn_cooldown = config[:spawn_cooldown]
  #     @cooldown_decrement_freq = config[:spawn_decrement_freq]
  #     @cooldown_decrement_amount = config[:spawn_decrement_amount]
  #   end
  #   def try_spawn(elapsed_time_spawner)
  #     @elapsed_time_spawner = elapsed_time_spawner
  #     @spawn_timer -= 1
  #     if @spawn_timer == 0
  #       @phase.do_spawn
  #
  #       #  TODO DONE - all opened phases using this CooldownStrategy should share the same cd clock....
  #       @spawn_timer = calculate_cooldown
  #     end
  #   end
  #   def calculate_cooldown
  #     50 + rand(@spawn_cooldown) / 2 + spawn_decrement
  #   end
  #
  #   ## Decrement depends on spawner elapsed_time, which can be modified for getting future or past difficulty
  #   def spawn_decrement
  #     - (@elapsed_time_spawner / @cooldown_decrement_freq) * @cooldown_decrement_amount
  #   end
  # end

  DEFAULTS = {
      spawns: [],
      spawn_count: 0,
      start: 0,
      end: Float::INFINITY,
      max_spawn: Float::INFINITY,
      # cooldown: [100, 1, 100],  # spawn cooldown | decrement amount | decrement frequency
      BGM: []
  }

  # Delegate accessors to internal hashes
  attr_readers_delegate :@config, :start, :end, :max_spawn, :cooldown, :spawns, :spawn_count


  def initialize(config) ## TODO Remove ## , spawning_strategy={})
    super(config)
    @config = {}
    Logger.start('phase', config, DEFAULTS)

    @config = DEFAULTS.deep_merge(config).deep_clone
    @type = @config.key?(:enemies) ? "enemies" : "powerups"
    @config[:spawns] = @config.delete(:enemies) || @config.delete(:powerups)
  end

  def update(elapsed_time_spawner)
    @state.update(elapsed_time_spawner)
  end

  ## checking spawns list...
  ## pick one spawn...
  ## return spawnee *config* to spawner...
  def pick_spawnee
    self.spawned += 1
    self.spawns.sample
  end

  def new_state(state)
    @state = state.new(self)
  end

  def play_bgm
    new_bgm = @config[:BGM]
    return if new_bgm.nil_empty?
    Sound.bgm(new_bgm)
    Logger.debug("Spawner #{self} changed BGM to #{new_bgm}... Playing music...")
  end

end
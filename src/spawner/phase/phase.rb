class Phase
  include Subject

  ####////////////////////////////////////////////////////////
  ## Phase States
  ####////////////////////////////////////////////////////////
  class NextPhaseState
    def initialize(phase)
      @phase = phase
      Logger.trace("Initialized state Next phase #{@phase}")
    end
    def update(elapsed_time)
      # Logger.trace("Updating NewPhaseState #{@phase}, start: #{@phase.start} (#{@phase.start / 60} seconds), elapsed_time: #{elapsed_time}")
      @phase.new_state(NewPhaseState) if elapsed_time >= @phase.start
    end
  end

  class NewPhaseState
    def initialize(phase)
      @phase = phase
      @phase.play_bgm
      Logger.debug("New phase started! #{@phase}. With new spanw(s): #{@phase.spawns}.")
    end
    def update(_)
      @phase.new_state(OpenedPhaseState)
    end
  end

  class OpenedPhaseState
    def initialize(phase)
      @phase = phase
      @timer = (phase.timer + phase.spawn_count) * 60 if phase.timer
      Logger.trace("Initialized state Opened phase #{@phase}#{"with timer #{phase.timer + phase.spawn_count}" if @timer}")
    end
    def update(elapsed_time = 0)
      # Logger.trace("updating opened phsae #{@phase}... with elapsed_time #{elapsed_time}")
      if elapsed_time >= @phase.end  || @phase.spawn_count >= @phase.max_spawn
        @phase.new_state(FinishedPhaseState)
        return
      end

      return unless @timer
      @timer -= 1
      @phase.new_state(ReadyPhaseState) if @timer <= 0
    end
  end

  ## State only used by 'timed' Phase
  class ReadyPhaseState
    def initialize(phase)
      @phase = phase
      @old_spawn_count = phase.spawn_count
      Logger.trace("Timed Phase is Ready to spawn #{@phase}")
    end
    def update(_)
      Logger.trace("Timed Phase Ready #{@phase} updated - should have spawned by now...")
      check_spawned
    end
    def check_spawned
      if @phase.spawn_count > @old_spawn_count
        Logger.trace("Timed phase #{@phase} did spawn! Restarting timer (changing back to OpenedState)")
        @phase.new_state(OpenedPhaseState)
      end
    end
  end

  class FinishedPhaseState
    def initialize(phase)
      @phase = phase
      Logger.trace("Initialized state Finished phase #{@phase}")
    end
    def update(_)
      # raise "NotImplementedError, :finished phase #{@phase} can't be updated! Is over..."
    end
  end

  # STATES:
  # New
  # Finished
  # Opened
  # Next

  # NEXT -> NEW -> OPENED -> FINISHED

  # Timed Ready
  # NEXT -> NEW -> ( OPENED <-> READY ) -> FINISHED


  DEFAULTS = {
      spawn_count: 0,
      start: 0,
      end: Float::INFINITY,
      max_spawn: Float::INFINITY,
      # timer: 60
      BGM: [],
      number: 0
  }

  # Delegate accessors to internal hashes
  attr_readers_delegate :@config, :start, :end, :max_spawn, :cooldown, :spawns, :timer, :number
  attr_accessors_delegate :@config, :spawn_count
  attr_reader :state, :type

  def initialize(config)
    super(config)
    @config = {}
    Logger.start('phase', config, DEFAULTS)

    @config = DEFAULTS.deep_merge(config).deep_clone
    @config[:start] *= 60 # convert start time from "frames" to "seconds"
    @type = @config.key?(:enemies) ? "enemies" : "powerups"
    @config[:spawns] = @config.delete(:enemies) || @config.delete(:powerups)
    new_state(NextPhaseState)
  end

  def update(elapsed_time_spawner)
    # Logger.trace("updating #{self}...")
    @state.update(elapsed_time_spawner)
  end

  ## checking spawns list...
  ## pick one spawn...
  ## return spawnee *config* to spawner...
  def pick_spawnee
    self.spawn_count += 1
    self.spawns.sample
  end

  def new_state(state)
    @state = state.new(self)
    # Logger.trace("Phase transitioned to new state! #{self} ")
  end

  def play_bgm
    new_bgm = @config[:BGM]
    return if new_bgm.nil_empty?
    Sound.bgm(new_bgm)
    Logger.debug("Spawner #{self} changed BGM to #{new_bgm}... Playing music...")
  end

  def to_s
    "<Phase:#{type}##{number}> state: #{state}"
  end
end
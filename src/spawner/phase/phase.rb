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
    def to_s; 'NextPhaseState'; end
  end

  class NewPhaseState
    def initialize(phase)
      @phase = phase
      @phase.play_bgm
      Logger.debug("New phase started! #{@phase}. With new spanw(s): #{@phase.spawns}.")
    end
    def update(_)
      return @phase.new_state(TimingPhaseState) if @phase.timer > 0
      @phase.new_state(OpenedPhaseState)
    end
    def to_s; 'NewPhaseState'; end
  end

  class TimingPhaseState
    def initialize(phase)
      @phase = phase
      # New timer is current timer + number of spawned, so it
      @timer = phase.calculate_timer
      Logger.trace("Initialized state Timed phase #{@phase} with timer #{@timer}")
    end
    def update(_)
      @timer -= 1
      @phase.new_state(ReadyPhaseState) if @timer <= 0
    end
    def to_s; 'TimingPhaseState'; end
  end

  class OpenedPhaseState
    def initialize(phase)
      @phase = phase
      Logger.trace("Initialized state Opened phase #{@phase}")
    end
    def update(elapsed_time = 0)
      @phase.new_state(FinishedPhaseState) if @phase.finished?(elapsed_time)
    end
  end

  ## State only used by 'timed' Phase
  class ReadyPhaseState
    def initialize(phase)
      @phase = phase
      @old_spawn_count = phase.spawn_count
      Logger.trace("#{@phase} is Ready to spawn")
    end
    def update(elapsed_time)
      Logger.trace("#{@phase} updated - should have spawned one spawnee...")

      return if @old_spawn_count == @phase.spawn_count
      Logger.trace("#{@phase} spawned randomly one of its spawns!")

      return @phase.new_state(FinishedPhaseState) if @phase.finished?(elapsed_time)
      Logger.trace("Restarting phase :timer (changing state back to TimingPhaseState)")
      @phase.new_state(TimingPhaseState)
    end
    def to_s; 'ReadyPhaseState'; end
  end

  class FinishedPhaseState
    def initialize(phase)
      @phase = phase
      Logger.trace("Initialized state Finished phase #{@phase}")
    end
    def update(_)
      # ":finished phase #{@phase} can't be updated! Is over..."
    end
    def to_s; 'FinishedPhaseState'; end
  end

  # STATES:
  # Next
  # New
  # Finished

  ## For COOLDOWN phases...
  # + Opened

  # NEXT -> NEW -> [ OPENED ] -> FINISHED

  ## for TIMED Phases....
  # + Timed
  # + Ready

  # NEXT -> NEW -> [ TIMED <-> READY ] -> FINISHED

  DEFAULTS = {
      spawns: [],
      spawn_count: 0,
      start: 0,
      end: Float::INFINITY,
      max_spawn: Float::INFINITY,
      timer: 0,
      timer_increment: 0,
      BGM: [],
      number: 0
  }

  # Delegate accessors to internal hashes
  attr_readers_delegate :@config, :start, :end, :max_spawn, :cooldown, :spawns, :number, :timer_increment
  attr_accessors_delegate :@config, :spawn_count, :timer
  attr_reader :state

  def initialize(config)
    super(config)
    @config = {}
    Logger.start(self, config, DEFAULTS)

    @config = DEFAULTS.deep_merge(config).deep_clone
    @config[:start] *= 60 # convert start time from "frames" to "seconds"
    @config[:end] *= 60 # convert start time from "frames" to "seconds"
    @config[:timer] *= 60 # convert timer from "frames" to "seconds"
    @config[:timer_increment] *= 60 # convert timer_increment from "frames" to "seconds"
    @config[:spawns] = @config.delete(:enemies) || @config.delete(:powerups)
    new_state(NextPhaseState)
  end

  def update(elapsed_time_spawner)
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
  end

  def play_bgm
    new_bgm = @config[:BGM]
    return if new_bgm.nil_empty?
    Sound.bgm(new_bgm)
    Logger.debug("Spawner #{self} changed BGM to #{new_bgm}... Playing music...")
  end

  def finished?(elapsed_time)
    elapsed_time >= self.end  || self.spawn_count >= self.max_spawn
  end

  # Update :timer with :timer_increment (be 0 or not), then return new :timer value.
  def calculate_timer
    self.timer += self.timer_increment
  end

  def type
    @config.key?(:enemies) ? "enemies" : "powerups"
  end

  def to_s
    "#{state} <Phase:#{type}##{number}>"
  end
end
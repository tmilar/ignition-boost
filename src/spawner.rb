# Factory for spawning new enemies whenever available
class Spawner

  def initialize(spawn_speed = 10, phases = {})

    @config = {
        spawn_speed: spawn_speed,
        phases: phases
    }

    Logger.start("spawner", @config)

    @spawn_speed = @config[:spawn_speed]
    @spawn_timer = 5
    @ticker = 0

    @enemy_phases = @config[:phases].values
    @current_phases = []
    @next_phases = []
  end

  def update
    @spawn_timer -= 1
    @ticker -= 1
    check_phases if @ticker < 0
  end

  def check_phases
    old_phases = @current_phases

    @current_phases, @next_phases = @enemy_phases.partition {
        |phase| Main_IB.game_time >= phase[:start]
    }

    Logger.trace("checking phases.... Current phases: #{@current_phases}. SpawnTimer: #{@spawn_timer},\n Game time: #{Main_IB.game_time} \n)")
    Logger.trace(" Next phases: #{@next_phases}")

    new_phases = @current_phases - old_phases

    if new_phases.any?
      new_bgm, enemies = false, []
      new_phases.each { |np|
        new_bgm = np[:BGM] if np.key?(:BGM)
        np[:enemies].each { |e| enemies << e[:name] }
      }
      Logger.debug("New phase(s) started! #{new_phases}. With new enemy(es): #{enemies}.#{" And Has BGM! #{new_bgm} Playing music..." if new_bgm}")

      Sound.bgm(new_bgm) if new_bgm
    end

    @ticker = 60 # Use this to only check phases once per second (60 frames)
  end

  def spawn_enemy
    return if @spawn_timer > 0

    # Restart spawn timer to configured speed
    @spawn_timer = @spawn_speed

    # Check current available phases enemies
    Logger.trace("Checking enemies for current phases : #{@enemy_phases} \n Game time: #{Main_IB.game_time}")

    # Get all current phase enemies
    spawnable_enemies, names = [], []
    @current_phases.each { |phase|
      phase[:enemies].each { |e|
        spawnable_enemies << e
        names << e[:name]
      }
    }
    Logger.trace("spawnable_enemies... #{names}")

    # spawn a random spawnable enemy
    new_enemy = spawnable_enemies.sample
    Logger.info("Spawning enemy: #{new_enemy}\n")

    new_enemy
    # Enemy.new(new_enemy)
  end

end
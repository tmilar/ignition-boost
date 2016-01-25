# Factory for spawning new enemies whenever available
class Spawner
  include Subject

  def initialize(spawn_speed = 10, phases = {})
    @config = {
        spawn_speed: spawn_speed,
        phases: phases
    }
    super(@config)

    # @config[:phases].each { |p| p[:spawned] = 0 }
    Logger.start('spawner', @config)

    @spawn_speed = @config[:spawn_speed]
    @spawn_timer = 0
    @ticker = 0

    @enemy_phases = @config[:phases].values
    @enemy_phases.each { |p| p[:spawned] = 0 }

    @current_phases = []
    @next_phases = []
    check_phases
  end

  def update
    @spawn_timer -= 1
    spawn_enemy
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
      new_bgm, enemies = false, []
      new_phases.each { |np|
        new_bgm = np[:BGM] if np.key?(:BGM)
        np[:enemies].each { |e| enemies << e[:name] }
      }
      Logger.debug("New phase(s) started! #{new_phases}. With new enemy(es): #{enemies}.#{" And Has BGM! #{new_bgm} Playing music..." if new_bgm}")

      Sound.bgm(new_bgm) if new_bgm
    end

  end

  def spawn_enemy
    return if @spawn_timer > 0

    check_phases if @current_phases.any? || @next_phases.any?
    return if @current_phases.empty?

    # Restart spawn timer to configured speed
    @spawn_timer = rand(@spawn_speed)

    # Check current available phases enemies
    Logger.trace("Checking enemies for current phases : #{@current_phases} \n Game time: #{Main_IB.game_time}")

    spawnable_enemies_names = []
    @current_phases.each { |phase|
      spawnable_enemies_names << phase[:enemies].map { |e| e[:name] }
    }
    Logger.trace("spawnable_enemies... #{spawnable_enemies_names}")

    # spawn a random spawnable enemy
    new_enemy = pick_spawnable_enemy(@current_phases)
    Logger.info("Spawning enemy: #{new_enemy}\n.#{" Observers notified >> #{observers.map {|o| o.class.name}}" if !observers.empty?}")

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

end
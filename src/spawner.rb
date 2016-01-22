# Factory for spawning new enemies whenever available
class Spawner

  def initialize(spawn_speed = 10, phases = {})

    @config = {
        spawn_speed: spawn_speed,
        phases: phases
    }

    Logger.start("spawner", @config)

    @spawn_speed = @config[:spawn_speed]
    @timer = 5
    @enemy_phases = @config[:phases]
    # @current_phases << @enemy_phases[0]
  end

  def update
    @timer -= 1
    check_phases ##TODO manage opened phases
    check_new_bgm
  end

  def check_phases
    ##
    # @current_phases = @enemy_phases.values.select {
    #     |phase| Main_IB.game_time >= phase[:start]
    # }
  end

  def check_new_bgm
    # @enemy_phases.values.seleasd
  end

  def spawn_enemy
    return if @timer > 0

    @timer = @spawn_speed

    Logger.debug("values: #{@enemy_phases} \n")
    Logger.debug("values: #{@enemy_phases.values} \n")
    Logger.debug(" game time: #{Main_IB.game_time} \n")

    spawnable_enemies = @enemy_phases.values.select {
        |phase|
      phase[:enemy] if Main_IB.game_time >= phase[:start]
    }
    Logger.debug("selected... #{spawnable_enemies}")

    # spawn a random spawnable enemy
    new_enemy = spawnable_enemies.sample
    Logger.info("Spawning enemy: #{new_enemy}\n")

    new_enemy ### TODO initialize new enemy
  end

end
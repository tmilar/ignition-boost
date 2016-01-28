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
      frequency: 5,
      spawn_cooldown: 100,
      spawn_decrement_amount: -0,     # DEFAULT 0, cantidad en que se reduce el cooldown base
      spawn_decrement_freq: 100,      # DEFAULT 100, tiempo que tarda en reducirse el cd
      phases: {
          1 => {
              powerups: [REPAIR_PUP, WEAPON_UP],
          }
      },
      destructible?: false         # Can pups can be destroyed by bullets?
  }

  def initialize(config={})
    Logger.start('@pup_spawner', config, DEFAULTS)
    @config = DEFAULTS.merge(config).deep_clone
    super(@config)
    @spawn_freq = @config[:frequency]
  end

  # @OVERRIDE
  def check_spawn_condition
    spawn = rand(1000) > (1000 - @spawn_freq)
    Logger.trace("About to spawn item at freq #{@spawn_freq}!") if spawn
    spawn
  end

  # @OVERRIDE
  def calculate_cooldown
    -1  ## DON'T use THIS cooldown
  end

  # OVERRIDE spawns
  def spawns(phase)
    phase[:powerups]
  end

  def emit_spawnee(pup_config)
    Logger.trace("pup config is #{pup_config}, self is #{@config}")
    pup_config[:destructible?] ||= @config[:destructible?]
    spawned_pup = PowerUp.new(pup_config)
    notify_observers('new_powerup', spawned_pup)
  end
end
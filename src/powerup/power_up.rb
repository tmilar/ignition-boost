class PowerUp

  #PowerUp defaults
  DEFAULTS = {
      name: "powerup0",
      target: "player",
      frequency: 1,
      speed: 1,                 ## PowerUp move speed
      destructible?: false,
      # hold: false,
      # effect: ""
  }

  # Keys that don't involve the PUP effect to be excluded when asking for effect stats
  CONFIG_KEYS = [:name, :target, :frequency, :destructible?, :speed] ## :hold, :effect]

### EXAMPLES ###
# PowerUps.
# Los powerUp multiplican o suman a un stat. Si el valor es +ENTERO o -ENTERO, sera suma/resta.
# Si es DECIMAL (con "punto" - de 0.0 en adelante) es un factor que se MULTIPLICA. Ej. 0.1, 1.5, 2.0, etc..
# Por ahora ademas, lo que puede cambiar es>
# >>> del JUEGO ->  spawn_cooldown  ; y  stats de naves
  RESET_PUP = {
      name: "powerup4",
      target: "enemies",
      spawn_cooldown: 0.5, # Factor to multiply current spawner "spawn_cooldown"
      stats: {
          shoot_freq: 0.5     # Factor to multiply current level ALL enemies "shoot_freq"
      },
  }
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
  SPEED_UP = {
      name: "speed_pup",
      stats: {
          speed: +1
      },
  }

  SLOW_ENEMY_PUP = {
      name: "slower_enemies_pup",
      target: "enemies",
      stats: {
          speed: -1
      },
  }

# Items are also a kind of powerup but with some key "effect" to distinguish
  NUKEALL_ITEM = {
      name: "item_nuke",
      target: "player",
      hold: true,
      effect: "nuke"    # keyword for item type
  }

  # Weapon change power up. Will change current weapon with other one...
  WEAPON2_CHANGE_PUP = {
      name: "powerup2",
      target: "player",
      weapon: IB::WEAPON2      # Weapon to change. If weapon is repeated, level will go up +1 instead.
  }

  WEAPON1_CHANGE_PUP = {
      target: "player",
      name: "powerup3",
      weapon: IB::WEAPON1
  }

  extend Forwardable
  def_delegators :@sprite, :x, :y, :ox, :oy, :zoom_x, :zoom_y, :height, :width, :bitmap
  def_delegators :@sprite, :position, :position=, :rectangle, :rectangle=
  def_delegators :@sprite, :dispose, :disposed?

  attr_accessor :sprite
  attr_readers_delegate :@config, :speed, :target, :destructible?, :name
  include Subject
  include LinearMovement

  def initialize(config={})
    super(config)
    Logger.start('powerup', config, DEFAULTS)
    @config = DEFAULTS.merge(config).deep_clone

    init_sprite
  end

  def init_sprite
    @sprite = Sprite.create({
        bitmap: @config[:name],
        name: @config[:name]
    })
    @sprite.position = Point.new( rand(Graphics.width) , - self.height + 1 )
  end

  def update
    update_movement
    @sprite.update
  end

  def direction
    Point.new(0, 1)
  end

  def collision(obj=nil, destroy=false)
    Logger.debug("Pup #{self} collided with #{obj}. #{"Destroyed!" if destroy})")
    self.dispose
  end


  def effect
    # return all except the config-exclusive keys

    effect = @config.except(CONFIG_KEYS).deep_clone
    Logger.trace("#{self} been asked for effect... which is... #{effect}")
    effect
  end

  def to_s
    "<#{self.class}> '#{self.name}'"
  end
end


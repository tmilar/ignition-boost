# dependencies:
## Graphics to see the boundaries of the screen
## Sprite to load ship image
class Ship
  extend Forwardable

  def_delegators :@sprite, :x, :y, :ox, :oy, :zoom_x, :zoom_y, :height, :width
  def_delegators :@sprite, :position, :position=, :rectangle

  attr_accessor :sprite
  attr_accessor :stats

  DEFAULT_WEAPON = {
      type: "lazor",          # weapon name (also image '.png' name)
      damage: 1,              # bullet damage
      speed: 4,               # bullet speed
      cooldown: 5,            # time to wait before shooting again
      SE: ["Attack2",80,150], # sound when shooting
      level: 1                # starting weapon level (optional, default 1)
  }

  DEFAULTS = {
      :name => "DEFAULT_SHIP",
      :stats => {
          :power => 1,
          :speed => 1,
          :hp => 5,
          :collide_damage => 1,
          :collide_resistance => 0,
          :shoot_freq => 0,             ## TODO por ahora esto remplazara la @difficulty
          :nuke_power => 99            # Damage caused by nuke
      },
      :weapon => DEFAULT_WEAPON,
      :position_limits => {         # Percentage limits ship can move, mostly for bosses
          x: [0.0, 1.0],
          y: [0.0, 1.0]
      },
      :DSE => ["Fire1",90,150],     # SE for death | "SE_Name",volume,pitch
  }

  def initialize(config = {})

    #config setup
    Logger.start("ship", config, DEFAULTS)
    @config = DEFAULTS.merge(config)

    sprite_init
  end

  def sprite_init
    @sprite = Sprite.create({bitmap: @config[:name]})

    @sprite.ox = width / 2 ## @cw / 2
    @sprite.oy = height
    @sprite.x = Graphics.width / 2
    @sprite.y = Graphics.height - height / 4
  end

  def update
    @sprite.update
  end

  def dispose
    @sprite.dispose
  end

end
class PowerUp

  #PowerUp defaults
  DEFAULTS = {
      name: "powerup0",
      target: "player",
      speed: 1,                 ## PowerUp move speed
      destructible?: false,
      # hold: false,
      # effect: ""
  }

  # Keys that don't involve the PUP effect to be excluded when asking for effect stats
  CONFIG_KEYS = [:name, :target, :destructible?, :speed] ## :hold, :effect]

  # Los powerUp multiplican o suman a un stat. Si el valor es +ENTERO o -ENTERO, sera suma/resta.
# Si es DECIMAL (con "punto" - de 0.0 en adelante) es un factor que se MULTIPLICA. Ej. 0.1, 1.5, 2.0, etc..
# Por ahora ademas, lo que puede cambiar es>
# >>> del JUEGO ->  spawn_cooldown  ; y  stats de naves

  extend Forwardable
  def_delegators :@sprite, :x, :y, :ox, :oy, :zoom_x, :zoom_y, :height, :width, :bitmap
  def_delegators :@sprite, :position, :position=, :rectangle, :rectangle=, :collision_rect
  def_delegators :@sprite, :dispose, :disposed?

  attr_accessor :sprite
  attr_readers_delegate :@config, :speed, :target, :destructible?, :name
  include Subject
  include LinearMovement

  def initialize(config={})
    super(config)
    Logger.start("#{self.class}", config, DEFAULTS)
    @config = DEFAULTS.merge(config).deep_clone

    init_sprite
  end

  def init_sprite
    @sprite = Sprite.create({
        bitmap: @config[:name],
        name: @config[:name],
        init_pos: lambda { |sprite| Point.new( rand(Graphics.width - sprite.width) , - sprite.height + 1 ) }
    })
  end

  def update
    update_movement
    @sprite.update
  end

  def direction
    Point.new(0, 1)
  end

  def collide_with(obj=nil, destroy=false)
    Logger.debug("Pup #{self} collided with #{obj}. #{"Destroyed!" if destroy})")
    self.dispose
  end

  def targets
    [@config[:targets] || @config[:target]].flatten
  end

  # return all except the config-exclusive keys
  def effect
    effect = @config.except(CONFIG_KEYS).deep_clone
    Logger.trace("#{self} been asked for effect... which is... #{effect}")
    effect
  end

  def type
    self.class.to_s.downcase
  end

  def to_s
    "<#{self.class}> '#{self.name}'"
  end
end


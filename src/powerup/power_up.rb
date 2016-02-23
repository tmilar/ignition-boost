class PowerUp < GameEntity

  #PowerUp defaults
  DEFAULTS = {
      name: "powerup0",
      target: "player",
      speed: 1,                 ## PowerUp move speed
      destructible?: false,
      movement_style: "linear_movement",
      direction: Point.new(0, 1)
      # hold: false,
      # effect: ""
  }

  # Keys that don't involve the PUP effect to be excluded when asking for effect stats
  CONFIG_KEYS = [:name, :target, :destructible?, :speed, :movement_style, :direction] ## :hold, :effect]

  # Los powerUp multiplican o suman a un stat. Si el valor es +ENTERO o -ENTERO, sera suma/resta.
# Si es DECIMAL (con "punto" - de 0.0 en adelante) es un factor que se MULTIPLICA. Ej. 0.1, 1.5, 2.0, etc..
# Por ahora ademas, lo que puede cambiar es>
# >>> del JUEGO ->  spawn_cooldown  ; y  stats de naves

  attr_readers_delegate :@config, :speed, :target, :destructible?, :name, :movement_style, :direction

  def initialize(config={})
    Logger.start("#{self.class}", config, DEFAULTS)
    @config = DEFAULTS.merge(config).deep_clone
    @effect_stats = @config.except(CONFIG_KEYS).deep_clone
    super(@config)
  end

  def sprite_init
    Sprite.create({
        bitmap: @config[:name],
        name: @config[:name],
        init_pos: self.position_init
    })
  end

  def position_init
    lambda { |sprite| Point.new( rand(Graphics.width - sprite.width) , - sprite.height + 1 ) }
  end

  def update
    super
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
    Logger.trace("#{self} been asked for effect... which is... #{@effect_stats}")
    @effect_stats
  end

  def type
    self.class.to_s.downcase
  end

  def to_s
    "<#{self.class}> '#{self.name}'"
  end
end


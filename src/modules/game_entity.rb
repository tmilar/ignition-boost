# ## Ship (Player or Enemy), Weapon, PowerUp, Bullet
### Physical game objects which can be moved, collide, etc.
### All of these should include this common behavior.
class GameEntity
  # include Node
  include Subject
  extend Forwardable

  attr_accessor :sprite
  def_delegators :@sprite, :zoom_x, :zoom_y, :height, :width, :bitmap, :ox, :oy
  def_delegators :@sprite, :dispose, :disposed?, :flash

  attr_accessor :movement
  def_delegators :@movement, :x, :y, :position, :position=, :rectangle, :rectangle=, :collision_rect

  attr_accessor :stats

  attr_accessors_delegate :@config, :movement_style, :direction

  DEFAULTS_ENTITY = {
      movement_style: "no_movement",
      direction: :DOWN,
      # sprite: nil,
      observers: nil
  }

  def initialize(config)

    @config = DEFAULTS_ENTITY.deep_clone.deep_merge(config).deep_clone
    Logger.trace("initialiced Game Entity with conf #{@config}")

    super(@config)

    self.sprite = sprite_init
    Logger.debug("inited sprite is...#{self.sprite} .. with @.. #{@sprite}!")

    movement_init(self.movement_style)
  end

  ## Initialize local variable @sprite
  def sprite_init
    raise "not implemented error! #{self.class} must implement sprite_init"
  end

  ## initialize local variable @movement
  def movement_init(movement_style)
    Logger.error("Cant init movement with sprite:#{self.sprite}!") if self.sprite.nil?
    @movement = Movement.create(movement_style, {
        # observers: self.observers, TODO REMOVE
        # sprite: self.sprite,
        # direction: self.direction,
        # speed: self.speed,
        # type: self.type,
        game_entity: self
    })
  end

  ## MUST Override
  def speed
    3
  end

  ## MUST Override
  def type
    'game_entity'
  end

  def update
    self.movement.update
    self.sprite.update
  end

  def collide_with(other_obj)
    raise "NotImplementedError, #{self} must implement #collide_with method!"
  end
end
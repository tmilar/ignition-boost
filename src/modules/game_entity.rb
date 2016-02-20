# ## Ship (Player or Enemy), Weapon, PowerUp, Bullet
### Physical game objects which can be moved, collide, etc.
### All of these should include this common behavior.
module GameEntity
  # include Node
  # include Subject
  # extend Forwardable
  #
  # include Movement
  # # include Collisionable
  # # include Powerupeable
  #
  #
  # def_delegators :@sprite, :x, :y, :ox, :oy, :zoom_x, :zoom_y, :height, :width, :bitmap
  # def_delegators :@sprite, :position, :position=, :rectangle, :rectangle=, :collision_rect
  # def_delegators :@sprite, :dispose, :disposed?, :flash
  #
  # attr_accessor :sprite

  # attr_accessor :stats
  def initialize
    # @children = []
  end


  def update
    # update_movement
    # @sprite.update
  end
end
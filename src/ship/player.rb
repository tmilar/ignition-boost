# require_relative '../ship/ship'

class Player < Ship

  DEFAULTS_PLAYER = {
      cells: 3,
      limits: {
          x: [0.0, 1.0],
          y: [0.0, 1.0]
      },
      movement_style: "keyboard_movement",
      :collision_rect => {      # Define ship collision rectangle, relative to ship size.
          :x => [0.1, 0.9],
          :y => [0.2, 0.8]
      },

  }

  def initialize(config = {})
    config = DEFAULTS_PLAYER.deep_merge(config)
    Logger.trace("Config before player super... Config -> #{config}, Ancestors are #{self.class.ancestors}")
    super(config)
    init_score
  end

  def init_score
    self.score = 0
    self.high_score = $game_variables[IB::HIGH_SCORE_VAR] || 0
  end

  # @Override Ship init_position
  def position_init
    lambda { |sprite|
      # Logger.trace(" #{self} new pos is #{init_pos}, width: #{sprite.width}, height: #{sprite.height}. Graphics w: #{Graphics.width}, h: #{Graphics.height}")
      Point.new(Graphics.width / 2 - (sprite.width / 2), Graphics.height - 2*sprite.height)
    }
  end

  def update
    super
    check_item
  end


  def weapon_pos
    Point.new(self.x + self.width/2, self.y - self.height / 2)
  end

  # @return [boolean check_shoot ] if true -> ship will shoot
  def check_shoot
    Input.press?(:C)
  end

  def check_item
    return unless Input.press?(:A) && @item
    Sound.se(@item.se)
    notify_observers("item_activate", @item)
    dispose_item
  end

  def dispose_item
    @item.dispose
    @item = nil
  end

  # ---------------------------------------------------------------------
  # PROPERTIES
  # ---------------------------------------------------------------------

  def item=(item_config)
    @item = Item.new(item_config)
    Logger.trace("#{self} got new item from config: #{item_config}")
  end

  def item
    @item
  end

  def high_score
    $game_variables[IB::HIGH_SCORE_VAR]
  end

  def high_score=(hs)
    $game_variables[IB::HIGH_SCORE_VAR] = hs
    notify_observers("high_score", self.high_score)
  end

  def score
    $game_variables[IB::SCORE_VAR]
  end

  def score=(num)
    $game_variables[IB::SCORE_VAR] = num
    self.high_score = self.score if self.score > self.high_score
    notify_observers("score", self.score)
  end
end
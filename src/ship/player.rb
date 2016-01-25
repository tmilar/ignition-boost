# require_relative '../ship/ship'

class Player < Ship

  include KeyboardMovement
  include Subject

  def initialize(config = {})
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
    self.position = Point.new(Graphics.width / 2, Graphics.height - self.height)
  end

  # Scene update, one per frame
  def update
    super
    ## TODO pendiente  updatear el cell sprite de la nave, segun la direccion...
  end


  def weapon_pos
    Point.new(self.x, self.y - self.height)
  end

  # @return [boolean check_shoot ] if true -> ship will shoot
  def check_shoot
    Input.press?(:C)
  end

  # ---------------------------------------------------------------------
  # PROPERTIES
  # ---------------------------------------------------------------------

  def item_held=(item)
    @item = item
    notify_observers("item", {item: item})
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
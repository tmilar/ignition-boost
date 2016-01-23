# require_relative '../ship/ship'

class Player < Ship

  include KeyboardMovement
  include Subject

  attr_reader :hp

  def initialize(config = {})
    super(config)
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


  def destroyed?
    false
    # @hp <= 0
  end

  # ---------------------------------------------------------------------
  # PROPERTIES
  # ---------------------------------------------------------------------
  def hp=(hp)
    @stats[:hp] = hp
    Logger.debug("Player hp changed, now is #{@stats[:hp]}")
    notify_observers("hp", {hp: @stats[:hp], mhp: @stats[:mhp]})
    notify_observers("game_over", {result: 'loss'}) if @stats[:hp] < 0
  end


  def item_held=(item)
    @item = item
    notify_observers("item", {item: item})
  end

  def high_score
    $game_variables[IB::HIGH_SCORE_VAR]
  end

  def high_score=(hs)
    $game_variables[IB::HIGH_SCORE_VAR] = hs
    notify_observers("high_score", {high_score: self.high_score})
  end

  def score
    $game_variables[IB::SCORE_VAR]
  end

  def score=(num)
    $game_variables[IB::SCORE_VAR] = num
    self.high_score = self.score if self.score > self.high_score
    notify_observers("score", {score: self.score})
  end

end
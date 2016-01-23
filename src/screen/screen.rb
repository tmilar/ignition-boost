class Screen

  def initialize(viewport)
    @reactions = {
        'score' => lambda { |scores| draw_scores(scores) },
        'high_score' => lambda { |hs| draw_scores(hs) },
        'hp' => lambda { |hp_data| draw_hp_bar(hp_data) },
        'nuke' => lambda { |_| init_nuke },
        'time' => lambda { |time| draw_time(time)},
        'game_over' => lambda { |result| init_game_over(result) },
        'item' => lambda { |item| draw_item_hold(item)}
    }

    @viewport = viewport
    @game_over = false
    init_window
  end


  def init_window
    @window = Window_Base.new(0, 0, Graphics.width, Graphics.height)
    @window.opacity = 0
    draw_scores({score: 0, high_score: 0})
    draw_hp_bar({rate: 1.0})
    init_item_hold
  end

  def init_nuke
    Logger.debug("Initializing nuke! ")
    @nuke = Sprite.new
    @nuke.bitmap = Bitmap.new(Graphics.width,Graphics.height)
    @nuke.bitmap.fill_rect(@flash.bitmap.rect,Color.new(255,255,255))
    @nuke.z = 2000
    @nuke.opacity = 0
  end

  def init_item_hold
    Logger.debug("Initializing item_hold! ") ###TODO

    @item_held = Sprite.new
    @item_held.x = Graphics.width / 4 + 40
    @item_held.y = 15
    @item_held.z = 100
  end

  def draw_item_hold(data = nil)
    @item_held.bitmap.dispose if @item_held.bitmap
    @item_held.opacity = 255
    return @item_held.opacity = 0 if data.nil?
    @item_held.bitmap = Cache.space(data[:item])
  end

  def init_game_over(result)
    case result
      when "win" then Sound.bgm(IB:BGM_WIN)
      when "loss" then Sound.bgm(IB:BGM_LOSS)
      else raise "Game over result #{result} invalid."
    end

    Logger.debug("Initializing game_over! Result: #{result}")

    @game_over = Sprite.new
    @game_over.bitmap = Cache.space("game-#{result}")
    @game_over.opacity = 0
    @game_over.z = 500
  end

  def draw_hp_bar(hp_data)
    x, y = 4, 0
    width = Graphics.width / 4
    rate = hp_data[:rate] || hp_data[:hp] / hp_data[:mhp].to_f || 1.0
    color1 = @window.text_color(1)
    color2 = @window.text_color(2)

    Logger.debug("Drawing hp_bar with HP data %#{rate*100}.")
    @window.draw_gauge(x, y, width, rate, color1, color2)
  end

  def draw_scores(scores)
    contents = @window.contents
    contents.clear
    window_draw_score("Score: ", scores[:score], 4, 0, contents.width - 8) if scores.key?(:score)
    window_draw_score("MaxScore: ", scores[:high_score], -(Graphics.width / 2) + 70, 0, contents.width - 8) if scores.key?(:high_score)
  end

  def window_draw_score(score_text, score_value, x, y, width)
    align = 2
    cx = @window.text_size(score_value).width
    lh = @window.line_height
    @window.draw_text(x, y, width - cx - 2, lh, score_text  , align)
    @window.draw_text(x, y, width         , lh, score_value , align)
  end

  def update
    @window.update
    update_game_over
    update_nuke
  end

  def update_nuke
    return unless @nuke
  end

  def update_game_over
    return unless @game_over
    @game_over.opacity += 3
    if @game_over.opacity >= 255 #&& Input.trigger?(:C)
      SceneManager.goto(Scene_Map)
    end
  end

  def notified(msg, data={})
    @reactions[msg].call(data)
  end

  def dispose
    Logger.debug("Disposing screen objects...")
    @item_held.bitmap.dispose if @item_held.bitmap
    @window.dispose
  end
end
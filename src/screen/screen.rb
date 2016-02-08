class Screen


  def initialize(viewport)
    @reactions = {
        'score' => lambda { |score| draw_score(score) },
        'high_score' => lambda { |hs| draw_high_score(hs) },
        'player_hp' => lambda { |player| draw_hp_bar(player) },
        'nuke' => lambda { |_| init_nuke },
        'game_over' => lambda { |result| init_game_over(result) },
        'item' => lambda { |item| draw_item_held(item)}
    }

    @viewport = viewport
    @game_over = false
    init_window
  end



  def init_window
    @window = Window_Base.new(0, 0, Graphics.width, Graphics.height)
    @window.opacity = 0
    draw_score(0)
    draw_high_score(0)
    draw_hp_bar
    init_item_held
    draw_item_held
  end

  def init_nuke
    Logger.debug("Initializing nuke! ")
    @nuke = Sprite.new
    @nuke.bitmap = Bitmap.new(Graphics.width,Graphics.height)
    @nuke.bitmap.fill_rect(@nuke.bitmap.rect,Color.new(255,255,255))
    @nuke.z = 2000
    @nuke.opacity = 0
  end

  def init_item_held
    Logger.debug("Initializing item_hold! ") ###TODO

    @item_held = Sprite.new
    @item_held.x = Graphics.width / 4 + 40
    @item_held.y = 15
    @item_held.z = 100
  end

  def draw_item_held(item = nil)
    @item_held.bitmap.dispose if @item_held.bitmap
    @item_held.opacity = 255
    return @item_held.opacity = 0 if item.nil?
    @item_held.bitmap = Cache.space(item[:name])
  end

  def init_game_over(result)
    return if @game_over

    Sound.fade(10)
    case result
      when "win"  then Sound.me(IB::ME_WIN)
      when "loss" then Sound.me(IB::ME_LOSS)
      else raise "Game over result #{result} invalid."
    end

    Logger.debug("Initializing game_over! Result: #{result}")
    @game_over = Sprite.new
    @game_over.bitmap = Cache.space("game-#{result}")
    @game_over.opacity = 0
    @game_over.z = 500
  end

  def draw_hp_bar(player={})
    x, y = 4, 0
    width = Graphics.width / 4
    rate = player.nil_empty? ?  1.0 : player.stats[:hp] / player.stats[:mhp].to_f
    color1 = @window.text_color(1)
    color2 = @window.text_color(2)

    Logger.debug("Drawing hp_bar with HP data %#{rate*100}.")
    @window.draw_gauge(x, y, width, rate, color1, color2)
  end

  def draw_score(score)
    return unless score
    align = 2
    score_text = "Score: #{score}"
    width = @window.text_size(score_text).width + 8
    height = @window.line_height
    x = Graphics.width - width - 35
    y = 0

    rect = Rect.new(x, y, width, height)
    @window.contents.clear_rect(rect)
    @window.draw_text(rect, score_text, align)
  end

  def draw_high_score(highscore)
    return unless highscore
    align = 0
    score_text = "MaxScore: #{highscore}"
    width = @window.text_size(score_text).width + 8
    height = @window.line_height
    x = Graphics.width / 2 - (width / 2)
    y = 0

    rect = Rect.new(x, y, width, height)
    @window.contents.clear_rect(rect)
    @window.draw_text(rect, score_text, align)
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
    if @game_over.opacity >= 255 && Input.trigger?(:C)
      SceneManager.goto(Scene_Map)
      @game_over = false
    end
  end

  def notified(msg, data={})
    Logger.trace("Screen received notification '#{msg}', with data #{data}... #{"But is not considered." unless @reactions.key?(msg)}")
    @reactions[msg].call(data) if @reactions.key?(msg)
  end

  def dispose
    Logger.debug("Disposing screen objects...")
    @item_held.bitmap.dispose if @item_held.bitmap
    @window.dispose
  end
end
class Main_IB < Scene_Base

  @@game_time = 0
  @@frames_in_second = 0
  @@elapsed_time_frames = 0

  def start
    $game_system.save_bgm
    super
    SceneManager.clear
    Graphics.freeze
    initialize_game
  end

  def initialize_game
    configure
    init_variables
    init_screen
    start_level
  end


  def configure
    Cache.relative_path(IB::GRAPHICS_ROOT)
    @viewport1 = Viewport.new()
    Sprite.setup(@viewport1)
    Logger.config(IB::DEBUG[:logger_level]) if IB::DEBUG.key?(:logger_level)
  end

  def init_variables
    Ship.count = 0
    @@game_time = 0
    @@start_time = Time.now
    @@old_second = -1
    @@current_second = @@start_time.sec
    @@frames_in_second = 0
    @@elapsed_time_frames = 0
  end

  def init_screen
    @screen = Screen.new(@viewport1)
  end


  def start_level
    @current_level_config = IB::current_level
    Logger.info("Starting new level! #{@current_level_config[:name]}") ## #{IB::current_level[:name]}")
    Level.pre_config(@current_level_config)
    @level = Level.new(@current_level_config)
    @level.screen_observe(@screen)
    Logger.debug("Configured level >> #{@level}")
  end

  def update
    super
    @@game_time += 1
    update_frames_in_second

    update_level
    update_screen
    check_exit
  end

  def update_frames_in_second
    @current_second = Time.now.sec
    @@frames_in_second = 0 if @old_second != @current_second
    @@frames_in_second += 1
    @@elapsed_time_frames += 1
    @old_second = @current_second
  end

  def check_exit
    if Input.trigger?(:B)
      SceneManager.goto(Scene_Map)
    end
  end

  def update_screen
    @screen.update
  end

  def update_level
    @level.update
  end


  def terminate
    super
    SceneManager.snapshot_for_background
    dispose_graphics
    Level.post_config(@current_level_config)
    $game_system.replay_bgm
  end

  def dispose_graphics
    @level.dispose
    @screen.dispose
    Logger.info( "<< FAKE >> all graphics disposed!!")
  end


  def self.game_time
    @@game_time / 60
  end

  def self.elapsed_time
    ((Date.now - @@start_time)*1000.0).to_i
  end

  def self.elapsed_time_frames
    @@elapsed_time_frames
  end

  def self.frames_in_second
    @@frames_in_second
  end

end

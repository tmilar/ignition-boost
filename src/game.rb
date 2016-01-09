#------------------------------------------------------------------------------#
#  SCRIPT CALL:
#------------------------------------------------------------------------------#
#  SceneManager.call(Scene_Invaders)       # Starts the minigame.
#------------------------------------------------------------------------------#

($imported ||= {})["Galv_Invaders"] = true
module Galv_SI

  #------------------------------------------------------------------------------#
  #  SCRIPT SETTINGS
  #------------------------------------------------------------------------------#

  #----------------#
  # PLAYER OPTIONS #
  #----------------#

  PLAYER_SHIELDS = 10  # Hits player can take before game over

  SHOOTING_COOLDOWN = 5 #cooldown entre cada tiro
  MAX_SHOTS = 10    # Maxium number of shots player can have on screen at a time
  Max_Gun_Level = 5 # Max gun powerup level (5 is the highest)

  SE = ["Attack2",80,150]  # "SE_Name",volume,pitch - SE for player laser
  SE1 = ["Heal5",80,160]  # "SE_Name",volume,pitch - SE for player lazorball
  NSE = ["Explosion3",120,100]  # "SE_Name",volume,pitch - SE for nuke

  PSE = ["Damage5",90,150]  # "SE_Name",volume,pitch - SE when player damaged
  KSE = ["Explosion7",100,100]  # "SE_Name",volume,pitch - SE when destroyed

  BSE = ["Down4",120,150]  # "SE_Name",volume,pitch - SE when bonus shield gain
  PUSE = ["Item1",80,150]  # "SE_Name",volume,pitch - SE when get powerup

  SHIP_SPEED = 5        # Speed at which player can move ship left and right
  LAZOR_SPEED = 5       # Speed the lazor fires


  #---------------#
  # ENEMY OPTIONS #
  #---------------#


  SPAWN_SPEED = 100    # Lower means faster spawn. Higher is slower spawn.

  LEVEL2 = 20          # Seconds until level 2 ships can start spawning
  LEVEL3 = 50         # Seconds until level 3 ships can start spawning
  LEVEL4 = 80         # Seconds until level 3 ships can start spawning

  LEVEL1_HP = 1        # Level 1 enemies have this much hp
  LEVEL2_HP = 3        # Level 2 enemies have this much hp
  LEVEL3_HP = 6        # Level 3 enemies have this much hp
  LEVEL4_HP = 12       # Level 4 enemies have this much hp

  ELAZOR_SPEED = 5     # Enemy lazor speed

  ASE = ["Attack2",80,110]  # "SE_Name",volume,pitch - SE for enemy shooting
  DSE = ["Fire3",90,150]  # "SE_Name",volume,pitch - SE for enemy dying


  #---------------#
  # OTHER OPTIONS #
  #---------------#

  SCORE_VAR = 100         # Variable id to keep track of score
  HIGH_SCORE_VAR = 101    # Variable id to keep track of highest score

  POWERUP_FREQUENCY = 2   # Frecuencia en la q aparecen pups,
  # entre mayor numero, mayor PROBABILIDAD de que aparezca.
  # si es 0 entonces no aparece ninguno.

  RESET_PUP = 40        # Seconds between reset powerup spawns. If the
  # player manages to get this, the enemy spawn rate is
  # reset and has a chance to earn more points!
  RESET_AMOUNT = 0.5    # Ratio of difficulty when reset powerup is obtained

  SOUND_TIMER = 5       # Prevent enemy lazor sound spam by increasing this

  DESTROY_PUPS = false      # Can destroy powerups true or false

  LAZOR_DAMAGE = 1      # Damage done when lazors hit
  COLLIDE_DAMAGE = 2    # Damage done when collide with enemy


  BGM = ["Battle2", 150, 110] #musica de fondo: ["BGM_Name",volume,pitch]

  GRAPHICS_ROOT = "Graphics/Invaders/"

  #Nombre de las imagenes, no incluir la terminacion .png
  FONDO = "backdrop"

  NAVE_PLAYER = "player"

  NAVE_ENEMIGO = "alien" #debe haber un tipo único por nivel (por
  #ej "alien"), pero en el directorio, los 3
  #empezar con el mismo nombre, y los 3 terminar
  #con 0, 1 o 2, por ej. "alien0.jpg",
  #"alien1.png", "alien2.jpg".


  #------------------------------------------------------------------------------#
  #  END OF SCRIPT SETTINGS
  #------------------------------------------------------------------------------#
end


#-------------------------------------------------------------------------------
#  CACHE
#-------------------------------------------------------------------------------



module Cache
  def self.space(filename)
    load_bitmap(Galv_SI::GRAPHICS_ROOT, filename)
  end
end # module Cache


#-------------------------------------------------------------------------------
#  SCENE
#-------------------------------------------------------------------------------

class Scene_Invaders < Scene_Base
  def start
    $game_system.save_bgm
    super
    SceneManager.clear
    Graphics.freeze
    initialize_game
  end

  def initialize_game
    play_bgm
    init_variables
    create_backdrop
    create_sprites
    create_stats
  end

  def play_bgm
    ##m = Galv_SI::BGM_LIST[rand(Galv_SI::BGM_LIST.count)]
    m = Galv_SI::BGM
    RPG::BGM.new(m[0],m[1],m[2]).play
  end

  def init_variables
    @nukeall = false
    @sound_timer = Galv_SI::SOUND_TIMER
    @enemy_wave = 1
    @guns = 1
    @gun_type = 0
    @bonus_shields = 0
    @reset_pup = Galv_SI::RESET_PUP * 60
    @player_shields = Galv_SI::PLAYER_SHIELDS
    $game_variables[Galv_SI::SCORE_VAR] = 0
    @plazors = []
    @elazors = []
    @enemies = []
    @explodes = []
    @pups = []
    @spawn_timer = rand(Galv_SI::SPAWN_SPEED)
    @ticker = 100
    @game_time = 0
    @alien_count = 0
    @pups_count = 0
    @difficulty = 0.to_f
    @finished = false

    @shooting_cooldown = Galv_SI::SHOOTING_COOLDOWN
  end

  def create_backdrop
    @backdrop = Plane.new
    @backdrop.bitmap = Cache.space(Galv_SI::FONDO)
    @backdrop.z = -1
    @flash = Sprite.new
    @flash.bitmap = Bitmap.new(Graphics.width,Graphics.height)
    @flash.bitmap.fill_rect(@flash.bitmap.rect,Color.new(255,255,255))
    @flash.z = 2000
    @flash.opacity = 0
  end

  def create_sprites
    @player = Sprite_Player.new(@viewport1)
    @item_held = Sprite.new
    @item_held.x = Graphics.width / 4 + 40
    @item_held.y = 15
    @item_held.z = 100
  end

  def draw_item_held
    @item_held.bitmap.dispose if @item_held.bitmap
    @item_held.opacity = 255
    return @item_held.opacity = 0 if @item.nil?
    @item_held.bitmap = Cache.space("item_" + @item.to_s)
  end

  def create_stats
    @score_window = Window_InvaderScore.new
    @score_window
  end

  def play_time
    @game_time / 60
  end

  def update
    update_flash
    @game_time += 1
    @reset_pup -= 1
    super
    update_backdrop
    update_player
    update_splosions
    update_plazors
    update_elazors
    update_enemies
    update_pups
    if !@finished
      update_spawn
    else
      update_game_over
    end
  end

  def update_flash
    @flash.opacity -= 3 if @flash.opacity > 0
  end

  def update_backdrop
    @backdrop.oy -= 1
  end

  def update_spawn
    #ver si termino el anuncio inicial, para demorar naves
    # if  Input::press?(:C)
    #  @spawn_timer = 500
    #Game_Interpreter::msgbg("claroquesi",-80)
    #end

    if @spawn_timer <= 0
      t = alien_type
      if rand(alien_type).to_i == alien_type
        @enemies << Sprite_Alien.new(@viewport1,@alien_count,t)
        @alien_count += 1
      else
        @enemies << Sprite_Alien.new(@viewport1,@alien_count,0)
        @alien_count += 1
      end
      @spawn_timer = 50 + rand(Galv_SI::SPAWN_SPEED) / 2 - @difficulty
    end
    @ticker -= 1
    if @ticker <= 0
      @difficulty += 1
      @ticker = 100
    end
    @spawn_timer -= 1
  end

  def alien_type
    r = rand(play_time)
    if r < Galv_SI::LEVEL2
      return 0
    elsif r < Galv_SI::LEVEL3
      return 1
    elsif r < Galv_SI::LEVEL4
      return 2
    else
      return 3
    end
  end

  def update_player
    @player.update
    update_player_actions
  end

  def init_game_over
    RPG::BGM.fade(10)
    @game_over = Sprite.new
    @game_over.bitmap = Cache.space("game-over")
    @game_over.opacity = 0
    @game_over.z = 500
  end

  def update_game_over
    @game_over.opacity += 3
    if @game_over.opacity >= 255 && Input.trigger?(:C)
      dispose_graphics
      initialize_game
    end
  end

  def update_player_actions
    @shooting_cooldown -= 1

    if Input.press?(:C) && !@finished  && @shooting_cooldown <= 0
      return if Galv_SI::MAX_SHOTS * @guns <= @plazors.count
      player_shoot
    end

    if Input.trigger?(:B)
      SceneManager.goto(Scene_Map)
    end
    if Input.trigger?(:X) && @item && !@finished
      @nukeall = true
      RPG::SE.new(Galv_SI::NSE[0],Galv_SI::NSE[1],Galv_SI::NSE[2]).play
      @difficulty *= 0.75
      @flash.opacity = 225
      @item = nil
      draw_item_held
    end
  end

  def player_shoot
    @shooting_cooldown = Galv_SI::SHOOTING_COOLDOWN
    case @gun_type
      when 0  # Normal Lazers
        RPG::SE.new(Galv_SI::SE[0],Galv_SI::SE[1],Galv_SI::SE[2]).play
        case @guns
          when 1
            @plazors << Sprite_Lazor.new(@viewport1,@player.x,@player.y)
          when 2
            2.times { |i|
              @plazors << Sprite_Lazor.new(@viewport1,@player.x - 20 + i * 40,@player.y)
            }
          when 3
            3.times { |i|
              @plazors << Sprite_Lazor.new(@viewport1,@player.x - 20 + i * 20,@player.y)
            }
          when 4
            4.times { |i|
              @plazors << Sprite_Lazor.new(@viewport1,@player.x - 30 + i * 20,@player.y)
            }
          when 5
            5.times { |i|
              @plazors << Sprite_Lazor.new(@viewport1,@player.x - 30 + i * 15,@player.y)
            }
        end
      when 1  # Lazer Ball
        RPG::SE.new(Galv_SI::SE1[0],Galv_SI::SE1[1],Galv_SI::SE1[2]).play
        case @guns
          when 1
            @plazors << Sprite_Lazor.new(@viewport1,@player.x,@player.y,1,0)
          when 2
            2.times { |i|
              @plazors << Sprite_Lazor.new(@viewport1,@player.x,@player.y,1,1 + i)
            }
          when 3,4,5
            @guns.times { |i|
              @plazors << Sprite_Lazor.new(@viewport1,@player.x,@player.y,1,i)
            }
        end
    end
  end


  def update_plazors
    @plazors.each_with_index { |lazor,i|
      lazor.update
      if lazor.y < -10
        lazor.dispose
        @plazors.delete_at(i)
      end
    }
  end

  def update_elazors
    @elazors.each_with_index { |lazor,i|
      next if !lazor
      lazor.update
      if lazor.y > Graphics.height
        lazor.dispose
        @elazors[i] = false
      elsif #lazor.y > (Graphics.height - @player.height) &&
      player_hit?(lazor.x,lazor.y)
        damage_player(Galv_SI::LAZOR_DAMAGE)
        lazor.dispose
        @elazors[i] = false
      end
    }
  end

  def update_enemies
    @sound_timer += 1
    @enemies.each_with_index { |enemy,i|
      next if enemy.nil?
      enemy.update
      if enemy_hit?(enemy) || @nukeall
        enemy.hp -= @nukeall ? enemy.mhp : 1
        if enemy.hp <= 0
          destroy_enemy(enemy.mhp)
          @explodes << Sprite_Splosion.new(@viewport1,enemy.x,enemy.y)
          enemy.dispose
          @enemies[i] = nil
        else
          RPG::SE.new(Galv_SI::PSE[0],Galv_SI::PSE[1],Galv_SI::PSE[2]).play
          enemy.flash(Color.new(255,155,155),20)
        end
      elsif #enemy.y > (Graphics.height - @player.height) &&
      player_hit?(enemy.x,enemy.y)
        destroy_enemy(enemy.mhp)
        @explodes << Sprite_Splosion.new(@viewport1,enemy.x,enemy.y)
        enemy.dispose
        @enemies[i] = nil
        damage_player(Galv_SI::COLLIDE_DAMAGE)
      elsif rand(1000) > (995 - @difficulty)
        if @elazors[i].nil?
          if @sound_timer >= Galv_SI::SOUND_TIMER
            RPG::SE.new(Galv_SI::ASE[0],Galv_SI::ASE[1],Galv_SI::ASE[2]).play
            @sound_timer = 0
          end
          @elazors[i] = Sprite_ELazor.new(@viewport1,enemy.x,enemy.y)
        end
      end
    }
    @nukeall = false
  end

  def update_pups
    if @reset_pup <= 0
      @pups << Sprite_Powerup.new(@viewport1,@pups_count,999)
      @reset_pup = (Galv_SI::RESET_PUP + @enemy_wave) * 60
    end
    if rand(1000) > (1000 - Galv_SI::POWERUP_FREQUENCY) && !@finished
      @pups << Sprite_Powerup.new(@viewport1,@pups_count,rand(4))
      @pups_count += 1
    end
    @pups.each_with_index { |pup,i|
      next if pup.nil?
      pup.update
      if enemy_hit?(pup,false) && Galv_SI::DESTROY_PUPS
        RPG::SE.new(Galv_SI::DSE[0],Galv_SI::DSE[1],Galv_SI::DSE[2]).play
        @explodes << Sprite_Splosion.new(@viewport1,pup.x,pup.y)
        pup.dispose
        @pups[i] = nil
      elsif #pup.y > (Graphics.height - @player.height) &&
      player_hit?(pup.x,pup.y)
        do_powerup(pup.type)
        pup.dispose
        @pups[i] = nil
      end
    }
  end

  def do_powerup(type)
    @player.flash(Color.new(155,255,155),20)
    case type
      when 0 # Shield Restore
        RPG::SE.new(Galv_SI::BSE[0],Galv_SI::BSE[1],Galv_SI::BSE[2]).play
        @player_shields = Galv_SI::PLAYER_SHIELDS
        @score_window.refresh(@player_shields.to_f,@bonus_shields)
      when 1 # Gun Type: 0 (Normal Lazor)
        RPG::SE.new(Galv_SI::PUSE[0],Galv_SI::PUSE[1],Galv_SI::PUSE[2]).play
        if @gun_type != 0
          @gun_type = 0
        elsif @guns < Galv_SI::Max_Gun_Level
          @guns += 1
        end
      when 2 # Gun Type: 1 (Lazor Ball)
        RPG::SE.new(Galv_SI::PUSE[0],Galv_SI::PUSE[1],Galv_SI::PUSE[2]).play
        if @gun_type != 1
          @gun_type = 1
        elsif @guns < Galv_SI::Max_Gun_Level
          @guns += 1
        end
      when 3
        RPG::SE.new(Galv_SI::PUSE[0],Galv_SI::PUSE[1],Galv_SI::PUSE[2]).play
        @item = "nuke"
        draw_item_held
      when 999 # Reset
        RPG::SE.new(Galv_SI::PUSE[0],Galv_SI::PUSE[1],Galv_SI::PUSE[2]).play
        @difficulty *= Galv_SI::RESET_AMOUNT
        @enemy_wave += 1
    end
  end

  def damage_player(amount)
    RPG::SE.new(Galv_SI::PSE[0],Galv_SI::PSE[1],Galv_SI::PSE[2]).play
    @player.flash(Color.new(255,155,155),20)
    if @bonus_shields > 0
      @bonus_shields = [@bonus_shields - amount,0].max
    else
      @player_shields -= amount
    end
    @score_window.refresh(@player_shields.to_f,@bonus_shields)
    destroy_player if @player_shields <= 0
  end

  def destroy_enemy(score)
    RPG::SE.new(Galv_SI::DSE[0],Galv_SI::DSE[1],Galv_SI::DSE[2]).play
    $game_variables[Galv_SI::SCORE_VAR] += score
    if $game_variables[Galv_SI::SCORE_VAR] > $game_variables[Galv_SI::HIGH_SCORE_VAR]
      $game_variables[Galv_SI::HIGH_SCORE_VAR] += score
    end
    @score_window.refresh(@player_shields.to_f,@bonus_shields)
  end

  def destroy_player
    @player_shields = 0
    @explodes << Sprite_Splosion.new(@viewport1,@player.x,@player.y,2)
    @player.opacity = 0
    @player.x = -100
    RPG::SE.new(Galv_SI::KSE[0],Galv_SI::KSE[1],Galv_SI::KSE[2]).play
    @score_window.refresh(@player_shields.to_f,@bonus_shields)
    init_game_over
    @finished = true
  end

  def update_splosions
    @explodes.each_with_index { |ex,i|
      ex.update
      if ex.finished?
        ex.dispose
        @explodes.delete_at(i)
      end
    }
  end

  def player_hit?(x,y)
    if x.between?(@player.x - player_width / 6, @player.x + player_width / 6) &&
        y.between?(@player.y - player_height, @player.y)
      return true
    end
    return false
  end

  def enemy_hit?(enemy, kill = true)
    @plazors.each_with_index { |lazor,i|
      if lazor.x.between?(enemy.x - enemy.width / 2, enemy.x + enemy.width / 2) &&
          lazor.y.between?(enemy.y - enemy.height / 2, enemy.y + enemy.height / 2)
        if kill
          lazor.dispose
          @plazors.delete_at(i)
        end
        return true
      end
    }
    false
  end

  def player_width
    @player.bitmap.width
  end
  def player_height
    @player.bitmap.height
  end

  def terminate
    super
    SceneManager.snapshot_for_background
    dispose_graphics
    $game_system.replay_bgm
  end

  def dispose_graphics
    @item_held.bitmap.dispose if @item_held.bitmap
    @plazors.each { |object| object.dispose if object }
    @elazors.each { |object| object.dispose if object }
    @enemies.each { |object| object.dispose if object }
    @explodes.each { |object| object.dispose if object }
    @pups.each { |object| object.dispose if object }
    @backdrop.bitmap.dispose
    @backdrop.dispose
    @player.bitmap.dispose
    @player.dispose
    if @game_over
      @game_over.bitmap.dispose
      @game_over.dispose
    end
    @score_window.dispose
  end
end # Scene_Invaders < Scene_Base

#-------------------------------------------------------------------------------
#  PLAYER SPRITE
#-------------------------------------------------------------------------------

class Sprite_Player < Sprite
  def initialize(viewport)
    super(viewport)
    init_position
  end

  def init_position
    setup_player_image
  end

  def dispose
    super
  end

  def update
    super
    update_src_rect
    update_position
  end

  def setup_player_image
    @cell = 1
    self.bitmap = Cache.space(Galv_SI::NAVE_PLAYER)
    @cw = bitmap.width / 3
    self.src_rect.set(@cell * @cw, 0, @cw, height)
    self.ox = @cw / 2
    self.oy = height
    self.x = Graphics.width / 2
    self.y = Graphics.height - height / 4
  end

  def width
    self.bitmap.width / 3
  end
  def height
    self.bitmap.height
  end

  def update_src_rect
    @cell = 1 if @cell > 3
    sx = @cell * @cw
    self.src_rect.set(sx, 0, @cw, height)
  end

  def update_position
    if Input.press?(:LEFT) && !Input.press?(:RIGHT)
      @cell = 0
      self.x -= Galv_SI::SHIP_SPEED if self.x > width / 2
    elsif Input.press?(:RIGHT) && !Input.press?(:LEFT)
      @cell = 2
      self.x += Galv_SI::SHIP_SPEED if self.x < Graphics.width - width / 2
    else
      @cell = 1
    end

    if Input.press?(:UP) #&& !Input.press?(:LEFT)
      #@cell = 1
      self.y -= Galv_SI::SHIP_SPEED if self.y > height / 2
    end
    if Input.press?(:DOWN) #&& !Input.press?(:LEFT)
      #@cell = 1
      self.y += Galv_SI::SHIP_SPEED if self.y < Graphics.height - height / 4
    end

  end
end # Sprite_Player < Sprite


#-------------------------------------------------------------------------------
#  LAZOR SPRITES
#-------------------------------------------------------------------------------

class Sprite_Lazor < Sprite
  def initialize(viewport,x,y,type = 0,dir = 0)
    super(viewport)
    self.x = x
    self.y = y - 20
    @type = type
    @dir = dir
    setup_lazor_image
  end

  def dispose
    super
  end

  def update
    super
    update_position
  end

  def setup_lazor_image
    case @type
      when 0
        self.bitmap = Cache.space("lazor")
      when 1
        self.bitmap = Cache.space("lazor_ball")
    end
    self.ox = bitmap.width / 2
    self.oy = bitmap.height / 2
  end

  def update_position
    self.y -= Galv_SI::LAZOR_SPEED
    case @dir
      when 1
        self.x -= Galv_SI::LAZOR_SPEED.to_f / 4
      when 2
        self.x += Galv_SI::LAZOR_SPEED.to_f / 4 + 1
      when 3
        self.x -= Galv_SI::LAZOR_SPEED
      when 4
        self.x += Galv_SI::LAZOR_SPEED
    end
  end
end # Sprite_Lazor < Sprite


class Sprite_ELazor < Sprite
  def initialize(viewport,x,y)
    super(viewport)
    self.x = x
    self.y = y - 20
    setup_lazor_image
  end

  def dispose
    super
  end

  def update
    super
    update_position
  end

  def setup_lazor_image
    self.bitmap = Cache.space("elazor")
    self.ox = bitmap.width / 2
    self.oy = bitmap.height / 2
  end

  def update_position
    self.y += Galv_SI::ELAZOR_SPEED
  end
end # Sprite_ELazor < Sprite

#-------------------------------------------------------------------------------
#  ALIEN SPRITES
#-------------------------------------------------------------------------------

class Sprite_Alien < Sprite
  attr_accessor :hp
  attr_reader :mhp

  def initialize(viewport,id,type = 0)
    super(viewport)
    @type = type
    @id = id
    @move = true   # true is right, false is left
    @speed = rand(2) + 1
    @ticker = 0
    setup_enemy
    init_position
  end

  def init_position
    self.x = rand(Graphics.width)
    self.y = -10
  end

  def dispose
    super
  end

  def update
    super
    update_move
  end

  def update_move
    case @move
      when true  # Right
        self.x += 1 * (@ticker * 0.06) if self.x <= Graphics.width
      when false # Left
        self.x -= 1 * (@ticker * 0.06) if self.x > 0
    end
    @ticker -= 1
    self.y += @speed
    if @ticker <= 0
      @move = self.x < Graphics.width / 2 ? true : false
      @ticker = rand(90)
    end
  end

  def setup_enemy
    self.bitmap = Cache.space(Galv_SI::NAVE_ENEMIGO  + @type.to_s)
    self.ox = bitmap.width / 2
    self.oy = bitmap.height / 2

    case @type
      when 0
        @hp = Galv_SI::LEVEL1_HP
      when 1
        @hp = Galv_SI::LEVEL2_HP
      when 2
        @hp = Galv_SI::LEVEL3_HP
        @speed = 1
      when 3
        @hp = Galv_SI::LEVEL4_HP
        @speed = 1
    end
    @mhp = @hp
  end

  def width
    self.bitmap.width
  end
  def height
    self.bitmap.height
  end
end # Sprite_Alien < Sprite

#-------------------------------------------------------------------------------
#  EXPLOSION SPRITES
#-------------------------------------------------------------------------------

class Sprite_Splosion < Sprite
  def initialize(viewport,x,y,zoom = 1)
    super(viewport)
    self.x = x
    self.y = y
    @timer = 10
    setup_explosion_image(zoom)
  end

  def dispose
    super
  end

  def update
    super
    wait_for_timer
  end

  def setup_explosion_image(zoom)
    self.bitmap = Cache.space("explode")
    self.ox = bitmap.width / 2
    self.oy = bitmap.height / 2
    self.zoom_x = zoom
    self.zoom_y = zoom
  end

  def wait_for_timer
    @finished = true if @timer <= 0
    @timer -= 1
  end

  def finished?
    @finished
  end
end # Sprite_Splosion < Sprite


#-------------------------------------------------------------------------------
#  POWERUP SPRITES
#-------------------------------------------------------------------------------

class Sprite_Powerup < Sprite
  attr_reader :type

  def initialize(viewport,id,type)
    super(viewport)
    @id = id
    @type = type            # 0 heal   1 lazor  2 lazerball  3 nuke   999 reset
    @speed = rand(1) + 1
    setup_image(type)
    init_position
  end

  def init_position
    self.x = rand(Graphics.width)
    self.y = -10
  end

  def dispose
    super
  end

  def update
    super
    update_move
  end

  def update_move
    self.y += @speed
  end

  def setup_image(type)
    self.bitmap = Cache.space("powerup" + type.to_s)
    self.ox = bitmap.width / 2
    self.oy = bitmap.height / 2
  end

  def width
    self.bitmap.width
  end
  def height
    self.bitmap.height
  end
end # Sprite_Powerup < Sprite

#-------------------------------------------------------------------------------
#  SCORE WINDOW
#-------------------------------------------------------------------------------


class Window_InvaderScore < Window_Base
  def initialize
    super(0, 0, Graphics.width, Graphics.height)
    self.opacity = 0
    refresh
  end

  def refresh(shields = Galv_SI::PLAYER_SHIELDS.to_f,bonus_shields = 0)
    contents.clear
    draw_score("Score: ", score, 4, 0, contents.width - 8, 2)
    draw_score("MaxScore: ", high_score, -(Graphics.width / 2) + 70, 0, contents.width - 8, 2)
    draw_shields(shields, 4, 0)
    draw_bonus_shields(bonus_shields)
  end

  def draw_shields(shields, x, y, width = Graphics.width / 4)
    draw_gauge(x, y, width, shields / Galv_SI::PLAYER_SHIELDS.to_f, text_color(1),
               text_color(4))
  end

  def draw_bonus_shields(x,width = Graphics.width / 4)
    w = width * x / Galv_SI::PLAYER_SHIELDS.to_f
    rect = Rect.new(4, 0, w, 12)
    contents.fill_rect(rect, text_color(1))
  end

  def score
    $game_variables[Galv_SI::SCORE_VAR]
  end
  def high_score
    $game_variables[Galv_SI::HIGH_SCORE_VAR]
  end

  def draw_score(value, unit, x, y, width, align)
    cx = text_size(unit).width
    draw_text(x, y, width - cx - 2, line_height, value, align)
    draw_text(x, y, width, line_height, unit, align)
  end

  def open
    refresh
    super
  end
end # Window_InvaderScore < Window_Base


## 1) para modificar el fondo hacer desde el juego: Galv_SI::FONDO = "nombreNuevoFondo"
## 2) para modificar la nave del jugador: Galv_SI::NAVE_PLAYER = "nueva_nave_superpower"
## 3) para modificar el pack de naves enemigas: Galv_SI::NAVE_ENEMIGO = "monster_op"
## El nombre de NAVE_ENEMIGO que usemos debe estar tener 3 imagenes, cuyo nombre de archivo debe
## estar terminado c/u en -"0.png", -"1.png" y -"2.png".
##Por ejemplo si mi nombre es "monster" , debo tener: "monster0.png", "monster1.png", etc
## 4) Cambiar Musica: Galv_SI::BGM = ["Town4", 100, 100]
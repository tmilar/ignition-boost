#------------------------------------------------------------------------------#
#  SCRIPT CALL:
#------------------------------------------------------------------------------#
#  SceneManager.call(Scene_Invaders_Boss)       # Starts the minigame.
#  v1.0.0
#------------------------------------------------------------------------------#

# Boss game script, once called, launches a level with a fight against
# a configured boss.

($imported ||= {})["Galv_Invaders"] = true
module Tomi_BOSS

  #------------------------------------------------------------------------------#
  #  SCRIPT SETTINGS
  #------------------------------------------------------------------------------#


  #----------------#
  # BOSS OPTIONS   #
  #----------------#

  BOSS_SPRITE_TYPE = "Boss" # Code of the boss sprite type, to be spawned. Also latter name of the sprite.
  BOSS_HP = 20
  BOSS_SPEED = 2


  BOSS_DIFFICULTY_INCREASE_INTERVAL = 20 # Tiempo cada cuanto se incrementa la probabilidad de disparo del jefe
  BOSS_DIFFICULTY_INCREASE_AMOUNT = 1 # Valor en que se aumenta la probabilidad de disparos del jefe terminado el intervalo

  BOSS_INITIAL_DIFFICULTY = 5 # Dificultad inicial

  BOSS_GUNS_MIN = 1 # minimum number of bullets boss can shoot
  BOSS_GUNS_MAX = 5 # maximum number of bullets boss can shoot

  BOSS_LAZOR_SPEED = 5

  BOSS_MAX_Y = 0.5  # Boss maximum height "y"  (en porcentaje de altura del mapa)
  BOSS_MIN_Y = 0.3 # boss minimum height "y"

  # TIME_BOSS_DOWN = 90 #tiempo maximo que el boss estara abajo (random de 1 a N) POR AHORA NO FUNCA
  # TIME_BOSS_UP = 90 #tiempo maximo que el boss estara arriba (random de 1 a N) POR AHORA NO FUNCA

  #----------------#
  # PLAYER OPTIONS #
  #----------------#

  PLAYER_SHIELDS = 30  # Hits player can take before game over

  SHOOTING_COOLDOWN = 5 #cooldown entre cada tiro
  MAX_SHOTS = 10    # Maxium number of shots player can have on screen at a time
  MAX_GUN_LEVEL = 5 # Max gun powerup level (5 is the highest)

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

  AVAILABLE_PUPS = [0,1,2] #  Available pups on map. 0 heal  1 lazor  2 lazerball  3 nuke  999 reset

  POWERUP_FREQUENCY = 2   # Frecuencia en la q aparecen pups,
  # entre mayor numero, mayor PROBABILIDAD de que aparezca.
  # si es 0 entonces no aparece ninguno.

  RESET_PUP = 40        # Seconds between reset powerup spawns. If the
  # player manages to get this, the enemy spawn rate is
  # reset and has a chance to earn more points!
  RESET_AMOUNT = 0.5    # Ratio of difficulty when reset powerup is obtained

  SOUND_TIMER = 5       # Prevent enemy lazor sound spam by increasing this

  DESTROY_PUPS = false      # Can destroy powerups true or false

  LAZOR_DAMAGE = 1      # Damage done when ENEMY lazors hit player
  COLLIDE_DAMAGE = 2    # Damage done when collide with enemy


  BGM = ["Battle2", 150, 110] #musica de fondo: ["BGM_Name",volume,pitch]
  ME_WIN = ["Victory2", 100, 110]
  ME_LOSS = ["Gameover2", 100, 110]

  GRAPHICS_ROOT = "Graphics/Invaders/"

  #Nombre de las imagenes, no incluir la terminacion .png
  FONDO = "backdrop"

  NAVE_PLAYER = "player"

  NAVE_ENEMIGO = "alien" #debe haber un tipo único por nivel (por
  #ej "alien", esto se puede redefinir), y en el directorio, los 3
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
    load_bitmap(Tomi_BOSS::GRAPHICS_ROOT, filename)
  end
end # module Cache


#-------------------------------------------------------------------------------
#  SCENE
#-------------------------------------------------------------------------------

class Scene_Invaders_Boss < Scene_Base
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

  def play_bgm(bgm_name = '')
    ##m = Tomi_BOSS::BGM_LIST[rand(Tomi_BOSS::BGM_LIST.count)]
    m = Tomi_BOSS::BGM
    if bgm_name == "win"
      m = Tomi_BOSS::ME_WIN
      RPG::ME.new(m[0],m[1],m[2]).play
    elsif bgm_name == "loss"
      m = Tomi_BOSS::ME_LOSS
      RPG::ME.new(m[0],m[1],m[2]).play
    else
      RPG::BGM.new(m[0],m[1],m[2]).play
    end
  end

  def init_variables
    @nukeall = false
    @sound_timer = Tomi_BOSS::SOUND_TIMER
    @enemy_wave = 1
    @guns = 1
    @gun_type = 0
    @bonus_shields = 0
    @reset_pup = Tomi_BOSS::RESET_PUP * 60
    @player_shields = Tomi_BOSS::PLAYER_SHIELDS
    $game_variables[Tomi_BOSS::SCORE_VAR] = 0
    @plazors = []
    @elazors = []
    @enemies = []
    @explodes = []
    @pups = []
    @spawn_timer = rand(Tomi_BOSS::SPAWN_SPEED)
    @ticker = 100
    @game_time = 0
    @alien_count = 0
    @pups_count = 0
    @difficulty = Tomi_BOSS::BOSS_INITIAL_DIFFICULTY.to_f
    @finished = false

    @shooting_cooldown = Tomi_BOSS::SHOOTING_COOLDOWN
  end

  def create_backdrop
    @backdrop = Plane.new
    @backdrop.bitmap = Cache.space(Tomi_BOSS::FONDO)
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

    alien_type_to_spawn = Tomi_BOSS::BOSS_SPRITE_TYPE
    # when spawn_timer finishes, display new enemy BOSS sprite.
    if @spawn_timer <= 0 && @alien_count < 1
      @enemies << Sprite_Alien.new(@viewport1,@alien_count,alien_type_to_spawn)
      @alien_count += 1
    end

    # when spawn_timer finishes, display new enemy sprite.
    # if @spawn_timer <= 0
    #   alien_type_to_spawn = alien_type
    #   if rand(alien_type).to_i == alien_type
    #     @enemies << Sprite_Alien.new(@viewport1,@alien_count,alien_type_to_spawn)
    #     @alien_count += 1
    #   else
    #     @enemies << Sprite_Alien.new(@viewport1,@alien_count,0)
    #     @alien_count += 1
    #   end
    #
    #   @spawn_timer = 50 + rand(Tomi_BOSS::SPAWN_SPEED) / 2 - @difficulty
    # end

    @ticker -= 1
    if @ticker <= 0
      @difficulty += Tomi_BOSS::BOSS_DIFFICULTY_INCREASE_AMOUNT
      @ticker = Tomi_BOSS::BOSS_DIFFICULTY_INCREASE_INTERVAL
    end

    @spawn_timer -= 1
  end

  # def alien_type
  #   r = rand(play_time)
  #   if r < Tomi_BOSS::LEVEL2
  #     return 0
  #   elsif r < Tomi_BOSS::LEVEL3
  #     return 1
  #   elsif r < Tomi_BOSS::LEVEL4
  #     return 2
  #   else
  #     return 3
  #   end
  # end

  def update_player
    @player.update
    update_player_actions
  end

  def init_game_over(str_result)
    @finished = true
    RPG::BGM.fade(10)
    @game_over = Sprite.new
    if str_result == "win"
      @game_over.bitmap = Cache.space("game-win")
    elsif str_result == "loss"
      @game_over.bitmap = Cache.space("game-loss")
    end

    play_bgm(str_result)

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
      return if Tomi_BOSS::MAX_SHOTS * @guns <= @plazors.count
      player_shoot
    end

    if Input.trigger?(:B)
      SceneManager.goto(Scene_Map)
    end
    if Input.trigger?(:X) && @item && !@finished
      @nukeall = true
      RPG::SE.new(Tomi_BOSS::NSE[0],Tomi_BOSS::NSE[1],Tomi_BOSS::NSE[2]).play
      @difficulty *= 0.75
      @flash.opacity = 225
      @item = nil
      draw_item_held
    end
  end

  def player_shoot
    @shooting_cooldown = Tomi_BOSS::SHOOTING_COOLDOWN
    case @gun_type
      when 0  # Normal Lazers
        RPG::SE.new(Tomi_BOSS::SE[0],Tomi_BOSS::SE[1],Tomi_BOSS::SE[2]).play
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
        RPG::SE.new(Tomi_BOSS::SE1[0],Tomi_BOSS::SE1[1],Tomi_BOSS::SE1[2]).play
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
      if lazor.y > Graphics.height || lazor.y < -10
        lazor.dispose
        @elazors[i] = false
      elsif player_hit?(lazor.x,lazor.y)  #lazor.y > (Graphics.height - @player.height) &&
        damage_player(lazor.damage)
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

      # Check enemy boss shooting
      if rand(1000) > (995 - @difficulty)
        boss_shoot(enemy)
      end

      # check player hit collision
      if player_hit?(enemy.x,enemy.y) #enemy.y > (Graphics.height - @player.height) &&
        # BOSS DOESN'T EXPLODE ON COLLISION
        # destroy_enemy(enemy.mhp)
        # @explodes << Sprite_Splosion.new(@viewport1,enemy.x,enemy.y)
        # enemy.dispose
        # @enemies[i] = nil

        damage_player(Tomi_BOSS::PLAYER_SHIELDS)
      end

      # check enemy  hit collision or nuke
      if enemy_hit?(enemy) || @nukeall
        enemy.hp -= @nukeall ? enemy.mhp : 1
        if enemy.hp <= 0
          destroy_enemy(enemy.mhp)
          @explodes << Sprite_Splosion.new(@viewport1,enemy.x,enemy.y)
          enemy.dispose
          @enemies[i] = nil
        else
          RPG::SE.new(Tomi_BOSS::PSE[0],Tomi_BOSS::PSE[1],Tomi_BOSS::PSE[2]).play
          enemy.flash(Color.new(255,155,155),20)
        end
      end
    }
    @nukeall = false
  end

  def boss_shoot(shooting_ship)
    if @sound_timer >= Tomi_BOSS::SOUND_TIMER
      RPG::SE.new(Tomi_BOSS::ASE[0],Tomi_BOSS::ASE[1],Tomi_BOSS::ASE[2]).play
      @sound_timer = 0
    end

    enemy_center_y = shooting_ship.y - (shooting_ship.height / 2)

    boss_gun_type = 1 # por ahora solo un tipo

    case boss_gun_type
      # when 0  # Normal Lazers
      #   RPG::SE.new(Tomi_BOSS::SE[0],Tomi_BOSS::SE[1],Tomi_BOSS::SE[2]).play
      #   # case @guns
      #   #   when 1
      #   #     @plazors << Sprite_Lazor.new(@viewport1,@player.x,@player.y)
      #   #   when 2
      #   #     2.times { |i|
      #   #       @plazors << Sprite_Lazor.new(@viewport1,@player.x - 20 + i * 40,@player.y)
      #   #     }
      #   #   when 3
      #   #     3.times { |i|
      #   #       @plazors << Sprite_Lazor.new(@viewport1,@player.x - 20 + i * 20,@player.y)
      #   #     }
      #   #   when 4
      #   #     4.times { |i|
      #   #       @plazors << Sprite_Lazor.new(@viewport1,@player.x - 30 + i * 20,@player.y)
      #   #     }
      #   #   when 5
      #   #     5.times { |i|
      #   #       @plazors << Sprite_Lazor.new(@viewport1,@player.x - 30 + i * 15,@player.y)
      #   #     }
      #   # end
      when 1  # Diagonal Lazer Ball
        RPG::SE.new(Tomi_BOSS::SE1[0],Tomi_BOSS::SE1[1],Tomi_BOSS::SE1[2]).play

        boss_damage = ( shooting_ship.mhp - shooting_ship.hp ) / shooting_ship.mhp.to_f
        guns = 1 + (( 5 * boss_damage ).floor)

        #limit guns to BOSS_GUNS_MIN and BOSS_GUNS_MAX, between 1 and 5
        guns = [[guns, Tomi_BOSS::BOSS_GUNS_MIN, 1].max, Tomi_BOSS::BOSS_GUNS_MAX, 5].min

        case guns
          when 1
            @elazors << Sprite_BLazor.new(@viewport1,shooting_ship.x,enemy_center_y,1,0)
          when 2
            2.times { |i|
              @elazors << Sprite_BLazor.new(@viewport1,shooting_ship.x,enemy_center_y,1,1 + i)
            }
          when 3,4,5
            guns.times { |i|
              @elazors << Sprite_BLazor.new(@viewport1,shooting_ship.x,enemy_center_y,1,i)
            }
        end
    end

  end


  def update_pups
    if @reset_pup <= 0
      @pups << Sprite_Powerup.new(@viewport1,@pups_count,999)
      @reset_pup = (Tomi_BOSS::RESET_PUP + @enemy_wave) * 60
    end
    if rand(1000) > (1000 - Tomi_BOSS::POWERUP_FREQUENCY) && !@finished
      @pups << Sprite_Powerup.new(@viewport1,@pups_count, Tomi_BOSS::AVAILABLE_PUPS.sample)
      @pups_count += 1
    end
    @pups.each_with_index { |pup,i|
      next if pup.nil?
      pup.update
      if enemy_hit?(pup,false) && Tomi_BOSS::DESTROY_PUPS
        RPG::SE.new(Tomi_BOSS::DSE[0],Tomi_BOSS::DSE[1],Tomi_BOSS::DSE[2]).play
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
        RPG::SE.new(Tomi_BOSS::BSE[0],Tomi_BOSS::BSE[1],Tomi_BOSS::BSE[2]).play
        if @player_shields == Tomi_BOSS::PLAYER_SHIELDS
          if @bonus_shields < Tomi_BOSS::PLAYER_SHIELDS
            @bonus_shields += 1
          end
        else
          @player_shields = Tomi_BOSS::PLAYER_SHIELDS
        end
        @score_window.refresh(@player_shields.to_f,@bonus_shields)
      when 1 # Gun Type: 0 (Normal Lazor)
        RPG::SE.new(Tomi_BOSS::PUSE[0],Tomi_BOSS::PUSE[1],Tomi_BOSS::PUSE[2]).play
        if @gun_type != 0
          @gun_type = 0
        elsif @guns < Tomi_BOSS::MAX_GUN_LEVEL
          @guns += 1
        end
      when 2 # Gun Type: 1 (Lazor Ball)
        RPG::SE.new(Tomi_BOSS::PUSE[0],Tomi_BOSS::PUSE[1],Tomi_BOSS::PUSE[2]).play
        if @gun_type != 1
          @gun_type = 1
        elsif @guns < Tomi_BOSS::MAX_GUN_LEVEL
          @guns += 1
        end
      when 3
        RPG::SE.new(Tomi_BOSS::PUSE[0],Tomi_BOSS::PUSE[1],Tomi_BOSS::PUSE[2]).play
        @item = "nuke"
        draw_item_held
      when 999 # Reset
        RPG::SE.new(Tomi_BOSS::PUSE[0],Tomi_BOSS::PUSE[1],Tomi_BOSS::PUSE[2]).play
        @difficulty *= Tomi_BOSS::RESET_AMOUNT
        @enemy_wave += 1
    end
  end

  def damage_player(amount)
    RPG::SE.new(Tomi_BOSS::PSE[0],Tomi_BOSS::PSE[1],Tomi_BOSS::PSE[2]).play
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
    RPG::SE.new(Tomi_BOSS::DSE[0],Tomi_BOSS::DSE[1],Tomi_BOSS::DSE[2]).play
    $game_variables[Tomi_BOSS::SCORE_VAR] += score
    if $game_variables[Tomi_BOSS::SCORE_VAR] > $game_variables[Tomi_BOSS::HIGH_SCORE_VAR]
      $game_variables[Tomi_BOSS::HIGH_SCORE_VAR] += score
    end
    @score_window.refresh(@player_shields.to_f,@bonus_shields)

    # BOSS LEVEL ONLY - when boss destroyed, display WIN.
    init_game_over("win")

  end

  def destroy_player
    @player_shields = 0
    @explodes << Sprite_Splosion.new(@viewport1,@player.x,@player.y,2)
    @player.opacity = 0
    @player.x = -100
    RPG::SE.new(Tomi_BOSS::KSE[0],Tomi_BOSS::KSE[1],Tomi_BOSS::KSE[2]).play
    @score_window.refresh(@player_shields.to_f,@bonus_shields)
    init_game_over("loss")
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
end # Scene_Invaders_Boss < Scene_Base

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
    self.bitmap = Cache.space(Tomi_BOSS::NAVE_PLAYER)
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
      self.x -= Tomi_BOSS::SHIP_SPEED if self.x > width / 2
    elsif Input.press?(:RIGHT) && !Input.press?(:LEFT)
      @cell = 2
      self.x += Tomi_BOSS::SHIP_SPEED if self.x < Graphics.width - width / 2
    else
      @cell = 1
    end

    # In BOSS map, player can't move up nor down.

    # if Input.press?(:UP) #&& !Input.press?(:LEFT)
    #   #@cell = 1
    #   self.y -= Tomi_BOSS::SHIP_SPEED if self.y > height / 2
    # end
    # if Input.press?(:DOWN) #&& !Input.press?(:LEFT)
    #   #@cell = 1
    #   self.y += Tomi_BOSS::SHIP_SPEED if self.y < Graphics.height - height / 4
    # end

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
    self.y -= Tomi_BOSS::LAZOR_SPEED
    case @dir
      when 1
        self.x -= Tomi_BOSS::LAZOR_SPEED.to_f / 4
      when 2
        self.x += Tomi_BOSS::LAZOR_SPEED.to_f / 4 + 1
      when 3
        self.x -= Tomi_BOSS::LAZOR_SPEED
      when 4
        self.x += Tomi_BOSS::LAZOR_SPEED
    end
  end
end # Sprite_Lazor < Sprite


class Sprite_ELazor < Sprite
  attr_reader :damage

  def initialize(viewport,x,y, damage = Tomi_BOSS::LAZOR_DAMAGE)
    super(viewport)
    self.x = x
    self.y = y
    @damage = damage
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
    self.y += Tomi_BOSS::ELAZOR_SPEED
  end
end # Sprite_ELazor < Sprite

# Sprite lazor for boss
class Sprite_BLazor < Sprite
  attr_reader :damage

  def initialize(viewport,x,y, type = 0,dir = 0, damage = Tomi_BOSS::LAZOR_DAMAGE)
    super(viewport)
    self.x = x
    self.y = y
    @type = type
    @damage = damage
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
        self.bitmap = Cache.space("boss_lazor0")
      when 1
        self.bitmap = Cache.space("boss_lazor1")
    end
    self.ox = bitmap.width / 2
    self.oy = bitmap.height / 2
  end

  def update_position
    self.y += Tomi_BOSS::BOSS_LAZOR_SPEED
    case @dir
      when 1
        self.x -= Tomi_BOSS::BOSS_LAZOR_SPEED.to_f / 4
      when 2
        self.x += Tomi_BOSS::BOSS_LAZOR_SPEED.to_f / 4 + 1
      when 3
        self.x -= Tomi_BOSS::BOSS_LAZOR_SPEED
      when 4
        self.x += Tomi_BOSS::BOSS_LAZOR_SPEED
    end
  end
end # Sprite_BLazor < Sprite

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
    @move_v = true # true is DOWN, false is UP
    @speed = rand(2) + 1
    @ticker = 0
    @ticker_v = 0

    @ticker_down = 0
    @ticker_up = 0

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

    if @ticker <= 0
      @move = self.x < Graphics.width / 2 ? true : false
      @ticker = rand(90)
    end


    ## movimiento vertical BOSS

    #   llega abajo,
    # luego sube un rato
    # luego baja un rato

    case @move_v
      when true  # Down
        self.y += 1 * (@ticker_v * 0.06) if self.y <= Graphics.height * Tomi_BOSS::BOSS_MAX_Y
      when false # Up
        self.y -= 1 * (@ticker_v * 0.06) if self.y > Graphics.height * Tomi_BOSS::BOSS_MIN_Y
    end

    @ticker_v -= 1
    if @ticker_v <= 0
      @move_v = self.y >= Graphics.height * Tomi_BOSS::BOSS_MAX_Y * 0.98 ? false : true
      @ticker_v = rand(90)
    end

    # case @move_v
    #   when true  # Down
    #     self.y += 1 * (@ticker_v * 0.06) if self.y <= Graphics.height * Tomi_BOSS::BOSS_MAX_Y
    #   when false # Up
    #     self.y -= 1 * (@ticker_v * 0.06) if self.y > Graphics.height * Tomi_BOSS::BOSS_MIN_Y
    # end
    #
    # @ticker_v -= 1
    # if @ticker_v <= 0
    #   # @move_v = self.y >= Graphics.height * Tomi_BOSS::BOSS_MAX_Y * 0.98 ? false : true
    #   @ticker_v = rand(90)
    # end
    #
    # #  el boss esta ABAJO, se queda un rato y despues sube
    # if self.y >= Graphics.height * Tomi_BOSS::BOSS_MAX_Y * 0.95
    #   @ticker_down -= 1
    # end
    #
    # if @ticker_down <= 0
    #   @move_v = false #go up
    #   @ticker_down = rand(Tomi_BOSS::TIME_BOSS_DOWN) #tiempo que el boss estara abajo la proxima
    # end
    #
    # #  el boss esta arriba, se queda un rato y despues BAJA
    # if self.y < Graphics.height * Tomi_BOSS::BOSS_MIN_Y * 0.95
    #   @ticker_up -= 1
    # end
    #
    # if @ticker_up <= 0
    #   @move_v = true  #go down
    #   @ticker_up = rand(Tomi_BOSS::TIME_BOSS_UP) #tiempo que el boss estara arriba la proxima
    # end

  end

  def setup_enemy
    self.bitmap = Cache.space(Tomi_BOSS::NAVE_ENEMIGO  + @type.to_s)
    self.ox = bitmap.width / 2
    self.oy = bitmap.height / 2

    case @type
      when 0
        @hp = Tomi_BOSS::LEVEL1_HP
      when 1
        @hp = Tomi_BOSS::LEVEL2_HP
      when 2
        @hp = Tomi_BOSS::LEVEL3_HP
        @speed = 1
      when 3
        @hp = Tomi_BOSS::LEVEL4_HP
        @speed = 1
      else # BOSS type case...
        @hp = Tomi_BOSS::BOSS_HP
        @speed = Tomi_BOSS::BOSS_SPEED
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

  def refresh(shields = Tomi_BOSS::PLAYER_SHIELDS.to_f,bonus_shields = 0)
    contents.clear
    draw_score("Score: ", score, 4, 0, contents.width - 8, 2)
    draw_score("MaxScore: ", high_score, -(Graphics.width / 2) + 70, 0, contents.width - 8, 2)
    draw_shields(shields, 4, 0)
    draw_bonus_shields(bonus_shields)
  end

  def draw_shields(shields, x, y, width = Graphics.width / 4)
    draw_gauge(x, y, width, shields / Tomi_BOSS::PLAYER_SHIELDS.to_f, text_color(1),
               text_color(4))
  end

  def draw_bonus_shields(x,width = Graphics.width / 4)
    w = width * x / Tomi_BOSS::PLAYER_SHIELDS.to_f
    rect = Rect.new(4, 0, w, 12)
    contents.fill_rect(rect, text_color(1))
  end

  def score
    $game_variables[Tomi_BOSS::SCORE_VAR]
  end
  def high_score
    $game_variables[Tomi_BOSS::HIGH_SCORE_VAR]
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


## 1) para modificar el fondo hacer desde el juego: Tomi_BOSS::FONDO = "nombreNuevoFondo"
## 2) para modificar la nave del jugador: Tomi_BOSS::NAVE_PLAYER = "nueva_nave_superpower"
## 3) para modificar el pack de naves enemigas: Tomi_BOSS::NAVE_ENEMIGO = "monster_op"
## El nombre de NAVE_ENEMIGO que usemos debe estar tener 3 imagenes, cuyo nombre de archivo debe
## estar terminado c/u en -"0.png", -"1.png" y -"2.png".
##Por ejemplo si mi nombre es "monster" , debo tener: "monster0.png", "monster1.png", etc
## 4) Cambiar Musica: Tomi_BOSS::BGM = ["Town4", 100, 100]
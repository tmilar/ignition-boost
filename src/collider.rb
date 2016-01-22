
class Collider
  attr_accessor :enemies
  attr_accessor :pups
  attr_accessor :player
  attr_accessor :lazors
  attr_accessor :elazors

  def initialize
    @enemies = []
    @pups = []
    @player = {}
    @plazors = []
    @elazors = []
  end
  # check colissions:

  # enemies ->  player, plazors
  # elazors -> player, pups (optional)
  # pups -> player, elazors, (opt) plazors (opt)

  def update
    check_enemies
    check_elazors
  end

  def check_elazors
    @elazors.each { |elazor|
      # -> @player
      if collides?(elazor, @player)
        elazor.player_hit(@player)
        @player.elazor_hit(elazor)
        # TODO delete on collision...
      end
    }
  end

  def check_enemies
    # check enemies
    @enemies.each { |enemy|
      # ->  player
      if collides?(enemy, @player)
        enemy.player_collision(@player)
        @player.enemy_collision(enemy)
      end

      # -> plazors
      @plazors.each { |plazor|
        if collides?(enemy, plazor)
          enemy.plazor_hit(plazor)
          plazor.enemy_hit
        end
      }
    }
  end

end

class Collider

  # check colissions:

  # enemies ->  player, plazors
  # elazors -> player, pups (optional)
  # pups -> player, elazors, (opt) plazors (opt)


  # Check elazor with player
  def self.check_elazor(elazor, player)
    if collides?(elazor, player)
      player.elazor_hit(elazor)
      elazor.player_hit
    end
  end

  def self.check_enemy(enemy, plazors, player)
    if collides?(enemy, player)
      Logger.trace("Collided #{enemy}, #{enemy.stats} WITH #{player}, #{player.stats}")
      enemy.player_collision(player)
      player.enemy_collision(enemy)
    end

    plazors.each {
      |plazor|
      if collides?(plazor, enemy)
        Logger.trace("Collided #{plazor}, #{plazor.stats} WITH #{enemy}, #{enemy.stats}")
        enemy.plazor_hit(plazor)
        plazor.enemy_hit
      end
    }
  end


  def self.collides?(obj1, obj2)
    # Logger.trace("Rect1: #{obj1.rectangle}, Rect2: #{obj2.rectangle}, collide? #{obj1.rectangle.collide_rect?(obj2.rectangle)}")
    return obj1.rectangle.collide_rect?(obj2.rectangle)
  end

end
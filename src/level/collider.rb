class Collider

  # check colissions:

  # enemies ->  player, plazors
  # elazors -> player, pups (optional)
  # pups -> player, elazors, (opt : plazors (opt TODO) ... pup.collision(lazor, true) if pup.destructible? )


  # Check elazor with player ship
  def self.check_lazor(lazor, ship)
    if collides?(lazor, ship)
      Logger.trace("Collided #{lazor}, #{lazor.stats} WITH #{ship}, #{ship.stats}")
      ship.lazor_hit(lazor)
      lazor.ship_hit(ship)
    end
  end

  # Check powerup with ship (mainly player)
  def self.check_pup(pup, ship)
    if collides?(pup, ship)
      Logger.trace("Collided #{pup}, #{pup.name} WITH #{ship}, #{ship.stats}")
      ship.pup_hit(pup)
      pup.collision(ship)
    end
  end

  # Check enemy ship with player ship
  def self.check_enemy_player(enemy, player)
    if collides?(enemy, player)
      Logger.trace("Collided #{enemy}, #{enemy.stats} WITH #{player}, #{player.stats}")
      enemy.ship_collision(player)
      player.ship_collision(enemy)
    end
  end

  # Check enemy ship with player lazors
  def self.check_enemy_plazors(enemy, plazors)
    plazors.each {
        |plazor|
      self.check_lazor(plazor, enemy)
    }
  end


  def self.collides?(obj1, obj2)
    # Logger.trace("Rect1: #{obj1.rectangle}, Rect2: #{obj2.rectangle}, collide? #{obj1.rectangle.collide_rect?(obj2.rectangle)}")
    return false if obj1.disposed? || obj2.disposed?
    return obj1.rectangle.collide_rect?(obj2.rectangle)
  end

end
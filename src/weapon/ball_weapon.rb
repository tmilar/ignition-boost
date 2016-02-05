class BallWeapon < Weapon

  ANGLE_BETWEEN_BALLS = 0.5

  def emit_lazors(config = {})
    lazors = []

    Logger.trace("#{self} preparing lazors for lvl #{@level}, conf #{config}")
    level = @level - 1 ## Use zero-indexed levels for calculations
    bullet_conf = config.deep_clone

    base_dirx = bullet_conf[:direction].x

    (0.. level).each { |i|

      pos = i - ( level/2.to_f )

      offset_dirx = pos * ANGLE_BETWEEN_BALLS

      bullet_conf[:direction] = bullet_conf[:direction].clone
      bullet_conf[:direction].x = base_dirx + offset_dirx

      Logger.trace("#{self} Shooting bullet #{i}, dir_x: #{bullet_conf[:direction]}, offsetx #{offset_dirx}, pos: #{pos}")

      lazors << Bullet.new(bullet_conf)
    }

    lazors

  end

end
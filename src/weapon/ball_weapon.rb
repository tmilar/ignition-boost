class BallWeapon < Weapon

  ANGLE_BETWEEN_BALLS = 0.5

  def emit_lazors(config = {})
    lazors = []

    # Logger.trace("#{self} preparing lazors for lvl #{@level}, conf #{config}")
    bullet_conf = config.deep_clone

    base_dirx = bullet_conf[:direction].x

    @level.times { |i|

      pos = i - (@level - 1).fdiv(2)

      offset_dirx = pos * ANGLE_BETWEEN_BALLS

      bullet_conf[:direction] = bullet_conf[:direction].clone
      bullet_conf[:direction].x = base_dirx + offset_dirx

      # Logger.trace("#{self} Shooting bullet #{i}, dir_x: #{bullet_conf[:direction]}, offsetx #{offset_dirx}, pos: #{pos}")

      lazors << Bullet.new(bullet_conf)
    }

    lazors

  end

end
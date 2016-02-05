class LazorWeapon < Weapon


  SPACE_BETWEEN = 12

  SPACE_FACTOR = 2 ## proporcion a la distancia al centro, para calcular el Ym

  def emit_lazors(config={})
    lazors = []

    Logger.trace("#{self} preparing lazors for lvl #{@level}, conf #{config}")
    level = @level - 1 ## Use zero-indexed levels for calculations
    bullet_conf = config.deep_clone

    base_x = bullet_conf[:position].x

    (0.. level).each { |i|

      pos = i - ( level/2.to_f )

      offset_x = pos*(SPACE_BETWEEN )

      bullet_conf[:position].x = base_x + offset_x

      Logger.trace("#{self} Shooting bullet #{i}, x: #{bullet_conf[:position].x}, offsetx #{offset_x}")
      lazors << Bullet.new(bullet_conf)
    }

    # (0.. level).each { |i|
    #
    #   center = level/2.to_f
    #   # pos = i - center
    #   space = space_between(i, center)
    #
    #   # offset_x = pos*(SPACE_BETWEEN )
    #   offset_x = space
    #   bullet_conf[:position].x = base_x + offset_x #+ (offset_x**3)/3.to_f
    #
    #   Logger.trace("Shooting bullet i:#{i}, x: #{bullet_conf[:position].x}, offsetx #{offset_x}, centre: #{center}")
    #   lazors << Bullet.new(bullet_conf)
    # }

    lazors
  end

  # i : point in (0..@level-1)
  # ce : dist_centre
  # ym : max_dist for furthest points
  def space_between(i, ce, ym=nil)

    ym = SPACE_FACTOR*ce if ym.nil?
    return 0.0 if ce <= 0.01

    (ym/ce**2.to_f) * i**2 + 2*(ym/ce.to_f)*i + ym
  end
end
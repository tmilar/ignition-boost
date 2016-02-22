class Collider

  include Subject

  # check colissions:

  # enemy ->  player, plazors
  # elazor -> player (opt:  pups TODO)
  # pup -> player (opt : elazors,  plazors [ TODO ... pup.collision(lazor, true) if pup.destructible? ])


  def initialize(game_container)
    @game_container = game_container

    @collisions = {
        # origin type => targets types
        :enemy_moved => [ :plazors, :player ] ,
        :elazor_moved => [ :player ],
        :powerup_moved => [ :player ]
    }
  end

  def notified(msg, collider)
    # Logger.trace("Collider received '#{msg}' notification! collider is#{collider}... #{"but is not considered..." unless @collisions.key?(msg.to_sym)}")
    return unless @collisions.key?(msg.to_sym)
    coll_target_symbols = @collisions[msg.to_sym]

    # Logger.trace("Collider received '#{msg}' notification! Checking #{collider} with #{coll_target_symbols}...")

    check_collisions(collider, coll_target_symbols)
  end

  def check_collisions(collider, coll_target_symbols)
    return Logger.error("No coll target symbols received/configured for #{collider}!") if coll_target_symbols.nil_empty?

    targets = get_collision_targets(coll_target_symbols)
    return Logger.trace("For #{collider}, no collision targets available in #{@game_container} of kind '#{coll_target_symbols}'") if targets.nil_empty?

    check_collider_targets(collider, targets)
  end


  def get_collision_targets(coll_target_symbols)

    targets = []

    coll_target_symbols.each { |coll_target_sym|
      unless @game_container.respond_to?(coll_target_sym)
        Logger.error("#{@game_container} can't get targets #{coll_target_sym}!")
        return
      end
      # get container actual target game entities
      targets.push(*@game_container.method(coll_target_sym).call)
    }

    targets
  end

  def check_collider_targets(collider, targets)
    # Logger.trace("Checking collider #{collider} with targets #{targets}")
    targets.each { |target|
      check_pair(collider, target)
    }
  end

  def check_pair(game_obj1, game_obj2)
    # Logger.trace("checking pair #{game_obj1}, #{game_obj2}...")
    return unless Collider.collides?(game_obj1, game_obj2)
    Logger.trace("Collided #{game_obj1}, #{game_obj1.stats if game_obj1.respond_to?(:stats)} WITH #{game_obj2}, #{game_obj2.stats if game_obj2.respond_to?(:stats)}")

    game_obj1.collide_with(game_obj2)
    game_obj2.collide_with(game_obj1)
  end

  def self.collides?(obj1, obj2)
    # Logger.trace("Rect1: #{obj1.rectangle}, Rect2: #{obj2.rectangle}, collide? #{(obj1.collision_rect || obj1.rectangle).collide_rect?( obj2.collision_rect || obj2.rectangle )}")
    return false if obj1.disposed? || obj2.disposed?
    return (obj1.collision_rect || obj1.rectangle).collide_rect?( obj2.collision_rect || obj2.rectangle )
  end

  def to_s
    "<#{self.class}>"
  end

end
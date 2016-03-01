# dependencies:
## Graphics to see the boundaries of the screen
## Sprite to load ship image
class Ship < GameEntity

  include Powerupeable

  DEFAULT_WEAPON = {
      name: "lazor1",         # weapon name (also lazor image '.png' name)
      type: "lazor",          # weapon type // por ahora no hace nada //
      stats: {
          damage: 1,              # bullet damage
          speed: 5,               # bullet speed
          cooldown: 5,            # time to wait before shooting again
      },
      SE: ["Attack2",80,150], # sound when shooting
      level: 1                # starting weapon level (optional, default 1)
  }

  DEFAULTS = {
      :name => "DEFAULT_SHIP",
      :stats => {
          :power => 1,
          :speed => 1,
          :hp => 5,
          :collide_damage => 1,
          :collide_resistance => 0,
          :shoot_freq => 1,             ## TODO por ahora esto remplazara la @difficulty
          :nuke_power => 99            # Damage caused by nuke
      },
      :collision_rect => {      # Define ship collision rectangle, relative to ship size.
          :x => [0.0, 1.0],
          :y => [0.0, 1.0]
      },
      :weapon => DEFAULT_WEAPON,
      :explosion => {
          bitmap: "explode",
          zoom: 1,
          time: 10,
          :DSE => ["Fire1",90,150],     # SE for death | "SE_Name",volume,pitch
      },
      :PUSE => ["Item1",80,150]   # "SE_Name",volume,pitch - SE when get powerup
  }

  # Delegate accessors to internal hashes
  attr_readers_delegate :@config, :name, :explosion, :limits
  attr_accessors_delegate :@stats, :power, :speed, :hp, :mhp, :collide_damage, :collide_resistance, :shoot_freq, :nuke_power

  attr_accessor :stats
  attr_reader :weapon

  #------------------------------------------------------------------------------#
  #  INITIALIZATION METHODS
  #------------------------------------------------------------------------------#
  def initialize(config = {})
    self.class.count += 1
    name_id = config[:name] + ":#{self.class.count}"

    #config setup
    Logger.start("ship#'#{name_id}'", config, DEFAULTS)
    @config = DEFAULTS.deep_clone.deep_merge(config).deep_clone
    @config[:name] = name_id
    stats_init
    weapon_init(@config[:weapon])

    super(@config)

    Logger.debug("Ship #{self} config is: #{@config}")

  end

  def gameobj_id
    @config[:name].split(':')[1].to_i
  end


  def weapon_init(weapon_config)
    weapon_config[:shooter] = self.type
    Logger.trace("About to create a new weapon. Config -> #{weapon_config}")
    @weapon = Weapon.create(weapon_config)
    Logger.trace("#{self} has created a weapon! #{@weapon}.")
  end



  def sprite_init
    Logger.trace("#{self} initializing sprite with config... #{@config}")
    ret_sprite = Sprite.create({
                                bitmap: @config[:name],
                                cells: @config[:cells],
                                limits: @config[:limits],
                                init_pos: self.position_init,
                                collision_rect: @config[:collision_rect],
                            })
    Logger.trace("initialized sprite: #{ret_sprite}! #{self.class} Ancestors: #{self.class.ancestors}, methods: #{(self.methods - Object.methods).sort}")
    ret_sprite
  end

  # Place initial sprite position
  def position_init
    raise 'position_init method NotImplemented! Please implement in the correct Ship implementation.'
  end

  # Get weapon position (relative to ship)
  def weapon_pos
    raise 'weapon_pos method NotImplemented! Must implement in Ship implementation.'
  end

  def stats_init
    @stats = @config[:stats].deep_clone
    @stats[:mhp] = @stats[:hp]
    Logger.trace("inited ship #{type} with stats: #{@stats}")
  end

  def level_observe(level)
    add_observer(level)
    add_observer(level.collider)
  end

  ## @Override | add observer to {self, @weapon, @movement}
  def add_observer(observer)
    super(observer)
    self.weapon.add_observer(observer)  unless self.weapon.nil?
    self.movement.add_observer(observer)
  end

  #------------------------------------------------------------------------------#
  #  SHIP BEHAVIOR METHODS
  #------------------------------------------------------------------------------#
  def update
    weapon_update
    super
  end

  def weapon_update
    return if disposed?
    @weapon.update
    @weapon.shoot(weapon_pos) if self.check_shoot
  end

  def collide_with(other_game_obj)
    case other_game_obj
      when Ship then ship_collision(other_game_obj)
      when Bullet then lazor_hit(other_game_obj)
      when PowerUp then pup_hit(other_game_obj)
      else raise "Attempted to collide #{self} with an object of unsupported type: #{other_game_obj} !"
    end
  end

  def ship_collision(ship)
    Logger.debug("#{self} collided with #{ship}, coll dmg #{ship.stats[:collide_damage]}, coll resist #{@stats[:collide_resistance]}")
    damage = ship.stats[:collide_damage] - (@stats[:collide_resistance] || 0)
    self.flash(Color.new(255,255,155),20)
    self.hp -= damage if damage > 0
  end

  def lazor_hit(lazor)
    Logger.debug("#{self} collided with #{lazor}, coll dmg #{lazor.stats[:damage]}")
    self.flash(Color.new(255,155,155),20)
    self.hp -= lazor.stats[:damage]
  end

  def pup_hit(pup)
    Logger.debug("#{self} hitted a powerup! #{pup}")
    self.flash(Color.new(155,255,155),20)
    notify_observers('powerup_grabbed', pup)
    Sound.se(@config[:PUSE])
  end

  def destroy
    notify_observers("#{type}_destroyed", {ship: self})
    Logger.debug("#{self} destroyed in #{self.position}")
    self.explode
    self.dispose(false)
  end

  def explode
    explosion_config = @config[:explosion].deep_clone
    explosion_config[:position] = self.rectangle.center
    Logger.debug("#{self} Starting explosion, config: #{explosion_config}")
    notify_observers('ship_exploded', explosion_config) ## { position: self.position, explosion: @config[:explosion]})
  end

  #------------------------------------------------------------------------------#
  #  SHIP PROPERTIES  || OVERRIDE GETTERS & SETTERS
  #------------------------------------------------------------------------------#
  def type
    self.class.to_s.downcase
  end

  def hp=(new_hp)
    return if disposed?
    @stats[:hp] = [new_hp, @stats[:mhp]].min
    Logger.debug("#{self} hp changed, now is #{@stats[:hp]}") # enemy hp changed ||| player hp changed
    notify_observers("#{type}_hp", self) # notify 'enemy_hp' or 'player_hp'
    self.destroy if @stats[:hp] <= 0
  end

  def stats=(stats)
    stats.each { |stat, value|
      self.property_set(stat, value)
    }
  end

  def weapon=(new_weapon)
    new_weapon_config = new_weapon.deep_clone #deep clone weapon config to prevent overriding defaults

    if new_weapon_config.key?(:name) && (@weapon.nil? || (new_weapon_config[:name] != @weapon.name))
      new_weapon_config[:level] = @weapon.level # keep current weapon level
      Logger.trace("Changed to New weapon! #{new_weapon_config} ")
      weapon_init(new_weapon_config)
      notify_observers("#{type}_weapon_changed", @weapon)
    else
      Logger.trace("#{new_weapon_config} is the same weapon as current.")
      @weapon.level += 1
    end
  end

  def difficulty
    @elapsed_time
  end

  ## On RESET or NUKE, modify elapsed_time by [factor] to go back or forward in difficulty time.
  def difficulty=(elapsed_time)
    Logger.debug("#{self} difficulty has been reduced by #{100*elapsed_time/@elapsed_time}%! (shooting_freq been modified)")
    @elapsed_time = elapsed_time
  end

  def to_s
    "<#{self.class}> '#{self.name}'"
  end

  def self.count
    @@count
  end

  def self.count=(val)
    @@count = val
  end

end
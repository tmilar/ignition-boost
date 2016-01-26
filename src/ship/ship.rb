# dependencies:
## Graphics to see the boundaries of the screen
## Sprite to load ship image
class Ship
  include Subject
  extend Forwardable

  def_delegators :@sprite, :x, :y, :ox, :oy, :zoom_x, :zoom_y, :height, :width, :bitmap
  def_delegators :@sprite, :position, :position=, :rectangle, :rectangle=
  def_delegators :@sprite, :dispose, :disposed?, :flash

  attr_accessor :sprite
  attr_accessor :stats
  attr_reader :weapon

  DEFAULT_WEAPON = {
      name: "lazor1",         # weapon name (also lazor image '.png' name)
      type: "lazor",          # weapon type // por ahora no hace nada //
      stats: {
          damage: 1,              # bullet damage
          speed: 5,               # bullet speed
      },
      cooldown: 5,            # time to wait before shooting again
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
      :weapon => DEFAULT_WEAPON,
      :position_limits => {         # Percentage limits ship can move, mostly for bosses
          x: [0.0, 1.0],
          y: [0.0, 1.0]
      },
      :explosion => {
          bitmap: "explode",
          zoom: 1,
          time: 10,
          :DSE => ["Fire1",90,150],     # SE for death | "SE_Name",volume,pitch
      },
  }

  # Delegate accessors to internal hashes
  attr_readers_delegate :@config, :name, :position_limits, :explosion
  attr_accessors_delegate :@stats, :power, :speed, :hp, :mhp, :collide_damage, :collide_resistance, :shoot_freq, :nuke_power

  #------------------------------------------------------------------------------#
  #  INITIALIZATION METHODS
  #------------------------------------------------------------------------------#
  def initialize(config = {})
    super(config)
    #config setup
    Logger.start("ship#'#{config[:name]}'", config, DEFAULTS)
    @config = DEFAULTS.merge(config)
    Logger.debug("Ship #{self} config is: #{@config}")
    stats_init
    sprite_init
    position_init
    weapon_init(@config[:weapon])
  end


  def weapon_init(weapon_config)
    weapon_config[:shooter] = self.ship_type
    Logger.trace("About to create a new weapon. Config -> #{weapon_config}")
    @weapon = Weapon.new(weapon_config)
    Logger.trace("#{self.introduce} has created a weapon! #{@weapon}.")
  end



  def sprite_init
    @sprite = Sprite.create({
                                bitmap: @config[:name],
                                x: Graphics.width / 2,
                                y: 0 ##Graphics.height - height / 4
                            })
  end

  # Place initial sprite position
  def position_init
    raise "position_init method NotImplemented! Please implement in the correct Ship implementation."
  end

  # Get weapon position (relative to ship)
  def weapon_pos
    raise "weapon_pos method NotImplemented! Must implement in Ship implementation."
  end

  def stats_init
    @stats = @config[:stats].deep_clone
    @stats[:mhp] = @stats[:hp]
    Logger.trace("inited ship #{ship_type} with stats: #{@stats}")
  end

  def level_observe(observer)
    Logger.warn("Can't observe this ship @weapon because is nil!") if @weapon.nil?
    @weapon.add_observer(observer) unless @weapon.nil?
    self.add_observer(observer)
  end
  #------------------------------------------------------------------------------#
  #  SHIP BEHAVIOR METHODS
  #------------------------------------------------------------------------------#
  def update
    sprite_update
    weapon_update
  end

  def sprite_update
    @sprite.update
  end

  def weapon_update
    @weapon.update
    @weapon.shoot(weapon_pos) if self.check_shoot
  end

  def ship_collision(ship)
    Logger.debug("#{self} collided with #{ship}, coll dmg #{ship.stats[:collide_damage]}, coll resist #{@stats[:collide_resistance]}")
    self.hp -= ship.stats[:collide_damage] - (@stats[:collide_resistance] || 0)
  end

  def lazor_hit(lazor)
    Logger.debug("#{self} collided with #{lazor}, coll dmg #{lazor.stats[:damage]}")
    self.flash(Color.new(255,155,155),20)
    self.hp -= lazor.stats[:damage]
  end

  def destroy
    notify_observers("#{ship_type}_destroyed", { ship: self, explosion: @config[:explosion] })
    Logger.debug("#{self} is destroyed! Starting explosion in #{self.position}, config: #{@config[:explosion]}")
    self.dispose
  end

  def apply_pup(pup_effect)
    Logger.debug("About to apply effect #{pup_effect} on #{self}...")
    pup_effect.each { |stat, effect|
      self.property_set(stat, effect)
    }
  end

  #------------------------------------------------------------------------------#
  #  SHIP PROPERTIES  || GETTERS & SETTERS
  #------------------------------------------------------------------------------#
  def ship_type
    self.class.to_s.uncapitalize
  end

  def hp=(new_hp)
    return if disposed?
    @stats[:hp] = new_hp
    Logger.debug("#{ship_type} hp changed, now is #{@stats[:hp]}") # enemy hp changed ||| player hp changed
    notify_observers("#{ship_type}_hp", self) # notify 'enemy_hp' or 'player_hp'
    self.destroy if @stats[:hp] <= 0
  end

  def stats=(stats)
    stats.each { |stat, value|
      self.property_set(stat, value)
    }
  end

  def weapon=(new_weapon)
    if new_weapon.key?(:name) && new_weapon[:name] != @weapon[:name]
      Logger.trace("New weapon! #{new_weapon} ")
      @weapon = Weapon.new(new_weapon)
      ### TODO SE for weapon change... and maybe a "reload" sound?
    else
      Logger.trace("#{new_weapon} is the same weapon as current.")
      @weapon.level += 1
      ## TODO - DECIDE - set other *weapon* property pups..?
    end
  end

  def property_set(stat, value)
    getter = stat
    setter = "#{stat}="

    unless self.respond_to?(setter) && self.respond_to?(getter)
      Logger.error("Trying to set property #{stat}, #{value} on #{self.introduce}, but doesn't respond to #{setter} or #{getter}!")
      return
    end

    if value.is_a?(Integer)
      Logger.trace("Calling ':#{getter}+=' #{value} on #{self}")
      current = self.send(getter)
      new_val = current + value
      self.send(setter, new_val)
    elsif value.is_a?(Float)
      Logger.trace("Calling ':#{getter}*=' #{value} on #{self}")
      current = self.send(getter)
      new_val = current * value
      self.send(setter, new_val)
    elsif value.kind_of?(Hash)
      Logger.trace("Calling ':#{getter}=' #{value} on #{self}")
      self.send(setter, value)
    else
      Logger.error("Unexpected type of value #{value} inputted for #{stat}, needs to be Float or Integer!")
    end
  end

  def to_s
    "<#{self.class}> #{@config}, #{self.stats}"
  end

  def introduce
    "<#{self.class}> '#{self.name}'"
  end
end
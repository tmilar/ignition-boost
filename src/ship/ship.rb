# dependencies:
## Graphics to see the boundaries of the screen
## Sprite to load ship image
class Ship
  extend Forwardable
  include Subject

  def_delegators :@sprite, :x, :y, :ox, :oy, :zoom_x, :zoom_y, :height, :width
  def_delegators :@sprite, :position, :position=, :rectangle

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
      :DSE => ["Fire1",90,150],     # SE for death | "SE_Name",volume,pitch
  }

  def initialize(config = {})
    super(config)
    #config setup
    Logger.start("ship#'#{config[:name]}'", config, DEFAULTS)
    @config = DEFAULTS.merge(config)
    stats_init
    sprite_init
    position_init
    weapon_init
  end

  def weapon_init
    @config[:weapon][:shooter] = self.ship_type
    Logger.trace("About to create new weapon. Config -> #{@config}")
    @weapon = Weapon.new(@config)
    Logger.trace("Player has created its weapon! #{@weapon} #{"and is accessible! " if self.respond_to?(:weapon)}")
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
  end

  def name
    @config[:name]
  end

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

  def dispose
    @sprite.dispose
    notify_observers("#{ship_type}_disposed", self)
  end

  def ship_type
    self.class.uncapitalize
  end

  def level_observe(observer)
    Logger.warn("Can't observe this ship @weapon because is nil!") if @weapon.nil?
    @weapon.add_observer(observer) unless @weapon.nil?
    self.add_observer(observer)
  end

  def disposed?
    @sprite.disposed?
  end

  def hp
    @stats[:hp]
  end

  def hp=(new_hp)
    @stats[:hp] = new_hp
    notify_observers("#{ship_type}_hit", self)
  end

end
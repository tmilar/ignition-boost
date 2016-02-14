class Item
  item = {
      hold: true,
      name: "nuke",
      bitmap: "item_nuke",
      SE: ["Explosion3",120,100],
      target: "enemies",
      stats: {
          hp: -30,  ## enough to kill most of them
      },
  }

  DEFAULTS = {
      hold: false,
      name: "DEFAULT_NAME",
      bitmap: "NO_IMAGE",
      SE: nil,
      target: nil
  }

  CONFIG_KEYS = [:hold, :name, :target, :bitmap, :SE]

  extend Forwardable

  def_delegators :@sprite, :dispose, :disposed?
  attr_readers_delegate :@config, :target, :name, :targets

  attr_accessor :sprite, :se

  def initialize(config={})
    Logger.start('item', config, DEFAULTS)
    @config = DEFAULTS.merge(config).deep_clone

    init_sprite
  end

  def init_sprite
    return unless @config[:hold]

    @sprite = Sprite.create({
                                name: @config[:name],
                                bitmap: @config[:bitmap],
                                x: Graphics.width / 4 + 40,
                                y: 15,
                                z: 100
                            })
  end

  def update
    return unless @config[:hold]
    @sprite.update
  end

  def se
    @config[:SE] if @config[:SE]
  end

  def targets
    [@config[:targets] || @config[:target]].flatten
  end


  def effect
    effect = @config.except(CONFIG_KEYS).deep_clone
    Logger.trace("#{self} been asked for effect... which is... #{effect}")
    @sprite.dispose ## when asked for effect, remove sprite image
    effect
  end

  def to_s
    "<#{self.class}> '#{self.name}'"
  end
end
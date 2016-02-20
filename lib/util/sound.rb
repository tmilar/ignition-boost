# Sound interface - mediator for RGSS3
module Sound
  @@last = ''

  def self.bgm(bgm)
    # name = bgm[0]
    new_bgm = RPG::BGM.new(bgm[0], bgm[1], bgm[2])
    last = RPG::BGM.last

    Logger.debug("last bgm> #{last.name}. #{"But is the same as actual, so nothing changed." if last.name == new_bgm.name}")
    return if last.name == new_bgm.name

    fade(10)
    new_bgm.play
    # @@last = bgm[0]
    Logger.debug("Playing new bgm> #{new_bgm.name}") ##", and bgm as 'last' :  #{@@last}")
  end

  def self.fade(time)
    RPG::BGM.fade(time)
    RPG::ME.fade(time)
    # @@last = nil
  end

  def self.se(se)
    RPG::SE.new(se[0], se[1], se[2]).play
  end

  def self.me(me)
    RPG::ME.new(me[0], me[1], me[2]).play
  end

  def self.stop
    RPG::ME.stop
    RPG::BGM.stop
  end
end
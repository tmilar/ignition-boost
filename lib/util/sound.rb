# Sound interface - mediator for RGSS3
module Sound
  @@last = ''

  def self.bgm(bgm)
    name = bgm[0]
    Logger.debug("last bgm> #{@@last}. #{"But is the same as actual, so nothing changed." if @@last == name}")
    return if @@last == name

    fade(10)
    RPG::BGM.new(bgm[0], bgm[1], bgm[2]).play
    @@last = bgm[0]
    Logger.debug("Playing new bgm> #{name}, and bgm as 'last' :  #{@@last}")
  end

  def self.fade(time)
    RPG::BGM.fade(time)
  end

  def self.se(se)
    RPG::SE.new(se[0], se[1], se[2]).play
  end

  def self.me(me)
    RPG::ME.new(me[0], me[1], me[2]).play
  end
end
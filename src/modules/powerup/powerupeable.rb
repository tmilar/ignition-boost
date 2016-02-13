module Powerupeable

  def apply_pup(pup_effect)
    Logger.debug("About to apply effect #{pup_effect} on #{self}...")
    pup_effect.each { |stat, effect|
      self.property_set(stat, effect)
    }
  end

  def property_set(prop, value)
    getter = prop
    setter = "#{prop}="

    unless self.respond_to?(setter) && self.respond_to?(getter)
      Logger.error("Trying to set property #{prop}, #{value} on #{self}, but doesn't respond to #{setter} or #{getter}!")
      return
    end

    valid_types = [Integer, Float, Hash]
    if valid_types.none? { |type| type === value}
      Logger.error("Unexpected type of value #{value} inputted for #{prop}, needs to be one of: #{valid_types}!")
      return
    end

    current = self.send(getter)

    # calculate new value
    if value.is_a?(Integer)
      value += current
    elsif value.is_a?(Float)
      value *= current
    end

    # call setter for new value
    Logger.trace("Calling ':#{setter}' #{value} on #{self} #{"(previous value was: #{current})" if current}")
    self.send(setter, value)
  end


end
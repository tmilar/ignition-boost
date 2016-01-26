class Hash
  # Returns a hash that includes everything but the given keys.
  #   hash = { a: true, b: false, c: nil}
  #   hash.except(:c) # => { a: true, b: false}
  #   hash # => { a: true, b: false, c: nil}
  #   hash.except([:c, :b]) # => { a: true}
  # This is useful for limiting a set of parameters to everything but a few known toggles:
  #   @person.update(params[:person].except(:admin))
  def except(keys)
    dup.except!(keys)
  end

  # Replaces the hash without the given keys.
  #   hash = { a: true, b: false, c: nil}
  #   hash.except!(:c) # => { a: true, b: false}
  #   hash # => { a: true, b: false }
  #   hash.except([:c, :b]) # => { a: true}
  #   hash # => { a: true }
  def except!(keys)
    if keys.respond_to?(:each)
      # array of keys
      keys.each { |key| delete(key) }
    else
      # only one key
      delete(keys)
    end
    self
  end


  def pick(*values)
    select { |k,v| values.include?(k) }
  end
end

module Cache
  #-----------------------------------------------------------------------------
  # Store image to relative path
  #-----------------------------------------------------------------------------
  def self.space(filename)
    Logger.info("CACHE spacing image: PATH: #{@relative_path}/#{filename}")
    load_bitmap(@relative_path || '', filename)
  end

  def self.relative_path(relative_path)
    @relative_path = relative_path
  end

  #-----------------------------------------------------------------------------
  ### DESTRUCTIVE CACHE ### ----------------------------------------------------
  #-----------------------------------------------------------------------------
  # Getters & Setters
  #-----------------------------------------------------------------------------
  def destructive_cache; @@destructive_cache; end
  def destructive_cache=value; @@destructive_cache = value; end
  @@destructive_cache = Hash.new{|h, k| h[k] = []};

  #-----------------------------------------------------------------------------
  # new_bmp                                                                [NEW]
  #-----------------------------------------------------------------------------
  def self.new_bmp(category, width, height)
    bmp = Bitmap.new(width, height)
    @@destructive_cache[category] << bmp
    bmp
  end

  #-----------------------------------------------------------------------------
  # dispose_bmp                                                            [NEW]
  #-----------------------------------------------------------------------------
  def dispose_bmp(category, bmp)
    return if !@@destructive_cache.has_key(category)
    deleted = @@destructive_cache[category].delete(bmp)
    deleted.dispose if deleted
    return deleted
  end
  #-----------------------------------------------------------------------------
  # dispose                                                                [NEW]
  #-----------------------------------------------------------------------------
  def self.dispose(category)
    return if !@@destructive_cache.has_key?(category)
    @@destructive_cache[category].each { |bmp| bmp.dispose }

    return @@destructive_cache.delete(category)
  end
end
#===============================================================================
# Test Code (outcommented)
#===============================================================================
#~ class Mem_test
#~   def initialize
#~     @bitmap = Cache.new_bmp(:mem_test, 512, 512)
#~     @sprite = Sprite.new
#~     @sprite.bitmap = @bitmap
#~     @sprite.dispose
#~   end
#~ end

#~ 10000.times do |i|
#~   @a = Mem_test.new
#~   @a = nil
#~   Cache.dispose(:mem_test) if i % 500 == 0 # This line prevents the crash.
#~ end


#===============================================================================
# ■ class Point
#===============================================================================
$imported ||= {}
$imported[:nap_point] = 1.04
class Point
  attr_accessor :x
  attr_accessor :y
  EPSILON = 0.00001

  #-----------------------------------------------------------------------------
  # Initialize
  #-----------------------------------------------------------------------------
  def initialize(x=0, y=0)
    @x, @y = x, y
  end
  #===============================================================================
  # Misc
  #===============================================================================
  #-----------------------------------------------------------------------------
  # Rotate Around
  # For: Rotating around an origin specified by the degree.
  #      http://phrogz.net/SVG/rotations.xhtml
  # Returns the new location but does not set it.
  #-----------------------------------------------------------------------------
  def rotate_around(degrees, origin=Point.empty)
    radians = degrees * Math::PI / 180
    x2 = x - origin.x
    y2 = y - origin.y

    cos = Math.cos(radians)
    sin = Math.sin(radians)

    return Point.new(
        x2*cos - y2*sin + origin.x,
        x2*sin + y2*cos + origin.y
    )
  end
  #-----------------------------------------------------------------------------
  # Rotate Around!
  # Same as Rotate but now sets the location to the point.
  #-----------------------------------------------------------------------------
  def rotate_around!(degrees, origin=Point.empty)
    result = rotate_around(degrees, origin)
    @x = result.x
    @y = result.y
    return result
  end
  #-----------------------------------------------------------------------------
  # Point.Empty
  # Returns 0,0 Point
  #-----------------------------------------------------------------------------
  def self.empty # same as Point.new w/o parameters
    Point.new
  end
  #-----------------------------------------------------------------------------
  # Empty
  #-----------------------------------------------------------------------------
  def empty?
    @x == 0 && @y == 0
  end
  #-----------------------------------------------------------------------------
  # Normalize Me
  #-----------------------------------------------------------------------------
  def normalize_me
    distance = Math.sqrt(@x * @x + @y * @y).to_f
    return Point.new(@x / distance, @y / distance)
  end
  #-----------------------------------------------------------------------------
  # Normalize
  #-----------------------------------------------------------------------------
  def self.normalize(point)
    distance = Math.sqrt(point.x * point.x + point.y * point.y).to_f
    return Point.new(point.x / distance, point.y / distance)
  end
  #-----------------------------------------------------------------------------
  # Get Move Dir
  # Returns the movement vector from start to destination
  #-----------------------------------------------------------------------------
  def self.get_move_dir(start, destination)
    if (destination - start == Point.empty) # If-statement is needed because normalizing a zero value results in a NaN value
      return Point.empty
    else
      return Point.normalize(destination - start)
    end
  end
  #===============================================================================
  # Overloading
  #===============================================================================
  def *(value)
    if value.kind_of?(Fixnum) || value.kind_of?(Float)
      return Point.new(@x * value, @y * value)
    elsif value.kind_of?(Point)
      return Point.new(@x * value.x, @y * value.y)
    end
    raise 'Invalid multiplication. Must be typeof Fixnum or Point'
  end

  def +(value)
    if value.kind_of?(Fixnum) || value.kind_of?(Float)
      return Point.new(@x + value, @y + value)
    elsif value.kind_of?(Point)
      return Point.new(@x + value.x, @y + value.y)
    end
    raise 'Invalid add. Must be typeof Fixnum or Point'
  end

  def -(value)
    if value.kind_of?(Fixnum) || value.kind_of?(Float)
      return Point.new(@x - value, @y - value)
    elsif value.kind_of?(Point)
      return Point.new(@x - value.x, @y - value.y)
    end
    raise 'Invalid substraction. Must be typeof Fixnum or Point'
  end

  def /(value)
    if value.kind_of?(Fixnum) || value.kind_of?(Float)
      return Point.new(@x / value, @y / value)
    elsif value.kind_of?(Point)
      return Point.new(@x / value.x, @y / value.y)
    end
    raise 'Invalid divide. Must be typeof Fixnum or Point'
  end

  def ==(value)
    (@x - value.x).abs < EPSILON &&
    (@y - value.y).abs < EPSILON
    # @x == value.x && @y == value.y
  end

  def !=(value)
    !(self == value)
  end

  def [] idx
    idx == 0 ? @x : @y
  end

  def []= idx, value
    idx == 0 ? @x = value : @y = value
  end

  def to_s
    "(X:#{@x}, Y:#{@y})"
  end

  def clone
    Point.new(self.x, self.y)
  end
end # class Point
#===============================================================================
# Sprite
#===============================================================================
class Sprite
  #-----------------------------------------------------------------------------
  # To Point                                                               [NEW]
  #-----------------------------------------------------------------------------
  def to_point
    Point.new(self.x, self.y)
  end
  #-----------------------------------------------------------------------------
  # Rotate Around                                                          [NEW]
  # Note: Sprite locations are in whole numbers so using this method
  #       incrementally may cause rounding problems.
  #-----------------------------------------------------------------------------
  def rotate_around(degrees, origin=Point.empty)
    return self.to_point.rotate_around(degrees, origin)
  end
  #-----------------------------------------------------------------------------
  # Rotate Around!                                                         [NEW]
  # Note: Sprite locations are in whole numbers so using this method
  #       incrementally may cause rounding problems.
  #-----------------------------------------------------------------------------
  def rotate_around!(degrees, origin=Point.empty)
    result = self.to_point.rotate_around(degrees, origin)
    self.x = result.x
    self.y = result.y
    return result
  end
end
#===============================================================================
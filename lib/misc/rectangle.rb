#sb:nap_rect [developer]
#==============================================================================
=begin
Rectangle class
Version 1.03
By Napoleon

About:
A Rectangle class with an x, y, width, height

Instructions:
- Place below "▼ Materials" but above "▼ Main Process".
- Place below the Point class

Requires:
- RPG Maker VX Ace
- Point class version 1.01 or later

Terms of Use:
- Attribution 3.0 Unported (CC BY 3.0)
  http://creativecommons.org/licenses/by/3.0/
- Attribution is not required. This overrules what's stated in the above
  license.

Version History:
1.03 (12 September 2014)
  - Added new method: rand_point
1.02 (26-05-2013)
  - Fixed some bugs
  - Added the clone() method
1.01 (21-5-2013)
  - Improved the $imported requirement check
  - modified the contains_point()
1.00 (18-5-2013)
  - First Release
=end
#===============================================================================
# ■ Dependency Check(s)
#===============================================================================
module Nap
  $imported ||= {}
  def self.dependency_check
    $imported[:nap_rectangle] = 1.03
    if !$imported[:nap_point]
      raise('The Recangle class requires the Point class.')
    else
      raise("The Recangle class requires the Point class version 1.01 or later. The current version is: #{$imported[:nap_point]}.") if $imported[:nap_point] < 1.01
    end
  end # dependecy_check
  dependency_check
end # module Nap
#===============================================================================
# ■ class Rectangle
#===============================================================================
class Rectangle
  attr_accessor :x
  attr_accessor :y
  attr_accessor :width
  attr_accessor :height

  def self.empty # same as Rectangle.new w/o parameters
    Rectangle.new
  end

  def initialize(x=0, y=0, width=0, height=0)
    @x, @y, @width, @height = x, y, width, height
  end

#===============================================================================
# Basic methods
#=============================================================================== 
  def left
    @x
  end

  def right
    @x + @width
  end

  def top
    @y
  end

  def bottom
    @y + @height
  end

  def topleft
    Point.new(@x,@y)
  end

  def topright
    Point.new(right, @y)
  end

  def bottomright
    Point.new(@right, @bottom)
  end

  def bottomleft
    Point.new(@x, @bottom)
  end

  def center
    Point.new(@x + @width/2, @y + @height/2)
  end

  def center_x
    @x + @width / 2
  end

  def center_y
    @y + @height / 2
  end

  def center_top
    Point.new(@x + @width / 2, @y)
  end

  def center_bottom
    Point.new(@x + @width / 2, @y + @height)
  end

  def center_left
    Point.new(@x, @y + @height / 2)
  end

  def center_right
    Point.new(@x + @width, @y + @height / 2)
  end
#===============================================================================
# Collision methods
#===============================================================================  
#-----------------------------------------------------------------------------
# returns true if the specified point is within this rectangle.
#-----------------------------------------------------------------------------
  def contains_point(point, include_border=false)
    point.x.between?(@x, self.right) && point.y.between?(y, self.bottom) unless include_border
    (point.x >= @x) && (point.x <= self.right) && (point.y >= @y) && (point.y <= self.bottom)
  end
#-----------------------------------------------------------------------------
# returns true of the specified rectangle collides with this rectangle.
#-----------------------------------------------------------------------------
  def collide_rect?(other_rect)
    !intersects(other_rect).empty?
  end
#-----------------------------------------------------------------------------
# returns the intersection area as a rectangle. If there is no intersection
# then an empty rectangle will be returned.
#-----------------------------------------------------------------------------
  def intersects(other_rect)
    new_x = [@x, other_rect.x].max
    new_y = [@y, other_rect.y].max

    new_width = [@x + @width, other_rect.x + other_rect.width].min - new_x
    new_height = [@y + @height, other_rect.y + other_rect.height].min - new_y

    return Rectangle.empty if new_width <= 0 || new_height <= 0
    return Rectangle.new(new_x, new_y, new_width, new_height)
  end
#===============================================================================
# Misc
#===============================================================================  
  def add_point(point)
    @x += point.x
    @y += point.y
    self
  end

  def sub_point(point)
    @x -= point.x
    @y -= point.y
    self
  end

  def empty?
    @x == 0 && @y == 0 && @width == 0 && @height == 0
  end

  def to_rect # RGGS Rect
    Rect.new(@x, @y, @width, @height)
  end

  def self.from_rect(rgss_rect)
    Rectangle.new(rgss_rect.x, rgss_rect.y, rgss_rect.width, rgss_rect.height)
  end

# Returns a random point within this rectangle.
# Returns nil if the width OR the height equals zero.
  def rand_point
    return nil if @width == 0 || @height == 0
    Point.new(1 + @x + rand(@x + @width), 1 + @y + rand(@y + @height))
  end

  def clone
    Rectangle.new(@x, @y, @width, @height)
  end
#===============================================================================
# Overloading
#===============================================================================
  def *(value)
    if value.kind_of?(Fixnum) || value.kind_of?(Float)
      return Rectangle.new(@x * value, @y * value,
                           @width * value, @height * value)
    elsif value.kind_of?(Rectangle)
      return Rectangle.new(@x * value.x, @y * value.y,
                           @width * value.width, @height * value.height)
    end
    raise 'Invalid multiplication. Must be typeof Fixnum or Rectangle'
  end

  def +(value)
    if value.kind_of?(Fixnum) || value.kind_of?(Float)
      return Rectangle.new(@x + value, @y + value,
                           @width + value, @height + value)
    elsif value.kind_of?(Rectangle)
      return Rectangle.new(@x + value.x, @y + value.y,
                           @width + value.width, @height + value.height)
    end
    raise 'Invalid add. Must be typeof Fixnum or Rectangle'
  end

  def -(value)
    if value.kind_of?(Fixnum) || value.kind_of?(Float)
      return Rectangle.new(@x - value, @y - value,
                           @width - value, @height - value)
    elsif value.kind_of?(Rectangle)
      return Rectangle.new(@x - value.x, @y - value.y,
                           @width - value.width, @height - value.height)
    end
    raise 'Invalid substraction. Must be typeof Fixnum or Rectangle'
  end

  def /(value)
    if value.kind_of?(Fixnum) || value.kind_of?(Float)
      return Rectangle.new(@x / value, @y / value,
                           width / value, height / value)
    elsif value.kind_of?(Rectangle)
      return Rectangle.new(@x / value.x, @y / value.y,
                           width / value.width, height / value.height)
    end
    raise 'Invalid divide. Must be typeof Fixnum or Rectangle'
  end

  def ==(value)
    raise "Rectangle expected typeof Rectangle for == operator. Got: #{value.class} expected: #{self.class} value: #{value}" if !value.kind_of?(Rectangle)
    @x == value.x && @y == value.y &&
        @width == value.width && @height == value.height
  end

  def !=(value)
    raise "Rectangle expected typeof Rectangle for != operator. Got: #{value.class} expected: #{self.class} value: #{value}" if !value.kind_of?(Rectangle)
    !(@x == value.x && @y == value.y &&
        @width == value.width && @height == value.height)
  end

  def [] key
    [@x, @y, @width, @height]
  end

  def []= key, value
    @x = [0]
    return if value.length == 1
    @y = [1]
    return if value.length == 2
    @width = [2]
    return if value.length == 3
    @height = [3]
  end

  def to_s
    "(X:#{@x}, Y:#{@y}, W:#{@width}, H:#{@height})"
  end
end # class Rectangle
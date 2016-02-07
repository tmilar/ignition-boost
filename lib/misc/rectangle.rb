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
  attr_reader :x
  attr_reader :y
  attr_accessor :width
  attr_accessor :height

  def self.empty # same as Rectangle.new w/o parameters
    Rectangle.new
  end

  def initialize(x=0, y=0, width=0, height=0)
    @x, @y, @width, @height = x, y, width, height
    @show_borders = IB::DEBUG.key?(:borders) && IB::DEBUG[:borders]
    if @show_borders
      draw_borders
      update_borders
    end
  end

  # A center-expanded (in all directions) rectangle, using other_rect size
  def expand(other_rect)
    raise "Can't expand, without a valid Rectangle!" unless other_rect.is_a?(Rectangle)
    Rectangle.new(@x - other_rect.width, @y - other_rect.height, @width + 2*other_rect.width, @height + 2*other_rect.height)
  end


  # Center-expand (in all directions) this rectangle, using other_rect size or a constant value
  def expand!(expansion)
    case expansion
      when Rectangle
        self.x -= expansion.width
        self.y -=  expansion.height
        self.width +=  2*expansion.width
        self.height +=  2*expansion.height
      when Fixnum, Float
        self.x -= expansion
        self.y -=  expansion
        self.width +=  2*expansion
        self.height +=  2*expansion
      else raise "Can't expand, without a valid Rectangle or constant Fixnum!"
    end
    self # Return self expanded rectangle
  end


  # param [config] : hash  { :x => [rel_min_x, rel_max_x], :y => [rel_min_y, rel_max_y] }
  # return new limited rectangle
  def limit(config)
    unless !config.nil? &&
        !config.empty? &&
        (config.key?(:x) ||  config.key?(:y))
      raise "invalid rectangle hash config : #{config}"
    end

    default_min = 0.0
    default_max = 1.0

    offset_left = config.key?(:x) ? (config[:x][0] || default_min) : default_min
    offset_right = config.key?(:x) ? (config[:x][1] || default_max)  : default_max
    offset_top = config.key?(:y) ? (config[:y][0] || default_min)  : default_min
    offset_bot = config.key?(:y) ? (config[:y][1] || default_max)  : default_max

    Rectangle.new(left * (1 - offset_left),   #x
                  top * (1 - offset_top),     #y
                  right * offset_right,       #width
                  bottom *   offset_bot       #height
    )
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
    Point.new(right, bottom)
  end

  def bottomleft
    Point.new(@x, bottom)
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

  def collides?(other_rect)
    collide_rect?(other_rect)
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
  def x=
    @x = x
    if @show_borders
    @borders.each { |b| b.x = x }
    update_borders
    end

  end

  def y=
    @y = y
    if @show_borders
    @borders.each { |b| b.y = y }
    update_borders
    end
  end

  def center=(center)
    current = self.center
    new_center = current + center
    @x = new_center.x
    @y = new_center.y
  end

  def dispose
    clear_borders
    # @borders.each { |b| b.dispose }
  end

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

#===============================================================================
# Debugging : borders
#===============================================================================
  def update_borders
    @borders.each { |b| b.update }
  end

  def clear_borders
    return unless @borders
    @borders.delete_if { |b|
      b.bitmap.clear
      b.bitmap.dispose
      b.dispose
      true
    }
  end

  def draw_borders
    clear_borders
    @top_line = draw_line(topleft, topright, "top")  unless @top_line
    @bot_line = draw_line(bottomleft, bottomright, "bot") unless @bot_line
    @right_line = draw_line(topright, bottomright, "right") unless @right_line
    @left_line = draw_line(topleft, bottomleft, "left") unless @left_line
    @borders = [@top_line, @bot_line, @right_line, @left_line]
  end

  def draw_line(orig, dest, side)
    min_width = 1
    size = Point.new([(dest.x-orig.x),min_width].max, [(dest.y-orig.y),min_width].max)

    # Logger.trace("#{self} drawing #{side} line, from #{orig} to #{dest}. Abs size: #{size}")
    line = Sprite.empty(orig)#(Sprite.viewport)

    # line.x = orig.x
    # line.y = orig.y
    line.z = 99999
    # line = Bitmap.new(size.x, size.y)
    # line.fill_rect(orig.x, orig.y, size.x, size.y, Color.new(255, 100, 0))

    line.bitmap = Bitmap.new(size.x, size.y)
    # line.bitmap.fill_rect(orig.x, orig.y, size.x, size.y, Color.new(255, 100, 0))
    line.bitmap.fill_rect(line.bitmap.rect, Color.new(200, 50, 50))


    line

  end
end # class Rectangle
class Object
  def nil_zero?
    self.nil? || self == 0
  end

  def nil_empty?
    self.nil? || (self.empty? if self.respond_to?(:empty?))
  end
end

# # which lets you do
# nil.nil_zero? # returns true
# 0.nil_zero?   # returns true
# 1.nil_zero?   # returns false
# "a".nil_zero? # returns false
#
# unless discount.nil_zero?
#   # do stuff...
# end
# source: http://stackoverflow.com/questions/252203/checking-if-a-variable-is-not-nil-and-not-zero-in-ruby
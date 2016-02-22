class Class
  #firstly, the * decoration on the parameter variable
  #indicates that the parameters should come in as an array
  #of whatever was sent

  def attr_readers_delegate(accessor, *props)
    props.each {
      |prop|
      #Here's the getter
      _log_and_class_eval('getter', accessor, prop)
    }
  end

  def attr_accessors_delegate(accessor, *props)
    props.each {
        |prop|
      #Here's the getter
      _log_and_class_eval('getter', accessor, prop)
      #Here's the setter
      _log_and_class_eval('setter', accessor, prop)
    }
  end

  private
  def _log_and_class_eval(type, accessor, prop, log=true)
    case type
      when 'getter' then method = "def #{prop}; #{accessor} ? #{accessor}[:#{prop}] : nil ;end"
      when 'setter' then method = "def #{prop}=(val);Logger.trace(\"\#{self} :#{prop} changed from \#{#{prop}} to \#{val}!\") if #{prop}!=val;Logger.trace(\"\#{self} :#{prop} didn't change, '#{prop}' value is already \#{val}!\") if #{prop}==val; #{accessor} = {} if #{accessor}.nil?; #{accessor}[:#{prop}]=val;end"
      else raise "Error, trying to define an invalid method type! #{type}"
    end
    Logger.trace("<#{self}> Defining #{type}: #{method}") if log
    self.class_eval(method)
  end

end
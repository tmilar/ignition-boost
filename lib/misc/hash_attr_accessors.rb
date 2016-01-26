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
      when 'getter' then method = "def #{prop}; #{accessor}[:#{prop}];end"
      when 'setter' then method = "def #{prop}=(val);Logger.trace(\"#{self} #{prop} changed from \#{#{accessor}[:#{prop}]} to \#{val}!\"); #{accessor}[:#{prop}]=val;end"
      else raise "Error, trying to define an invalid type! #{type}"
    end
    Logger.trace("<#{self}> Defining #{type}: #{method}") if log
    self.class_eval(method)
  end

end
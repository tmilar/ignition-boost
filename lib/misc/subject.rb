# require 'forwardable'

module Subject
  # extend Forwardable

  # def_instance_delegator :@observers, :<<, :add_observer
  # def_instance_delegator :@observers, :delete, :delete_observer

  attr_accessor :observers

  def initialize(config = {})
    @observers = []
    super(config)
  end

  def add_observer(observer)
    @observers << observer
  end

  def delete_observer(observer)
    @observers.delete(observer)
  end

  def notify_observers(msg, data={})
    @observers.each do |observer|
      observer.notified(msg, data)
    end
  end
end

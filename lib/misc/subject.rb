# require 'forwardable'

module Subject
  # extend Forwardable

  # def_instance_delegator :@observers, :<<, :add_observer
  # def_instance_delegator :@observers, :delete, :delete_observer

  attr_accessor :observers

  def initialize(config = {})
    @observers = []
    if config.key(:observers) && !config[:observers].nil_empty?
      Logger.trace("#{self} pushing observers #{config[:observers]} to current ones: #{@observers}")
      add_observers(config[:observers])
    end
    Logger.trace("Initialized Subject #{self.class} with conf #{config}")
    super(config)
  end

  def add_observers(observers)
    Array(observers).each { |o| add_observer(o) }
  end

  def add_observer(observer)
    @observers << observer unless @observers.include?(observer)
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

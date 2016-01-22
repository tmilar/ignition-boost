$imported = {} if $imported.nil?
$imported["Babu_Logger"] = true
class Logger
  ERROR = 1
  WARNING = 2
  INFO = 3
  DEBUG = 4
  TRACE = 5

  @@level = TRACE

  # Lazily instantiate @@log
  def self.log
    @@log ||= File.open('game.log', 'w')
  end

  # private-like
  def self.msg(log_msg)
    puts log_msg
    log.puts("[#{Time.now.strftime("%d/%m/%Y %H:%M:%S")}] #{log_msg}")
    log.flush
  end

  def self.error(msg)
    msg("[ERROR] #{msg}")
  end

  def self.warn(msg)
    msg("[WARNING] #{msg}") if @@level >= WARNING
  end

  def self.info(msg)
    msg("[INFO] #{msg}") if @@level >= INFO
  end

  def self.debug(msg)
    msg("[DEBUG] #{msg}") if @@level >= DEBUG
  end

  def self.trace(msg)
    msg("[TRACE] #{msg}") if @@level >= TRACE
  end

  def self.level=(new_level)
    @@level = new_level
  end

  def self.level
    @@level
  end


  def self.start(object, options={}, defaults={})
    Logger.info("New #{object} created...#{"Defined or Configured options: #{options}" if !options.empty?}")

    (defaults.keys - options.keys).each { |key|
      Logger.warn("Undefined #{object} option #{key.inspect}, default used: '#{defaults[key]}'")
    }
  end
end
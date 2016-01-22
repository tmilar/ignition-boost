#==============================================================================
# ** Main  ///////  Replace MAIN with THIS
#------------------------------------------------------------------------------
#  This processing is executed after module and class definition is finished.
#==============================================================================
begin
  rgss_main do
    begin
      SceneManager.run
    rescue RGSSReset
      Graphics.transition(10)
      retry
    end
  end
rescue SystemExit
  exit
rescue Exception => error
  # Prepare scripts information
  scripts_name = load_data('Data/Scripts.rvdata2')
  scripts_name.collect! {|script|  script[1]  }

  # Build error backtrace string
  backtrace = []
  error.backtrace.each_with_index {|line,i|
    if line =~ /{(.*)}(.*)/
      backtrace << (scripts_name[$1.to_i] + $2)
    elsif line.start_with?(':1:')
      break
    else
      backtrace << line
    end
  }
  error_line = backtrace.first
  error_msg = "%s: %s, %s" %[error_line, error.message, error.class]
  backtrace[0] = ''

  # Log error backtrace
  if $imported["Babu_Logger"]
    Logger.error(error_msg)
    Logger.error(backtrace.join("\n\tfrom "))
  end

  # If no Logger defined, only write to error_log.txt
  File.open("error_log.txt", "w") do |f|
    f.write(error_msg)
    f.write(backtrace.join("\n\tfrom "))
  end


  raise  error.class, "Error ocurred, check the debug console for more information.", [error.backtrace.first]
end
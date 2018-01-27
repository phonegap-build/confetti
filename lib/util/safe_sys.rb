module SafeSys

  CommandResult = Struct.new(:exit, :out, :err) do 
    def to_s
      out || ""
    end
  end

  def safe_command *cmd, params
    if !params.is_a?(Hash)
      cmd.push params
      params = {}
    end

    opts = { :raise => true, :dir => Dir.pwd, :timeout => 5*60 }
    opts.merge!(params)

    cmd.map!{|v| v.to_s}

    begin
      Open3.popen3(*cmd, {:pgroup => true, :chdir => opts[:dir]}) {|_in, _out, _err, _wait|
        output = Thread.new { _out.read }
        error  = Thread.new { _err.read }

        if !_wait.join(opts[:timeout]) # wait for thread for opts[:timeout]
          Process.kill(:TERM, -_wait.pid) # kill the process group
          raise Timeout::Error.new
        end

        output = output.value
        error  = error.value
        exit   = _wait.value.exitstatus

        if exit != 0 && opts[:raise] === true
          raise IOError, "\"#{ cmd.join(' ') }\": #{ error }"
        end
        CommandResult.new exit, output, error
      }      
    rescue Timeout::Error => ex # timeout limit reached
      if opts[:raise] === true
        raise IOError, "\"#{ cmd.join(' ') }\": command timeout"
      end
      CommandResult.new 124, nil, "\"#{ cmd.join(' ') }\": command timeout"
    rescue Errno::ENOENT => ex # always raise bad command errors
      raise IOError, "\"#{ cmd }\": #{ ex.message }"
    end
  end
  module_function :safe_command
end

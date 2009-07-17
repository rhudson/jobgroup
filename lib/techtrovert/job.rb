module Techtrovert
  class Job
    
    attr_reader :exception
    attr_reader :return_val
    attr_reader :pids
    
    def initialize(*args, &block)
      if block.nil?
        @job  = args.shift
      else
        @job = block
      end
      
      @args = args
      @pipe_reader = nil
      @pipe_writer = nil
      @exception   = nil
      @return_val  = nil
      @pids        = []
    end
    
    
    def kill
      @pids.each do |pid|
        Process.kill("TERM", pid)
        Process.detach(pid)
      end
    end
    
    
    def run
      @pipe_reader, @pipe_writer = IO.pipe
      
      pid = fork

      # Parent process
      if pid
        @pids << pid
        @pipe_writer.close
        return_yaml = @pipe_reader.read
        if return_yaml != nil and return_yaml != ""
          return_hash = YAML::load(return_yaml)
          if return_hash[:exception] != nil
            @exception = return_hash[:exception].exception(return_hash[:message])
            @exception.set_backtrace(return_hash[:backtrace])
          end
          @return_val = return_hash[:return_val]
        end
        @pipe_reader.close
        Process.waitpid(pid, Process::WNOHANG)
      
      # Child process
      else
        begin
          @pipe_reader.close
          return_hash = {}
          begin
            run_helper
            return_hash[:return_val] = @return_val if @return_val != nil
          rescue Exception => exc
            # Collect the pertinent pieces of the exception to be returned to
            # the parent process.  This is done because Exception objects do not
            # seem to yamlize very well.
            return_hash[:exception] = exc
            return_hash[:message] = exc.message
            return_hash[:backtrace] = exc.backtrace
          end
  
          @pipe_writer.write return_hash.to_yaml if !return_hash.empty?
          @pipe_writer.close
          exit 0
  
        rescue Exception => e
          # ignore these exceptions
        end

      end

    end
    
    
    def exception_thrown?
      @exception != nil
    end

    
    private 
    
    def run_helper
      puts "Job PID: #{Process.pid}" if $DEBUG
      
      if @job.kind_of? Method or @job.kind_of? Proc
        @return_val = @job.call(*@args)
      else
        raise "Unknown job type."
      end
    end

  
  end


end

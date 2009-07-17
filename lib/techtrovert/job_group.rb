require 'techtrovert/job'
require 'monitor'

module Techtrovert
  class JobGroup

    attr_accessor  :concurrent_limit
    attr_accessor  :failed_jobs
    attr_accessor  :abort_on_exceptions
    
    def initialize
      @job_queue        = []
      @job_hash         = {}
      @failed_jobs      = []
      @threads          = []
      @concurrent_limit = 10
      @lock             = Monitor.new
      @abort_on_exceptions = true
    end
    
    
    def add(*args, &block)
      id = Time.now.to_f.to_s.to_sym
      @job_queue << id
      @job_hash[id] = Job.new(*args, &block)
      return id
    end
    
    
    def get_job(id)
      return @job_hash[id]
    end
    
    
    def kill_all
      @threads.each do |thread|
        job_id = thread[:job_id]
        @job_hash[job_id].kill if @job_hash[job_id] != nil
        Thread.kill(thread)
      end
      @threads = []
    end

    
    def run
      
      #Thread.abort_on_exception = @abort_on_exceptions
      
      puts "JobGroup PID: #{Process.pid}" if $DEBUG

      loop_again = true
      
      @old_threads = []
      
      while loop_again

        loop_again = false
        
        schedule_jobs
        
        # wait a second between each scan of the ThreadGroup
        sleep 1

        active_threads = @old_threads
        
        # Check for dead threads that have not exited
        while (thread = @threads.pop)
          if thread.alive?
            loop_again = true
            active_threads.push thread
          else
            begin
              thread.join
            rescue Exception => e
              if (job = @job_hash[thread[:job_id]]) != nil
                e = job.exception if job.exception_thrown?
              end
              if @abort_on_exceptions
                kill_all
                raise e
              end
            end
          end
        end
        
        @old_threads = @threads
        @threads = active_threads
        
        # Keep going if there are still jobs waiting to be run
        loop_again = true if !@job_queue.empty?
      end
      
    end
    
    
    private
    
    def schedule_jobs
      
      # Check to see if there is room for another job
      return if @threads.length >= @concurrent_limit
      
      while (job_id = @job_queue.shift) != nil
        job_temp = @job_hash[job_id]
        next if job_temp.nil?
        @threads << Thread.new do
          job = job_temp
          Thread.current[:job_id] = job_id
          job.run
          add_failed_job(job) if job.exception_thrown?
        end
        break if @threads.length >= @concurrent_limit
      end
    
    end
    
    
    def add_failed_job(job)
      @lock.synchronize do
        @failed_jobs << job
        raise job.exception if @abort_on_exceptions
      end
    end
  
  end


end


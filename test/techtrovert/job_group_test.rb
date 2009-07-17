require File.dirname(__FILE__) + '/../test_helper'

require 'techtrovert/job_group'

class TestJobGroup < Test::Unit::TestCase
  
  EXCEPTION_MESSAGE = "oops, failure."
  PRINT_MESSAGE_RETURN_VAL = { :answer => "data" }
  
  def test_job_group
    jgroup = Techtrovert::JobGroup.new

    # Add a job as a method
    job_id = jgroup.add(self.method(:print_message), "First note.", "Second NOTE.")
    jgroup.run
    assert(jgroup.failed_jobs.empty?, "Job should NOT have failed")
    
    # Test that the Job's return value was maintained
    job = jgroup.get_job(job_id)
    assert_not_nil(job.return_val, "Job should have a return value.")
    assert_equal(PRINT_MESSAGE_RETURN_VAL.class, job.return_val.class, "Job return value has unexpected type.")
    assert_equal(PRINT_MESSAGE_RETURN_VAL[:answer], job.return_val[:answer], "Job has unexpected return value.")
    
    # Verify that exceptions thrown by the job are captured
    jgroup.add(self.method(:raise_exception), EXCEPTION_MESSAGE)
    assert_raise(RuntimeError, EXCEPTION_MESSAGE) do
      jgroup.run
    end
    assert_exception(jgroup, EXCEPTION_MESSAGE)
    
    # Add a job as a block
    message = "Block raised exception"
    jgroup.add(message) { |m| raise_exception(m) }
    assert_raise(RuntimeError, EXCEPTION_MESSAGE) do
      jgroup.run
    end
    assert_exception(jgroup, message)

    # Blocks can look like this too
    message = "Multi-line block raised exception"
    jgroup.add(message) do |m|
      raise_exception(m)
    end
    assert_raise(RuntimeError, EXCEPTION_MESSAGE) do
      jgroup.run
    end
    assert_exception(jgroup, message)

    # ...or this
    message = "lambda block raised exception"
    jgroup.add(lambda { |m| raise_exception(m) }, message)
    
    # Setting the abort_on_exceptions property to false will prevent
    # the JobGroup from raising the exceptions that occur in the Job.
    # The exceptions will still be recorded in the Job, just not thrown.
    jgroup.abort_on_exceptions = false
    
    # Verify that the Job's exception is NOT thrown by the JobGroup 
    assert_nothing_raised do
      jgroup.run
    end
    assert_exception(jgroup, message)

  end


  def test_job_group_handles_array_args
    jgroup = Techtrovert::JobGroup.new
    
    # Add a job as a method
    first_item = "ITEM1"
    string_arg = "STRING ARGUMENT #1"
    job_id = jgroup.add(self.method(:handle_array), [first_item], string_arg)
    jgroup.run
    assert(jgroup.failed_jobs.empty?, "Job should NOT have failed")
    
    # Test that the Job's return value was maintained
    job = jgroup.get_job(job_id)
    assert_not_nil(job.return_val, "Job should have a return value.")
    
    return_hash = job.return_val
    assert(return_hash.kind_of?(Hash), "Return value should be a Hash")
    
    assert_equal(first_item, return_hash[:array_first], "Job return value has unexpected value.")
    assert_equal(string_arg, return_hash[:string_arg], "Job return value has unexpected value.")

  end


  def assert_exception(jgroup, message)
    assert(!jgroup.failed_jobs.empty?, "Job should have failed")
    job = jgroup.failed_jobs.shift
    assert_not_nil(job.exception, "Failed job should have an exception")
    assert_equal(message, job.exception.message, "Unexpected exception raised.")
    assert_not_nil(job.exception.backtrace, "Exception backtrace not found.")
  end

  
  def print_message(message, message2)
    puts "MESSAGE: #{message}"
    puts "MESSAGE2: #{message2}"
    puts
    return PRINT_MESSAGE_RETURN_VAL
  end


  def handle_array(array_arg, string_arg)
    return nil if !array_arg.kind_of? Array
    return {:array_first => array_arg.first, :string_arg => string_arg}
  end


  def raise_exception(message)
    raise message
  end
  
end


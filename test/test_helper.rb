require 'rubygems'
#require 'ruby-debug'

require "test/unit"
require 'active_support'
require 'action_controller'
require 'active_record'
require 'action_mailer'

ENV["RAILS_ENV"] = "test"
$: << File.expand_path(File.dirname(__FILE__) + "/../lib")
#require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
#require 'test_help'

ActionMailer::Base.template_root = File.expand_path(File.dirname(__FILE__) + "/../views")
ActionMailer::Base.delivery_method = :test
if ActionMailer::Base.logger == nil
  ActionMailer::Base.logger = ActiveSupport::BufferedLogger.new(STDERR)
  ActionMailer::Base.logger.level = ActiveSupport::BufferedLogger::WARN
end

  

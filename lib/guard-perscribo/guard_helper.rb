require 'guard'
require 'support/stdout_helper.rb'

def reload_guardfile!
  capture_stdout { ::Guard.evaluator.reevaluate_guardfile }
end

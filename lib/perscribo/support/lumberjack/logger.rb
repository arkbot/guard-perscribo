require 'perscribo/guard/common'

require 'perscribo/support/core/dsl'

module Perscribo
  module Support
    module Lumberjack
      module Logger
        include Core::Dsl::Bootstrappable

        def self.included(base)
          bootstrap!(lambda { ::Lumberjack::Logger }.call)
        end

        module Bootstraps
          module PrependMethods
            def base_sev
              lambda { ::Lumberjack::Severity }.call
            end

            # TODO: NEED TO CHOP LINES AT X CHARACTERS
            # TODO: NEED TO CACHE PROGNAME SIZES
            # TODO: REFACTOR THIS NOW
            def add(severity, message = "", progname = nil, &block)
              message = block.call if message.empty? && block_given?
              color = base_sev.severity_to_color(severity)
              progname = (progname == 'Guard::Ui' ? 'Guard' : progname)
              progname = (progname || '?').center(9).try(color)
              (message.strip.empty? ? "\n" : message).each_line do |line|
                super(severity, line, progname)
              end
            end

            def success(message = nil, name = nil, &block)
              add(base_sev.const_get(:SUCCESS, false), message, name, &block)
            end

            def failure(message = nil, name = nil, &block)
              add(base_sev.const_get(:FAILURE, false), message, name, &block)
            end
          end
        end
      end
    end
  end
end

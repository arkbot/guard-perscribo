require 'perscribo/guard/common'

require 'perscribo/support/core/dsl'

module Perscribo
  module Support
    module Lumberjack
      module Logger
        include Core::Dsl::Bootstrappable

        def self.included(base)
          base.instance_eval do
            bootstrap!(lambda { ::Lumberjack::Logger }.call)
          end
        end

        module Bootstraps
          module PrependMethods
            def self.prepended(base)
              base.inside do
                [Array, Hash].each { |i| formatter.add(i, :pretty_print) }
                # Workaround for whitespace stripping, because it's annoying.
                formatter.add(String) { |s| "▸ #{s}" }
              end
            end

            unless const_defined?(:BASE_SEV, false)
              BASE_SEV = lambda { ::Lumberjack::Severity }.call
            end

            # TODO: NEED TO CHOP LINES AT X CHARACTERS
            # TODO: NEED TO CACHE PROGNAME SIZES
            # TODO: REFACTOR THIS NOW
            def add(severity, message = "", progname = nil, &block)
              message = block.call if message.empty? && block_given?
              color = BASE_SEV.severity_to_color(severity)
              progname = (progname || '?').center(9).try(color)
              (message.strip.empty? ? "\n" : message).each_line do |line|
                super(severity, line, progname)
              end
            end

            def success(message = nil, name = nil, &block)
              add(BASE_SEV.const_get(:SUCCESS, false), message, name, &block)
            end

            def failure(message = nil, name = nil, &block)
              add(BASE_SEV.const_get(:FAILURE, false), message, name, &block)
            end
          end
        end
      end
    end
  end
end

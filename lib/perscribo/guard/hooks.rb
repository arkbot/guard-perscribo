require 'perscribo/core'
require 'perscribo/support/core'

require 'perscribo/guard/common'
require 'perscribo/support/lumberjack'

module Perscribo
  module Guard
    include Support::Core::Dsl::Refinements

    # TODO: Default guard_opts are not injected..
    # => Perscribo::Support::Guard::<PLUGIN>::DEFAULTS[:guard_opts]

    def capture!(config_base)
      config = config_base.const_get(:DEFAULTS, false)
      config[:identifier] = id = config_base.module_eval do
        lambda { Module.nesting }.call.first.to_s.split(/::/).last
      end
      unless $watchers[id].nil?
        $perscribo.listen(id, config[:labels]) do |id, label, *messages|
          [label, messages.join, id]
        end
        $watchers[id] = $perscribo.register(config)
      end
    end

    def setup!(base)
      guard = base.instance_eval do
        lambda { ::Guard::UI }.call
      end

      guard.options = {
        level: :info,
        template: '[ :time | :severity | :progname ] :message',
        time_format: '%Y-%m-%d %H:%M:%S'
      }

      $watchers ||= {}
      $perscribo ||= Core::Proxy.new(guard.logger)

      at_exit do
        $watchers.each { |_, v| v.close }
        $watchers = nil
      end
    end

    publish! :capture!, :setup!

    module Helpers
      include Support::Core::IO::Helpers

      def self.included(base)
        ::Perscribo::Guard.setup!(base)
        base.inside do
          include(Support::Lumberjack::Severity)
          include(Support::Lumberjack::Logger)
        end
      end

      def reload_guardfile!
        capture_all do 
          lambda { ::Guard.evaluator.reevaluate_guardfile }.call
        end
      end
    end
  end
end

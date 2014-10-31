require 'perscribo/guard/common'

require 'perscribo/support/core/dsl'

module Perscribo
  module Support
    module Lumberjack
      module Severity
        include Core::Dsl::Bootstrappable

        def self.included(base)
          bootstrap!(lambda { ::Lumberjack::Severity }.call.singleton_class)
        end

        module Bootstraps
          module PrependMethods
            def self.prepended(base)
              lambda { ::Lumberjack::Severity }.call.inside do
                reset_severities
                add_severity(:SUCCESS, '✔', :green)
                add_severity(:FAILURE, '✖', :red)
                add_severity(:PENDING, '?', :yellow)
              end
            end

            DEFAULT_SEVERITIES = %w(DEBUG INFO WARN ERROR FATAL UNKNOWN)
            DEFAULT_COLORS = %w(yellow light_black light_red red red black)
            DEFAULT_CHARS  = %w(D I W E F U)

            def base_ref
              lambda { ::Lumberjack::Severity }.call
            end

            def base_const_get(name)
              base_ref.const_get(name, false)
            end

            def base_const_set(name, value)
              base_ref.const_set(name, value)
            end

            def base_const_defined?(name)
              base_ref.const_defined?(name, false)
            end

            def base_remove_const(name)
              base_ref.send(:remove_const, name)
            end

            def severity_to_color(severity)
              label = severity.is_a?(Numeric) ? get_label(severity) : severity
              index = base_const_get(:SEVERITY_LABELS).index(label)
              base_const_get(:SEVERITY_COLORS)[index].to_sym
            end

            def get_label(severity)
              base_const_get(:SEVERITY_LABELS)[severity] || "UNKNOWN"
            end

            def severity_to_char(severity)
              label = severity.is_a?(Numeric) ? get_label(severity) : severity
              index = base_const_get(:SEVERITY_LABELS).index(label)
              base_const_get(:SEVERITY_CHARS)[index]
            end

            def level_to_label(severity)
              label = "#{super}"
              color, char = severity_to_color(label), severity_to_char(label)
              color == :default ? char : char.send(:colorize, color)
            end

            def add_severity(label, char, color)
              index = base_const_get(:SEVERITY_LABELS).size
              base_const_set(label.upcase.to_s, index)
              add_item(:SEVERITY_LABELS, label.upcase.to_s)
              add_item(:SEVERITY_CHARS, char.to_s)
              add_item(:SEVERITY_COLORS, color.downcase.to_s)
            end

            # TODO: We do not reset the individual constant for each severity..
            def setup_items(name, *items)
              base_remove_const(name) if base_const_defined?(name)
              base_const_set(name, items.flatten)
            end

            def add_item(name, *items)
              entries = base_const_get(name) || []
              items.each { |i| entries << i.to_s }
              setup_items(name, entries)
            end

            def reset_severities
              setup_items(:SEVERITY_LABELS, DEFAULT_SEVERITIES)
              setup_items(:SEVERITY_COLORS, DEFAULT_COLORS)
              setup_items(:SEVERITY_CHARS, DEFAULT_CHARS)
            end
          end
        end
      end
    end
  end
end

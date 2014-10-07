require 'colorize'
require 'rubyisms'

module SeverityHook
  DEFAULT_LABELS = %w(DEBUG INFO WARN ERROR FATAL UNKNOWN)
  DEFAULT_COLORS = %w(yellow light_black light_red red red black)
  DEFAULT_CHARS  = %w(D I W E F U)

  def severity_to_color(severity)
    label = severity.is_a?(Numeric) ? get_label(severity) : severity
    index = ::Lumberjack::Severity::SEVERITY_LABELS.index(label)
    ::Lumberjack::Severity::SEVERITY_COLORS[index].to_sym
  end

  def get_label(severity)
    ::Lumberjack::Severity::SEVERITY_LABELS[severity] || "UNKNOWN"
  end

  def severity_to_char(severity)
    label = severity.is_a?(Numeric) ? get_label(severity) : severity
    index = ::Lumberjack::Severity::SEVERITY_LABELS.index(label)
    ::Lumberjack::Severity::SEVERITY_CHARS[index]
  end

  def level_to_label(severity)
    label = "#{super}"
    color = severity_to_color(label)
    char = severity_to_char(label)
    color == :default ? char : char.send(:colorize, color)
  end

  def add_severity(label, char, color)
    index = ::Lumberjack::Severity::SEVERITY_LABELS.size
    ::Lumberjack::Severity.const_set(label.upcase.to_s, index)
    add_label(:SEVERITY_LABELS, label.upcase.to_s)
    add_label(:SEVERITY_CHARS, char.to_s)
    add_label(:SEVERITY_COLORS, color.downcase.to_s)
  end

  # TODO: We do not reset the individual constant for each label
  def setup_labels(const_field, *labels)
    if ::Lumberjack::Severity.const_defined?(const_field)
      ::Lumberjack::Severity.send(:remove_const, const_field)
    end
    ::Lumberjack::Severity.const_set(const_field, labels.flatten)
  end

  def add_label(const_field, *labels)
    current_values = ::Lumberjack::Severity.const_get(const_field) || []
    labels.each { |i| current_values << i.to_s }
    setup_labels(const_field, current_values)
  end

  def reset_severities
    setup_labels(:SEVERITY_LABELS, DEFAULT_LABELS)
    setup_labels(:SEVERITY_COLORS, DEFAULT_COLORS)
    setup_labels(:SEVERITY_CHARS, DEFAULT_CHARS)
  end
end
::Lumberjack::Severity.singleton_class.send(:prepend, SeverityHook)

module LoggerHook
  # TODO: NEED TO CHOP LINES AT X CHARACTERS
  # TODO: NEED TO CACHE PROGNAME SIZES
  def add(severity, message = "", progname = nil, &block)
    message = block.call if message.empty? && block_given?
    color = ::Lumberjack::Severity.severity_to_color(severity)
    progname = (progname || '?').center(9).try(color)
    (message.strip.empty? ? "\n" : message).each_line do |line|
      super(severity, line, progname)
    end
  end
end
::Lumberjack::Logger.prepend LoggerHook

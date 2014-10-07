require 'guard'
require 'guard-perscribo/lumberjack_helper.rb'

::Guard::UI.options = {
  level: :info,
  template: '[ :time | :severity | :progname ] :message',
  time_format: '%Y-%m-%d %H:%M:%S'
}

# Workaround for whitespace stripping, because it's annoying.
::Guard::UI.logger.formatter.add(String) { |s| "▸ #{s}" }

[Array, Hash].each { |i| ::Guard::UI.logger.formatter.add(i, :pretty_print) }

::Lumberjack::Severity.reset_severities
::Lumberjack::Severity.add_severity(:SUCCESS, '✔', :green)
::Lumberjack::Severity.add_severity(:FAILURE, '✖', :red)
::Lumberjack::Severity.add_severity(:PENDING, '?', :yellow)

module GuardLoggerHook
  def add(severity, message = nil, progname = nil, &block)
    progname = (progname == 'Guard::Ui' ? 'Guard' : progname)
    super(severity, message, progname, &block)
  end

  def success(message = nil, progname = nil, &block)
    add(::Lumberjack::Severity::SUCCESS, message, progname, &block)
  end

  def failure(message = nil, progname = nil, &block)
    add(::Lumberjack::Severity::FAILURE, message, progname, &block)
  end
end
::Guard::UI.logger.class.send(:prepend, GuardLoggerHook)

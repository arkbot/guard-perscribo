require 'perscribo'

$watchers ||= {}
$perscribo ||= Perscribo::Proxy.new(::Guard::UI.logger)

at_exit do
  $watchers.each { |_, v| v.close }
  $watchers = nil
end

def log_output_with_options(identifier, path, watcher_opts = {}, *labels)
  return unless $watchers[identifier].nil?
  labels.each do |i|
    $perscribo.listen(identifier, i) do |id, label, *messages|
      [label, messages.join, id]
    end
  end
  $watchers[identifier] = $perscribo.register(identifier, path, watcher_opts)
end

def log_output(identifier, path, *labels)
  log_output_with_options(identifier, path, nil, *labels)
end

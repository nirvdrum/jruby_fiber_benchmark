require 'bundler/setup'
require 'sidekiq'

if ENV.has_key?('USE_FIBER_POOL')
  $stderr.puts 'Using fiber pool'
  
  if defined?(Sidekiq::Processor)
    require_relative 'lib/celluloid/task_pooled_fiber'
  
    [Sidekiq::Fetcher, Sidekiq::Manager, Sidekiq::Processor, Sidekiq::Scheduled::Poller].each do |klass|
      klass.task_class(Celluloid::TaskPooledFiber)
    end
  end
end

class NoopWorker
  include Sidekiq::Worker

  def perform
  end
end


require_relative 'noop_worker'

queue = Sidekiq::Queue.new

start = Time.now

unless ENV.has_key?('JOB_COUNT')
  $stderr.puts "You must specify JOB_COUNT for this script to run properly"
  exit -1
end

ENV['JOB_COUNT'].to_i.times { NoopWorker.perform_async }

while queue.size > 0
  sleep 0.1
end

puts "Total time: #{Time.now - start}"

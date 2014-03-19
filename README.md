JRuby Fiber Benchmark
=====================

This is a simple project intended to benchmark Fiber performance in different JRuby versions and with other Fiber
modifications.  The Fiber code is stressed by way of a no-op Sidekiq job.  Sidekiq performance is ultimately the
motivating driver here. Sidekiq is tightly coupled to Celluloid and makes heavy use of Celluloid's TaskFibers, which
as the name implies, are tightly coupled to Ruby's Fibers.  While this is an indirect way of testing Fiber performance,
I didn't want to test in isolation and perhaps miss particular call patterns through either Sidekiq or Celluloid.

Prerequisites
-------------

This is a pretty standard and simple Ruby application.  It should work with any Ruby implementation targeting the 1.9+
API.  For my purposes I used JRuby 1.7.10 and JRuby 1.7.11.  You will also need Bundler if you wish to run the code
without modification.  Since this is also testing through Sidekiq, you'll need to have Redis running on localhost:6379.

Running
-------

The benchmark code requires two processes.  The first will run the Sidekiq daemon and will execute jobs pushed onto
Redis by the second.  The second process will also monitor the Sidekiq queue size to report total time for completion.

The Sidekiq daemon process can be run in one of two ways.  The first is just the stock Sidekiq system.  The second,
controlled by use of the `USE_FIBER_POOL` environment variable, will monkeypatch Sidekiq to use a TaskFiberPool
implementation in Celluloid.  This will function identically to stock Sidekiq/Celluloid with the notable exception that
an internal Fiber pool will be used to recycle old Fibers.

Running the Sidekiq daemon without the Fiber pool:

```
bundle exec sidekiq -r noop_worker.rb  -c 100 > /dev/null
```

Running the Sidekiq daemon with the Fiber pool:

```
USE_FIBER_POOL=true bundle exec sidekiq -r noop_worker.rb  -c 100 > /dev/null
```

For my testing purposes I ran the Sidekiq process with 100 workers.  STDOUT is redirected to /dev/null just to ensure
that I/O buffering doesn't adversely impact timing results.


To actually enqueue the jobs and measure the execution time, run:

```
JOB_COUNT=1000 bundle exec ruby benchmark.rb
```

where `JOB_COUNT` is the number of jobs to equeue.
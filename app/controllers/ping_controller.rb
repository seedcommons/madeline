class PingController < ApplicationController
  def index
    if (background_jobs_pid = (File.read(Rails.root.join("tmp/pids/sidekiq.pid")).to_i rescue nil))
      @sidekiq_running = (Process.kill(0, background_jobs_pid) && true rescue false)
    else
      @sidekiq_running = false
    end

    @count = Sidekiq::Queue.new.size
    @stuck = Sidekiq::RetrySet.new.size > 0

    @ok = !@stuck && @sidekiq_running

    render layout: nil, formats: :text, status: @ok ? 200 : 503
  end
end

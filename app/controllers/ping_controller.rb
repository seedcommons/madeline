class PingController < ApplicationController
  def index
    if (background_jobs_pid = (File.read(Rails.root.join("tmp","pids","sidekiq.pid")).to_i rescue nil))
      @sidekiq_running = (Process.kill(0, background_jobs_pid) && true rescue false)
    else
      @sidekiq_running = false
    end

    @count = @sidekiq_running ? Sidekiq::Queue.new.size : "N/A"

    render layout: nil, formats: :text, status: @sidekiq_running ? 200 : 503
  end
end

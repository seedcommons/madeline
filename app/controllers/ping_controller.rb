class PingController < ApplicationController
  def index
    @sidekiq_running = Sidekiq::ProcessSet.new.size > 0
    @process_count = Sidekiq::ProcessSet.new.size
    @count = @sidekiq_running ? Sidekiq::Queue.new.size : "N/A"

    render layout: nil, formats: :text, status: @sidekiq_running ? 200 : 503
  end
end

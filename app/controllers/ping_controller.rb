class PingController < ApplicationController
  def index
    if dj_pid = (File.read(File.join(Rails.root, "tmp/pids/delayed_job.pid")).to_i rescue nil)
      @dj = (Process.kill(0, dj_pid) && true rescue false)
    else
      @dj = false
    end

    render layout: nil, formats: :text, status: @dj ? 200 : 503
  end
end

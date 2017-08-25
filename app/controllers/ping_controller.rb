class PingController < ApplicationController
  def index
    if dj_pid = (File.read(File.join(Rails.root, "tmp/pids/delayed_job.pid")).to_i rescue nil)
      @dj = (Process.kill(0, dj_pid) && true rescue false)
    else
      @dj = false
    end

    @count = Delayed::Job.count

    @stuck = Delayed::Job.where.not(failed_at: nil).count > 0

    @stale = Delayed::Job.where('attempts >= 3 and created_at < ?', Time.now - 1.day).count > 0

    @ok = !@stuck && @dj

    render layout: nil, formats: :text, status: @ok ? 200 : 503
  end
end

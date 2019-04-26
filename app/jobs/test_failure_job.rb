class TestFailureJob < TaskJob
  def perform_task_job(args)
    Rails.logger.debug "This is the test job that should fail!"
    raise StandardError
  end
end

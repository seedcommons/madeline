class TestFailureJob < TaskJob
  def perform(args)
    Rails.logger.debug "This is the test job that should fail!"
    raise StandardError
  end
end

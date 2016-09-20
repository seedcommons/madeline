module Timeline

  class BatchOp

    attr_reader :user, :step_ids, :notice_key

    def initialize(user, step_ids, notice_key: :notice_batch_updated)
      @user = user
      @step_ids = step_ids
      @notice_key = notice_key
    end

    # Returns the two values in an array, the project id, and a 'notice' string needed to redisplay
    # the timeline.
    # 'step_ids' may either be an array of integer or comma separated string
    def perform
      success_count = 0
      failure_count = 0
      project_id = nil
      raise_error = true
      @step_ids = @step_ids.split(',') if @step_ids.is_a?(String)
      @step_ids.each do |step_id|
        begin
          step = ProjectStep.find(step_id)
          Pundit.authorize @user, step, authorization_key
          project_id ||= step.project_id

          # If the block returns false, this indicates no change and this record should be left out of
          # both success and failure counts.
          if batch_operation(@user, step)
            success_count += 1
          end
          raise_error = false
        rescue => e
          Rails.logger.error("project step: #{step_id} - batch operation error: #{e}")
          raise e if raise_error
          failure_count += 1
        end
      end

      notice = I18n.t(@notice_key, count: success_count)
      if failure_count > 0
        notice = [notice, I18n.t(:notice_batch_failures, failure_count: failure_count)].join(" ")
      end

      [project_id, notice]
    end

    protected

    def authorization_key
      raise NotImplementedError.new('Abstract class, please override #authorization_key')
    end

    def batch_operation(user, step)
      raise NotImplementedError.new('Abstract class, please override #perform')
    end
  end
end

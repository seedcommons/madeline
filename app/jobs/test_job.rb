class TestJob < TaskJob
  def perform(args)
    Rails.logger.debug "This is the test job!"
  end
  # def perform(args)
  #   puts "test job perform task job"
  #   # task = Task.find(args[:task_id])
  #   # provider_job_id = task.provider_job_id
  #   # job = nil
  #   # Sidekiq::Queue.all.each do |q|
  #   #   j = q.find_job(provider_job_id)
  #   #   if j.present?
  #   #     job = j
  #   #     next
  #   #   end
  #   # end
  #   # Sidekiq.logger.info "=====PERFORM===="
  #   # Sidekiq.logger.info "Looking for job with provider job id #{provider_job_id}"
  #   # Sidekiq.logger.info "Job found? #{job.present?}"
  #   # #Sidekiq.logger.info "Performing job id #{job.job_id}"
  #   # #Rails.logger.info "This is a test job! for jid #{self.jid}"
  #   # #raise StandardError
  # end
end

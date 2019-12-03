case ENV['QB_SANDBOX_MODE']
when "1"
  Quickbooks.sandbox_mode = true
when "0"
  Quickbooks.sandbox_mode = false
else
  Quickbooks.sandbox_mode = !Rails.env.production?
end

Quickbooks.logger = ActiveSupport::Logger.new Rails.root.join("log", "quickbooks_gem_#{Rails.env}.log")
Quickbooks.log = true

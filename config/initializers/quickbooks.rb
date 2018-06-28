case ENV['QB_SANDBOX_MODE']
when "1"
  Quickbooks.sandbox_mode = true
when "0"
  Quickbooks.sandbox_mode = false
else
  Quickbooks.sandbox_mode = !Rails.env.production?
end

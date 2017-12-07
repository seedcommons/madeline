# ActiveJob seems to provide no way to control this on a per-job basis.
# Defining a max_attempts method does not seem to work.
# Also, setting rescue_from seems to also immediately delete a job, so even if this were not set to 1,
# retries do not appear to work in conjunction with rescue_from.
# So we're disabling retry functionality for now because we don't need it for existing jobs.
# We can use https://github.com/isaacseymour/activejob-retry or similar if we ever need
# the ability to retry a job.
Delayed::Worker.max_attempts = 1

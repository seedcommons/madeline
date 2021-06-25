# Raises an error, that's all. Useful for testing error handling flows in production.
class RaiseAnErrorJob < ApplicationJob
  def perform(**_args)
    raise "Raising an error on purpose!"
  end
end

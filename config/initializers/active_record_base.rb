# Be sure to restart your server when you modify this file.

# convenient methods for all Active Record classes to automatically inherit


class ActiveRecord::Base

  # fetch a single record or return nil if doesn't exist
  def self.find_safe(id)
    self.where(id: id).first
  end

end

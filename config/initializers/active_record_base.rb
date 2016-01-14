# Be sure to restart your server when you modify this file.

# convenient methods for all Active Record classes to automatically inherit


class ActiveRecord::Base

  # fetch a single record or return nil if doesn't exist
  def self.find_safe(id)
    self.where(id: id).first
  end

  # will update the postgres sequence value to be greater than the hightest existing id plus a gap
  # gap - gap in id values to leave between existing hightest id and next value
  def self.recalibrate_sequence(gap=0)
    self.connection.execute("SELECT setval('#{table_name}_id_seq', (SELECT MAX(id) FROM #{table_name})+#{gap})")
  end


end

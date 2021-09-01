# Be sure to restart your server when you modify this file.

# convenient methods for all Active Record classes to automatically inherit


class ActiveRecord::Base
  # will update the postgres sequence value to be greater than the highest existing id plus a gap
  # gap - gap in id values to leave between existing highest id and next value
  def self.recalibrate_sequence(gap: 0, id: nil)
    if id
      self.connection.execute("SELECT setval('#{table_name}_id_seq', #{id})")
    else
      self.connection.execute("SELECT setval('#{table_name}_id_seq', (SELECT MAX(id) FROM #{table_name})+#{gap})")
    end
  end
end

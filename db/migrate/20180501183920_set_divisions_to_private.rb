class SetDivisionsToPrivate < ActiveRecord::Migration[5.1]
  def up
    Division.update_all(public: false)
  end

  def down
    Division.update_all(public: true)
  end
end

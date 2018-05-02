class SetRootDivisionToHidden < ActiveRecord::Migration[5.1]
  def up
    Division.find_by(name: 'Root Division').update_attribute(:public, false)
  end

  def down
    Division.find_by(name: 'Root Division').update_attribute(:public, true)
  end
end

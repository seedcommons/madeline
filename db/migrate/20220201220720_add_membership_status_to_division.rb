class AddMembershipStatusToDivision < ActiveRecord::Migration[6.1]
  def change
    add_column :divisions, :membership_status, :string, default: "ally", null: false
  end
end

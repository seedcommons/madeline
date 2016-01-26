class AddPersonToUser < ActiveRecord::Migration
  def change
    add_reference :users, :profile, index: true
    add_foreign_key :users, :people, column: :profile_id
  end
end

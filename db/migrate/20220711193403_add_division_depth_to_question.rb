class AddDivisionDepthToQuestion < ActiveRecord::Migration[6.1]
  def up
    add_column :questions, :division_depth, :integer, null: true
    Question.find_each do |q|
      q.save!
    end
    change_column_null :questions, :division_depth, false
  end

  def down
    remove_column :questions, :division_depth
  end
end

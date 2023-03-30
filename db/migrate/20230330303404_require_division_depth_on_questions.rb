class RequireDivisionDepthOnQuestions < ActiveRecord::Migration[6.1]
  def change
    change_column_null :questions, :division_depth, false
  end
end

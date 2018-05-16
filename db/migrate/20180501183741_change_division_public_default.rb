class ChangeDivisionPublicDefault < ActiveRecord::Migration[5.1]
  def change
    change_column_default :divisions, :public, false
  end
end

class SetBasicProjectsToHidden < ActiveRecord::Migration[5.1]
  def change
    BasicProject.where(public_level_value: 'public').update_all(public_level_value: 'hidden')
  end
end

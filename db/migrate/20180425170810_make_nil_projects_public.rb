class MakeNilProjectsPublic < ActiveRecord::Migration[5.1]
  def change
    nil_projects = Project.where(public_level_value: nil)

    if nil_projects
      nil_projects.each do |np|
        np.update_attribute(:public_level_value, 'public')
      end
    end

    change_column_null :projects, :public_level_value, false
  end
end

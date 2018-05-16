class MakeBlankProjectsPublicToo < ActiveRecord::Migration[5.1]
  def change
    Project.where(public_level_value: "").update_all(public_level_value: "public")
  end
end

class MakeNilProjectsPublic < ActiveRecord::Migration[5.1]
  def change
    no_pub_val = Project.where(public_level_value: nil)

    if no_pub_val
      no_pub_val.each do |npv|
        npv.update_attribute(:public_level_value, 'featured')
      end
    end
  end
end

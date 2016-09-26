class CustomField < ActiveRecord::Base; end
class CustomFieldSet < ActiveRecord::Base; end

class RenameBreakevenDataToBreakeven < ActiveRecord::Migration
  def change
    cfs = CustomField.where(data_type: 'breakeven_data')
    puts "CustomFields: #{cfs.inspect}"
    cfs.update_all(data_type: 'breakeven')

    cfs.each do |cf|
      id = cf.id.to_s
      lrss = CustomFieldSet.select { |i| i.custom_data.keys.include? id }
      lrss.each do |lrs|
        if lrs.custom_data[id].keys.include? 'breakeven_data'
          puts "CustomFieldSet ##{lrs.id}: renaming"
          lrs.custom_data[id]['breakeven'] = lrs.custom_data[id]['breakeven_data']
          lrs.custom_data[id].delete 'breakeven_data'
          lrs.save!
        end
      end
    end
  end
end

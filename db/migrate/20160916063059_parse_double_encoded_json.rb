class CustomField < ActiveRecord::Base; end
class CustomFieldSet < ActiveRecord::Base; end

class ParseDoubleEncodedJson < ActiveRecord::Migration
  def change
    ids = CustomField.where(data_type: 'breakeven_data').ids.map(&:to_s)
    puts "LoanQuestion ids: #{ids.inspect}"
    ids.each do |id|
      lrss = CustomFieldSet.select { |i| i.custom_data.keys.include? id }
      puts "CustomFieldSet ids: #{lrss.map(&:id).inspect}"
      lrss.each do |lrs|
        value = lrs.custom_data[id]['breakeven_data']
        if value.is_a? String
          puts "Parsing LRS ##{lrs.id.inspect}"
          lrs.custom_data[id]['breakeven_data'] = JSON.parse value
          lrs.save!
        end
      end
    end
  end
end

class ChangeStringToTextType < ActiveRecord::Migration[5.1]
  def up
    # change string type questions to text type
    Question.where(data_type: 'string').update_all(data_type: 'text')

    ResponseSet.all.each do |rs|
      rs.custom_data = switch_string_for_text(rs.custom_data)
      rs.save
    end
  end

  def down
  end

  def switch_string_for_text(old_hash)
    new_hash = {}
    old_hash.each do |k, v|
      value = v.is_a?(Hash) ? switch_string_for_text(v) : v
      k == 'string' ? new_hash['text'] = value : new_hash[k] = value
    end

    new_hash
  end
end

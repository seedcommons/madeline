class ChangeStringToTextType < ActiveRecord::Migration[5.1]
  def up
    # change string type questions to text type
    Question.where(data_type: 'string').update_all(data_type: 'text')

    # update responses hash with text and delete string keys
    # WIP - find a way to loop through values accurately
    # run rake db:migrate:redo VERSION=20181002134709
    ResponseSet.all.each do |rs|
      rs.custom_data.transform_values do |v|
        switch_string_for_text(v)
      end
      rs.save
    end
  end

  def down
  end

  def switch_string_for_text(old_hash)
    # binding.pry
    new_hash = {}
    old_hash.each do |k, v|
      new_hash[k] = v
      if k == 'string'
        new_hash['text'] = v
        new_hash.delete(k)
      end
    end
  end
end

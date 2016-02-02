# -*- SkipSchemaAnnotations
module Legacy

class Translation < ActiveRecord::Base
  establish_connection :legacy
  include LegacyModel

  def migration_data
    new_model_name = Translation.map_model_name(remote_table)
    new_attribute_name = map_attribute_name(new_model_name, remote_column_name)
    puts "Translation[#{self.id}]"
    data = {
        # note, no need to maintain ids from legacy translation table
        # id: self.id,
        translatable_type: new_model_name,
        translatable_id: remote_id,
        translatable_attribute: new_attribute_name,
        language_id: language,
        text: translated_content
    }
    data
  end

  def migrate
    if [1,2].include?(language)
      data = migration_data
      puts "#{data[:id]}: #{data[:translatable_type]}[#{data[:translatable_id]}].#{data[:translatable_attribute]}"
      ::Translation.create(data)
    else
      # note, there is a lot of orphaned translation data in the current production db
      puts "Warning, ignoring Translation[#{id}] with invalid Language reference: #{language}"
    end
  end

  # usage shared with Media
  def self.map_model_name(old_table)
    case old_table
      when 'ProjectEvents'
        'ProjectStep'
      when 'Cooperatives'
        'Organization'
      else
        old_table.singularize
    end
  end

  def map_attribute_name(new_model, old_column)
    ATTRIBUTE_MAP[new_model][old_column]
  end

  ATTRIBUTE_MAP = {
      'Loan' => {'ShortDescription' => 'summary', 'Description' => 'details'},
      'ProjectStep' => {'Summary' => 'summary', 'Details' => 'details'},
      'ProjectLog' => {'Explanation' => 'summary', 'DetailedExplanation' => 'details',
                       'AdditionalNotes' => 'additional_notes', 'NotasPrivadas' => 'private_notes'},
      'Media' => {'Caption' => 'caption', 'Description' => 'description'}
  }

end

end

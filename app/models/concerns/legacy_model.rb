# Methods and declarations for dealing with legacy database
# Include in models referring to tables created outside of rails. Tables generated by rails follow rails conventions.
module LegacyModel
  extend ActiveSupport::Concern

  # Datetime fields to convert to date fields (times are not used - all are set to midnight)
  DATE_FIELDS = %w(Date DateDue DatePaid)

  included do
    # tell rails to look for table name in CamelCase instead of default under_score
    self.table_name = self.table_name.camelize

    # default primary key
    self.primary_key = 'ID'

    # make CamelCase column names accessible as under_score
    column_names.each do |col|
      if col.in? DATE_FIELDS
        # Convert datetimes to date
        define_method(col.underscore) { send(col).try(:to_date) }
      else
        alias_attribute col.underscore, col
      end
    end
  end

  module ClassMethods
    def migratable
      all
    end

    def migrate_all
      puts "---------------------------------------------------------"
      puts "#{name}: #{migratable.count}"
      migratable.find_each(&:migrate)
    end
  end

  def copy_translations(data, from:, to:, local_source: nil)
    from = Array.wrap(from)
    %i[en es].each do |locale|
      local =
        if local_source
          self[local_source[locale]]
        elsif locale == I18n.locale
          self[from.first]
        else
          nil
        end
      local = local&.strip.presence
      remotes = from.map { |c| lookup_translation(locale, c) }.compact
      all = (remotes << local).compact.uniq
      if all.size > 1
        class_name = self.class.name.split('::')[-1]
        Legacy::Migration.log << [class_name, id, "Multiple non-unique translations defined for "\
          "#{locale.upcase} #{from.first}, copying the longest one"]
        all.sort_by!(&:size)
      end
      data[:"#{to}_#{locale}"] = all.last if all.any?
    end
  end

  def lookup_translation(locale, col_name)
    translation = Legacy::Translation.find_by(
      remote_id: id,
      remote_table: self.class.table_name,
      remote_column_name: col_name.to_s.camelize,
      language: locale == :en ? 1 : 2
    )
    translation&.translated_content&.strip.presence
  end

  def map_legacy_person_id(legacy_id)
    return nil if legacy_id == 0 || legacy_id.blank?

    Person.find_by(legacy_id: legacy_id)&.id
  end
end

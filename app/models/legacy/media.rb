# -*- SkipSchemaAnnotations
module Legacy

  class Media < ActiveRecord::Base
    establish_connection :legacy
    include LegacyModel

    LEGACY_MEDIA_BASE_PATH = ENV['LEGACY_MEDIA_BASE_PATH'] || '../legacymedia'

    def migration_data
      file = File.open(Rails.root.join(LEGACY_MEDIA_BASE_PATH, media_path))
      data = {
          id: id,
          media_attachable_type: Translation.map_model_name(context_table),
          media_attachable_id: context_id,
          uploader_id: member_id,
          sort_order: priority,
          item: file
      }
      data
    end

    def migrate
      begin
        data = migration_data
        if data
          puts "#{data[:id]}: #{media_path}"
          ::Media.create!(data)
        end
      rescue StandardError => e
        $stderr.puts "Media[#{id}] #{media_path} - migrate error: #{e} - skipping"
      end
    end


    def self.migrate_all
      puts "media: #{self.count}"
      self.all.each &:migrate
      ::Media.recalibrate_sequence(gap: 1000)

      puts "media translations: #{ Legacy::Translation.where('RemoteTable' => 'Media').count }"
      Legacy::Translation.where("RemoteTable = 'Media'").each &:migrate
    end

    def self.purge_migrated
      puts "Media.delete_all"
      ::Media.delete_all
    end

  end

end

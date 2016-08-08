# -*- SkipSchemaAnnotations
module Legacy

  class LoanResponsesIFrame < ActiveRecord::Base
    establish_connection :legacy
    include LegacyModel


    def migration_data
      data = {
          id: id,
          url: url,
          original_url: original_url,
          height: height,
          width: width,
          html: html
      }
      data
    end

    def migrate
      data = migration_data
      puts "#{data[:id]}: #{data[:url]}"
      ::EmbeddableMedia.create(data)
    end


    def self.migrate_all
      puts "LoanResponseseIFrames: #{ self.count }"
      self.all.each &:migrate
      ::EmbeddableMedia.recalibrate_sequence(gap: 100)

      # todo: wire into loan responses (LoanResponseSets) once 3738 branch is merged down
    end

    def self.purge_migrated
      puts "EmbeddableMedia.destroy_all"
      ::EmbeddableMedia.destroy_all
    end


  end

end

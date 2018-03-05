# -*- SkipSchemaAnnotations
module Legacy

  class LoanResponseSet < ActiveRecord::Base
    establish_connection :legacy
    include LegacyModel

    def self.migrate_all
      puts "loan response sets: #{self.count}"
      all.each(&:migrate)
    end

    def self.purge_migrated
      # note, not complete, but sufficient for purpose
      puts "LoanResponseSet.delete_all"
      ::LoanResponseSet.delete_all
    end

    def migrate
      loan = ::Loan.find_by(id: loan_id)
      unless loan
        $stderr.puts "loan not found for id: #{response_set_id} - skipping"
        return
      end

      # Cache of criteria and post_analysis value sets.
      models = {}

      responses = LoanResponse.where("ResponseSetID = ?", response_set_id)
      puts "responses count: #{responses.count}"
      responses.each do |response|
        # puts "response id: #{response.id} - question id: #{response.question_id}"
        field = ::Question.find_by(id: response.question_id)
        if field
          # puts "question_id: #{response.question_id} - set: #{field.loan_question_set.internal_name}"
          model = models[field.loan_question_set.internal_name]
          unless model
            match = /loan_(.*)/.match(field.loan_question_set.internal_name)
            raise "unexpected custom field set name: #{field.loan_question_set.internal_name}" unless match
            attrib = match[1]
            model = loan.send(attrib) || ::LoanResponseSet.new(kind: attrib, loan: loan, custom_data: {})
            models[field.loan_question_set.internal_name] = model
          end
          # puts "update: #{field.id} -> #{response.value_hash}"
          value_hash = response.value_hash
          model.custom_data[field.id.to_s] = value_hash
        else
          $stderr.puts "WARNING - custom field not found for id: #{response.question_id}"
        end
      end

      models.values.each do |m|
        # Some migration data exists with invalid numeric data.  Need to disable validation here
        # so that the full set of migrated data will be persisted.  A warning will be displayed
        # when a record with invalid data is first loaded (i.e. loan 1043 post analysis).
        # The simple form automatic numeric field handler will automatically strip the invalid
        # numeric data so that the record can still be simply re-saved.
        m.save(:validate => false)
      end

    end

  end

end

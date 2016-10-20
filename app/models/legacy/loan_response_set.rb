# -*- SkipSchemaAnnotations
module Legacy

  class LoanResponseSet < ActiveRecord::Base
    establish_connection :legacy
    include LegacyModel


    def self.migrate_all
      puts "loan response sets: #{self.count}"
      LoanResponseSet.uniq.pluck('ResponseSetID').each do |response_set_id|
        migrate(response_set_id)
      end
    end

    def self.purge_migrated
      # note, not complete, but sufficient for purpose
      puts "LoanResponseSet.delete_all"
      ::LoanResponseSet.delete_all
    end


    def self.migrate(response_set_id)
      has_matching_loan = LoanResponseSet.where("ResponseSetID = #{response_set_id} and LoanID = #{response_set_id}").count
      unless has_matching_loan
        $stderr.puts "ERROR - matching loan unexpectedly missing for response set id: #{response_set_id}"
        raise "ERROR - matching loan unexpectedly missing for response set id: #{response_set_id}"
      end
      loan_id = response_set_id
      new_loan = ::Loan.find_by(id: loan_id)
      unless new_loan
        $stderr.puts "new loan not found for id: #{loan_id} - skipping"
        return
      end

      # criteria = new_loan.fetch_has_one_custom('loan_criteria', autocreate: true)
      # post_analysis = new_loan.fetch_has_one_custom('loan_post_analysis', autocreate: true)
      # Cache of criteria and post_analysis value sets.
      models = {}

      responses = LoanResponse.where("ResponseSetID = ?", response_set_id)
      puts "responses count: #{responses.count}"
      responses.each do |response|
        # puts "response id: #{response.id} - question id: #{response.question_id}"
        field = ::LoanQuestion.find_by(id: response.question_id)
        if field
          # puts "question_id: #{response.question_id} - set: #{field.loan_question_set.internal_name}"
          model = models[field.loan_question_set.internal_name]
          unless model
#            model = new_loan.fetch_has_one_custom(field.loan_question_set.internal_name, autocreate: true)
            match = /loan_(.*)/.match(field.loan_question_set.internal_name)
            raise "unexpected custom field set name: #{field.loan_question_set.internal_name}" unless match
            attrib = match[1]
            model = new_loan.send(attrib) || ::LoanResponseSet.new(kind: attrib, loan: new_loan, custom_data: {})
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
      LoanResponseSet.where("ResponseSetID = ? and ResponseSetID <> LoanID", response_set_id).pluck('LoanID').each do |linked_loan_id|
        puts "related loan: #{linked_loan_id}"
        # todo: clone cross-linked response sets
      end

    end

  end

end

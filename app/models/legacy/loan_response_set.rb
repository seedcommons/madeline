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
      puts "CustomModel.delete_all"
      ::ProjectLog.delete_all
    end


    def self.migrate(response_set_id)
      has_matching_loan = LoanResponseSet.where("ResponseSetID = #{response_set_id} and LoanID = #{response_set_id}").count
      unless has_matching_loan
        puts "ERROR - matching loan unexpectedly missing for response set id: #{response_set_id}"
        raise "ERROR - matching loan unexpectedly missing for response set id: #{response_set_id}"
      end
      loan_id = response_set_id
      new_loan = ::Loan.find_by(id: loan_id)
      unless new_loan
        puts "new loan not found for id: #{loan_id} - skipping"
        return
      end

      responses = LoanResponse.where("ResponseSetID = ?", response_set_id)
      puts "responses count: #{responses.count}"
      responses.each do |response|
        puts "response id: #{response.id} - question id: #{response.question_id}"
        field = CustomField.find_by(id: response.question_id)
        if field
          puts "question_id: #{response.question_id} - set: #{field.custom_field_set.internal_name}"
          # model = new_loan.fetch_belongs_to_custom(attribute_name, field_set_name: field.custom_field_set.internal_name,
          #                                          owner: new_loan.organization, autocreate: true)
          model = new_loan.fetch_has_one_custom(field.custom_field_set.internal_name, autocreate: true)
          # note, could be optimized by building entire json blob and storing as a single operations, but this seems fast enough
          puts "update: #{field.id} -> #{response.value_hash}"

          value_hash = response.value_hash
          embeddable_media_id = value_hash.delete(:embeddable_media_id)
          if embeddable_media_id
            puts "updating owner of embeddable media: #{embeddable_media_id} to cvs #{model.id}"
            embeddable_media = EmbeddableMedia.find_safe(embeddable_media_id)
            if embeddable_media
              embeddable_media.update!(owner: model, owner_attribute: field.id)
            else
              puts "**** warning, dangling embeddable media ref: #{embeddable_media_id} by cvs: #{model.id}"
            end
          end

          model.update_custom_value(field.id, value_hash)
        else
          puts "WARNING - custom field not found for id: #{response.question_id}"
        end
      end

      # LoanResponseSet.where("ResponseSetID = ? and ResponseSetID <> LoanID", response_set_id).pluck('LoanID').each do |linked_loan_id|
      #   puts "related loan: #{linked_loan_id}"
      #   link_response(new_loan, linked_loan_id)
      # end

      LoanResponseSet.where("ResponseSetID = ? and ResponseSetID <> LoanID", response_set_id).pluck('LoanID').each do |linked_loan_id|
        puts "related loan: #{linked_loan_id}"
        # todo: clone cross-linked response sets
      end



    end

    # def self.link_response(source_loan, linked_loan_id)
    #   linked_loan = Loan.find_by(id: linked_loan_id)
    #   if linked_loan
    #     linked_loan.update(loan_criteria_id: source_loan.loan_criteria_id, post_analysis_id: source_loan.post_analysis_id)
    #     old_loan_criteria_id = source_loan.custom_value(:old_loan_criteria_id)
    #     linked_loan.update_custom_value(:old_loan_criteria_id, old_loan_criteria_id)  if old_loan_criteria_id
    #   else
    #     puts "WARNING - linked loan not found: #{linked_loan_id}"
    #   end
    # end

  end

end

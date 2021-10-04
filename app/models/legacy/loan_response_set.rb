# -*- SkipSchemaAnnotations
module Legacy
  class LoanResponseSet < ApplicationRecord
    establish_connection :legacy
    include LegacyModel

    attr_accessor :new_response_sets

    def migrate
      unless loan
        Migration.log << ["LoanResponseSet", id, "Could not find Madeline Loan with ID #{loan_id}, skipping"]
        return
      end
      self.new_response_sets = {}
      build_new_response_sets
      new_response_sets.values.each(&:save!)
    end

    private

    def build_new_response_sets
      # Note, we match our own ResponseSetID as the foreign key as opposed to the usual ID because
      # this is how the old system worked.
      responses = LoanResponse.where("ResponseSetID = ?", response_set_id)
      responses.each do |response|
        unless (response.question.present?)
          Migration.log << ["LoanResponse", response.id, "Could not find legacy LoanQuestion with "\
                                                         "id #{response.question_id}, skipping"]
          next
        end
        unless (new_question = Question.find_by(legacy_id: response.question_id))
          Migration.log << ["LoanResponse", response.id, "Could not find Madeline Question with "\
                                                         "legacy_id #{response.question_id}, skipping"]
          next
        end
        question_set = new_question.question_set
        new_response_sets[question_set] ||= ResponseSet.new(question_set: question_set, loan: loan,
                                                            custom_data: {}, legacy_id: id)
        new_response_sets[question_set].custom_data[new_question.id.to_s] = response.value_hash
      end
    end

    def loan
      @loan ||= ::Loan.find_by(id: loan_id)
    end
  end
end

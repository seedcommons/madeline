# -*- SkipSchemaAnnotations
module Legacy
  class LoanResponseSet < ApplicationRecord
    establish_connection :legacy
    include LegacyModel

    attr_accessor :new_response_sets

    def self.migratable
      # ResponseSetID == 1 seems to be all spam and all sets with this ID map to loan #1
      where.not(response_set_id: 1)
    end

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
      # Note, a given response ID can be mapped to multiple loans. This is why we match LoanResponse
      # on ResponseSetID instead of just ID.
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

        add_value_hash(question_set, new_question, response)
      end
    end

    def add_value_hash(question_set, new_question, response)
      value_hash = response.value_hash
      if LoanResponse::SPAM_URLS.any? { |url| response.answer.include?(url) }
        Migration.skipped_spam_response_count += 1
      elsif (existing = new_response_sets[question_set].custom_data[new_question.id.to_s])
        if existing == value_hash
          Migration.skipped_identical_response_count += 1
        else
          Migration.log << ["LoanResponse", response.id, "(Loan #{loan.id}) Skipped because response "\
                                                         "already existed for this question and loan"]
        end
      else
        puts "LoanResponse #{response.id} value hash:"
        pp value_hash
        new_response_sets[question_set].custom_data[new_question.id.to_s] = value_hash
      end
    end

    def loan
      @loan ||= ::Loan.find_by(id: loan_id)
    end
  end
end

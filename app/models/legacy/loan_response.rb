# -*- SkipSchemaAnnotations
module Legacy

  class LoanResponse < ActiveRecord::Base
    establish_connection :legacy
    include LegacyModel

    def loan_question
      LoanQuestion.where(id: question_id).first
    end

    def loan_question_active
      LoanQuestion.where(id: question_id).pluck(:active).first
    end


    def value_hash
      question = loan_question
      key = question.try(:data_type) == 'number' ? :number : :text
      result = {}
      # Note, numbers will be encoded as JSON strings, but this is by design since
      # float values may introduce rounding issues
      result[key] = answer

      # if question.try(:data_type) == 'number'
      #   result[:number] = answer.to_d
      # end

      result[:rating] = rating  if rating
      result[:embeddable_media_id] = loan_responses_i_frame_id if loan_responses_i_frame_id
      result
    end

  end

end

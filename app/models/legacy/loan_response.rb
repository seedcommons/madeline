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



  end

end

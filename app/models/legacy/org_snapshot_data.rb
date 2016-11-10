module Legacy
  class OrgSnapshotData
    establish_connection :legacy

    def self.create_loan_questions
      defaults = { loan_question_set_id: 2, data_type: 'string' } # criteria
      parent = ::LoanQuestion.create(defaults.merge label: "Migrated from loan fields")
      defaults.merge! parent: parent
      ::LoanQuestion.create(defaults.merge label: "Cooperative members")
      ::LoanQuestion.create(defaults.merge label: "POC ownership %")
      ::LoanQuestion.create(defaults.merge label: "Women ownership %")
      ::LoanQuestion.create(defaults.merge label: "Environmental impact score")
    end

    def self.migrate_all
      create_loan_questions

    end

    def migrate

    end

  end
end

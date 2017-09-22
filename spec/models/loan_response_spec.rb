require 'rails_helper'

describe LoanResponse do
  let(:question) { create(:loan_question, data_type: 'number') }
  let(:response) {
    LoanResponse.new(
      loan: nil,
      question: question,
      loan_response_set: nil,
      data: {}
    )
  }

  describe '#blank?' do
    it do
      expect(response).to be_blank
    end
  end
end


# group == loan_question - has descen. and asc
# loan_response
# QS     RS
# x
#    x - r
#    x - r
#    g - r
#       x - r
#       x
#    x
#    x
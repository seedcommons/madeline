require 'rails_helper'

describe LoanResponse do
  let(:question) { create(:loan_question, data_type: type) }
  let(:response) do
    LoanResponse.new(
      loan: nil,
      question: question,
      loan_response_set: nil,
      data: data
    )
  end
  subject { response }

  describe '#blank?' do
    context 'for non-group questions' do
      let(:type) { 'number' }

      context 'empty response' do
        let(:data) { {} }

        it { is_expected.to be_blank }
      end

      context 'non-empty response' do
        let(:data) { {'number' => 1} }

        it { is_expected.not_to be_blank }
      end
    end

    context 'for group questions' do
      let(:type) { 'group' }
      let(:q1) { create(:loan_question, parent: question, data_type: 'number') }
      let(:q2) { create(:loan_question, parent: question, data_type: 'number') }
      let(:r1) { LoanResponse.new(loan: nil, question: q1, loan_response_set: nil, data: data1) }
      let(:r2) { LoanResponse.new(loan: nil, question: q2, loan_response_set: nil, data: data2) }
      let(:data) { {} }
      let(:data1) { {} }

      before do
        question.reload
        allow(response).to receive(:children) { [r1, r2] }
      end

      context 'both child responses blank' do
        let(:data2) { {} }

        it { is_expected.to be_blank }
      end

      context 'non-empty response' do
        let(:data2) { { 'number' => 3 } }

        it { is_expected.not_to be_blank }
      end
    end
  end
end

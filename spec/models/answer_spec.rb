require 'rails_helper'

describe Answer, type: :model do
  let!(:question_set) { create(:question_set)}
  let!(:question) { create(:question, data_type: type) }
  let!(:response_set) { create(:response_set, question_set: question_set) }
  let(:text_data) { nil }
  let(:numeric_data) { nil }
  let(:boolean_data) { nil }
  let(:breakeven_data) { nil }
  let(:business_canvas_data) { nil }
  let(:linked_document_data) { nil }
  let(:answer) {
    Answer.create({
        response_set: response_set,
        question: question,
        not_applicable: false,
        text_data: text_data,
        boolean_data: boolean_data,
        breakeven_data: breakeven_data,
        business_canvas_data: business_canvas_data,
        linked_document_data: linked_document_data
      })
  }
  subject { answer }

  context "text_answer" do
    let(:type) { "text"}

    context "has text_data" do
      let(:text_data) { "test" }
      it "is valid" do
        expect(subject.valid?).to be_truthy
      end
    end
  end
end

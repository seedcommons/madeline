require 'rails_helper'

describe Response do
  let(:response_set) { create(:response_set)}
  let(:question) { create(:question, data_type: type) }
  let(:response) do
    Response.new(
      loan: nil,
      question: question,
      response_set: response_set,
      data: data
    )
  end
  subject { response }

  before do
    Answer.save_from_form_field_params(question.internal_name, data, response_set)
  end
end

module ModelSpecHelpers
  # Helper method to shorten keys
  def create_question(attribs)
    attribs[:loan_question_set] = attribs.delete(:set)
    attribs[:internal_name] = attribs.delete(:name)
    attribs[:data_type] = attribs.delete(:type)
    create(:loan_question, attribs)
  end
end

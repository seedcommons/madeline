module ResponsesHelper
  def display_value_for_number(question, answer: nil, response_set: nil)
    return if !question.has_number? || answer.nil?
    if question.has_currency?
      "#{prefix(question, response_set)}#{number_with_delimiter(answer.number)} #{postfix(question, response_set)}"
    elsif question.has_percentage?
      "#{number_with_delimiter(answer.number)}%"
    else
      number_with_delimiter(answer.number)
    end
  end

  def prefix(question, response_set)
    if question.has_currency?
      response_set.loan.currency.try(:short_symbol)
    end
  end

  def postfix(question, response_set)
    if question.has_currency?
      response_set.loan.currency.try(:code)
    elsif question.has_percentage?
      "%"
    end
  end
end

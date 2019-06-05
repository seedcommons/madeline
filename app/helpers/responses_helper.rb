module ResponsesHelper
  def display_value_for_number(response)
    return if !response.has_number?
    if response.has_currency?
      "#{prefix(response)}#{response.number} #{postfix(response)}"
    elsif response.has_percentage?
      "#{response.number}%"
    else
      response.number
    end
  end

  def prefix(response)
    if response.has_currency?
      response.loan.currency.try(:short_symbol)
    end
  end

  def postfix(response)
    if response.has_currency?
      response.loan.currency.try(:code)
    elsif response.has_percentage?
      "%"
    end
  end
end

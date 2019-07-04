module ResponsesHelper
  def display_value_for_number(response)
    return if !response.has_number?
    if response.has_currency?
      "#{prefix(response)}#{format_number(response.number)} #{postfix(response)}"
    elsif response.has_percentage?
      "#{format_number(response.number)}%"
    else
      format_number(response.number)
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

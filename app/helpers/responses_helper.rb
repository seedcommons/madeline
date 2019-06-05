module ResponsesHelper
  def display_value_for_number(response)
    return if !response.has_number?
    if response.has_currency?
      "#{display_prefix(response)}#{response.number} #{display_postfix(response)}"
    elsif response.has_percentage?
      "#{response.number}%"
    else
      response.number
    end
  end

  def display_prefix(response)
    if response.has_currency?
      response.loan.currency.try(:short_symbol)
    end
  end

  def display_postfix(response)
    if response.has_percentage?
      "%"
    elsif response.has_currency?
      response.loan.currency.try(:code)
    end
  end
end

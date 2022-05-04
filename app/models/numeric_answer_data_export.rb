class NumericAnswerDataExport < EnhancedLoanDataExport
  def q_data_types
    ["number", "percentage", "rating", "currency", "range"]
  end

  def allow_text_like_numeric?
    false
  end
end

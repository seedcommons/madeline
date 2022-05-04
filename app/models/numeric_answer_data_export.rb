class NumericAnswerDataExport < EnhancedLoanDataExport
  def q_data_types
    ["number", "percentage", "rating", "currency", "range"]
  end

  def include_numeric_answer_in_export?(str)
    true if Float(str) rescue false
  end
end

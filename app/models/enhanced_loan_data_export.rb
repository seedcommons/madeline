class EnhancedLoanDataExport < StandardLoanDataExport

  protected

  def object_data_as_hash(loan)
    super.merge(response_hash(loan))
  end

  # We index questions by ID in this hash but use question labels in the header row.
  def response_hash(loan)
    result = {}
    response_sets = ResponseSet.joins(:question_set).where(loan: loan).order("question_sets.kind")
    response_sets.each do |response_set|
      response_set.answers.each do |a|
        if q_data_types.include?(a.data_type)
          result[a.question_id] = a.answer_for_csv(allow_text_like_numeric: allow_text_like_numeric?)
        end
      end
    end
    result
  end

  def q_data_types
    ["boolean", "text", "number", "percentage", "rating", "currency", "range"]
  end

  def header_rows
    [main_header_row, question_id_row]
  end

  def main_header_row
    headers = StandardLoanDataExport::HEADERS.map { |h| I18n.t("standard_loan_data_exports.headers.#{h}") }
    headers + questions.map { |q| q.label.to_s }
  end

  def question_id_row
    row = [I18n.t("standard_loan_data_exports.headers.question_id")]
    row[StandardLoanDataExport::HEADERS.size - 1] = nil
    row + questions.map(&:id)
  end

  # Returns questions in the order we want them to show up in the header row.
  # Includes question sets from target division and all its descendants.
  def questions
    @questions ||= question_sets.flat_map do |question_set|
      question_set.root_group.self_and_descendants_preordered.select do |q|
        q_data_types.include?(q.data_type)
      end
    end
  end

  def question_sets
    # get all question sets for all response sets of loans in this division and descendants
    loans = division.self_and_descendants.flat_map { |d| Loan.where(division: d) }
    question_sets = loans.flat_map{|l| l.response_sets.map{|rs| rs.question_set}}.uniq
    question_sets.sort_by(&:kind)
  end

  def questions_by_id
    @questions_by_id ||= questions.index_by(&:id)
  end

  # Returns the list of symbols representing headers in the order they should appear.
  def header_symbols
    @header_symbols ||= StandardLoanDataExport::HEADERS + questions.map(&:id)
  end

  def allow_text_like_numeric?
    true #include all numeric answers, even if invalid text
  end
end

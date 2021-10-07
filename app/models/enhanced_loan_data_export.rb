class EnhancedLoanDataExport < StandardLoanDataExport
  Q_DATA_TYPES = ["number", "percentage", "rating", "currency"]

  private

  def loan_data_as_hash(loan)
    super.merge(response_hash(loan))
  end

  # We index questions by ID in this hash but use question labels in the header row.
  def response_hash(loan)
    result = {}
    response_sets = ResponseSet.joins(:question_set).where(loan: loan).order("question_sets.kind")
    response_sets.each do |response_set|
      response_set.custom_data.each do |q_id, response_data|
        question = questions_by_id[q_id.to_i]
        if question.present?
          response = Response.new(loan: loan, question: question,
                                  response_set: response_set, data: response_data)
          if response.has_rating?
            result[q_id.to_i] = response.rating
          elsif response.has_number?
            result[q_id.to_i] = response.number
          end
        end
      end
    end
    result
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

  def questions
    @questions ||= Question.where(data_type: Q_DATA_TYPES).sort_by(&:label)
  end

  def questions_by_id
    @questions_by_id ||= questions.index_by(&:id)
  end

  # Methods below decouple order in BASE_HEADERS constant and question map from the order in which values are added to data row
  def headers_key
    @headers_key ||= StandardLoanDataExport::HEADERS + questions.map(&:id)
  end

  def insert_in_row(column_name, row_array, value)
    row_array[headers_key.index(column_name)] = value
  end
end

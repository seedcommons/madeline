class EnhancedLoanDataExport < StandardLoanDataExport
  Q_DATA_TYPES = ["number", "percentage", "rating", "currency"]

  private

  def loan_data_as_hash(loan)
    super.merge(response_hash(loan))
  end

  def response_hash(loan)
    result = {}
    response_sets = ResponseSet.joins(:question_set).where(loan: loan).order("question_sets.kind")

    response_sets.each do |response_set|
      response_set.custom_data.each do |q_id, response_data|
        question = memoized_questions[q_id.to_i]
        if question.present?
          response = Response.new(loan: loan, question: question,
                                  response_set: response_set, data: response_data)
          if response.has_rating?
            result[q_id] = response.rating
          elsif response.has_number?
            result[q_id] = response.number
          end
        end
      end
    end
    result
  end

  def question_id_row
    row = [I18n.t("standard_loan_data_exports.headers.question_id")]
    row[StandardLoanDataExport::HEADERS.size - 1] = nil
    row + questions_map.keys.sort
  end

  def header_rows
    [main_header_row, question_id_row]
  end

  def main_header_row
    headers = StandardLoanDataExport::HEADERS.map { |h| I18n.t("standard_loan_data_exports.headers.#{h}") }
    headers + questions_map.keys.sort.map { |k| questions_map[k] }
  end

  def questions_map
    @questions_map ||= make_questions_label_map
  end

  # map q_ids as strings (so that they can be treated same as base headers in #insert_in_row) to labels
  def make_questions_label_map
    q_id_to_label_map = {}
    Question.where(data_type: Q_DATA_TYPES).find_each { |q| q_id_to_label_map[q.id.to_s] = q.label.to_s }
    q_id_to_label_map
  end

  def memoized_questions
    @memoized_questions ||= Question.where(data_type: Q_DATA_TYPES).index_by(&:id)
  end

  # Methods below decouple order in BASE_HEADERS constant and question map from the order in which values are added to data row
  def headers_key
    @headers_key = @headers_key || StandardLoanDataExport::HEADERS + questions_map.keys.sort
  end

  def insert_in_row(column_name, row_array, value)
    row_array[headers_key.index(column_name.to_s)] = value
  end
end

# -*- SkipSchemaAnnotations
module Legacy
  class LoanResponse < ApplicationRecord
    establish_connection :legacy
    include LegacyModel
    include ActionView::Helpers::TextHelper

    def question
      LoanQuestion.find_by(id: question_id)
    end

    def value_hash
      key = question.data_type == "number" ? :number : :text
      result = {}
      # Note, numbers will be encoded as JSON strings, but this is by design since
      # float values may introduce rounding issues
      result[key] = answer
      result[:rating] = rating if rating
      if loan_responses_i_frame_id.present?
        iframe = LoanResponsesIFrame.find_by!(id: loan_responses_i_frame_id)
        iframe.parse_legacy_display_data
        result[:url] = iframe.original_url
        result[:start_cell] = iframe.start_cell if iframe.start_cell.present?
        result[:end_cell] = iframe.end_cell if iframe.end_cell.present?
      end

      # Generate HTML for long text answers
      result[:text] = simple_format(result[:text]) if question.data_type == "text"

      puts "LoanResponse #{id} value hash:"
      pp result
      result
    end
  end
end

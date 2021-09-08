# -*- SkipSchemaAnnotations
module Legacy

  class LoanResponse < ApplicationRecord
    establish_connection :legacy
    include LegacyModel

    def question
      LoanQuestion.where(id: question_id).first
    end

    def value_hash
      key = question.try(:data_type) == 'number' ? :number : :text
      result = {}
      # Note, numbers will be encoded as JSON strings, but this is by design since
      # float values may introduce rounding issues
      result[key] = answer

      # if question.try(:data_type) == 'number'
      #   result[:number] = answer.to_d
      # end

      result[:rating] = rating  if rating
      if loan_responses_i_frame_id
        iframe = LoanResponsesIFrame.find_by(id: loan_responses_i_frame_id)
        if iframe
          iframe.parse_legacy_display_data
          result[:url] = iframe.original_url
          result[:start_cell] = iframe.start_cell if iframe.start_cell.present?
          result[:end_cell] = iframe.end_cell if iframe.end_cell.present?
        else
          $stderr.puts "warning, dangling response iframe ref: #{loan_responses_i_frame_id} by loan response: #{id}"
        end
      end
      result
    end

  end

end

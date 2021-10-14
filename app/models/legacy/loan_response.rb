# -*- SkipSchemaAnnotations
module Legacy
  class LoanResponse < ApplicationRecord
    establish_connection :legacy
    include LegacyModel
    include ActionView::Helpers::TextHelper

    SPAM_URLS = %w(
      http://autoinsuranceonet.info/average
      http://autoinsuranceonet.info/buy
      http://autoinsurancerater.info/a
      http://autoinsurancexv.info/auto
      http://autoinsurancexv.info/autoinsurancequotesfornewdrivers.html
      http://autoinsurancexv.info/autoinsurancequotesfornewdrivers.html
      http://bigskilletlive.com/augmentin/
      http://carinsurancequoteson.info/aaa
      http://casinogamblingbest.space/
      http://cheapinsurancenerd.org/cheap
      http://detroitcoralfarms.com/canadian
      http://gladscricket.com/CA/Concord/auto
      http://gladscricket.com/MT/Billings/cheapest
      http://gladscricket.com/NH/Concord/car
      http://kullutourism.com/propranolol/
      http://nauseainthemorning.ml/little
      http://theyogabodyoceanside.com/WV/Wheeling/non
      http://ussportsnews.net/NJ/Camden/car
      http://webodtechnologies.com/cialis/
      http://wonderlandinc.org/AR/Jonesboro/free
      http://wonderlandinc.org/IN/Brownsburg/cheapest
      http://www.LnAJ7K8QSpfMO2wQ8gO.com
      https://canadianpharmacyntv.com/
      https://canadianpharmacyopen.com/
      https://cbd
      https://cbdhempoiltrust.com/
      https://ciaonlinebuyntx.com/
      https://goldentabs.com/
      https://momshealthadvice.com/kamagra/
      https://safeonlinecanadian.com/
      https://trustedwebpharmacy.com/
      https://viagradjango.com/
      https://viagradocker.com/
      https://viagrapython.com/
    )

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
      result[:text] = simple_format(result[:text]).to_str if question.data_type == "text"
      result
    end
  end
end

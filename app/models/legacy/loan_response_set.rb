# -*- SkipSchemaAnnotations
module Legacy
  class LoanResponseSet < ApplicationRecord
    establish_connection :legacy
    include LegacyModel

    DUPE_DIVIDER = "<br/><br/>------------------------------------------------------------<br/><br/>"

    attr_accessor :new_response_sets

    def self.migratable
      # ResponseSetID == 1 seems to be all spam and all sets with this ID map to loan #1
      where.not(response_set_id: 1)
    end

    def migrate
      unless loan
        Migration.log << ["LoanResponseSet", id, "Could not find Madeline Loan with ID #{loan_id}, skipping"]
        return
      end
      self.new_response_sets = {}
      build_new_response_sets
      combine_duplicates
      new_response_sets.values.each(&:save!)
    end

    private

    def build_new_response_sets
      # Note, a given response ID can be mapped to multiple loans. This is why we match LoanResponse
      # on ResponseSetID instead of just ID.
      responses = LoanResponse.where("ResponseSetID = ?", response_set_id)
      responses.each do |response|
        unless (response.question.present?)
          Migration.log << ["LoanResponse", response.id, "Could not find legacy LoanQuestion with "\
                                                         "id #{response.question_id}, skipping"]
          next
        end
        unless (new_question = Question.find_by(legacy_id: response.question_id))
          Migration.log << ["LoanResponse", response.id, "Could not find Madeline Question with "\
                                                         "legacy_id #{response.question_id}, skipping"]
          next
        end
        question_set = new_question.question_set
        new_response_sets[question_set] ||= ResponseSet.new(question_set: question_set, loan: loan,
                                                            custom_data: {}, legacy_id: id)

        add_value_hash(new_response_sets[question_set], new_question, response)
      end
    end

    def add_value_hash(new_resonse_set, new_question, response)
      value_hash = response.value_hash
      if LoanResponse::SPAM_URLS.any? { |url| response.answer.include?(url) }
        Migration.skipped_spam_response_count += 1
      elsif (existing = new_resonse_set.custom_data[new_question.id.to_s])
        if existing.include?(value_hash)
          Migration.skipped_identical_response_count += 1
        else
          existing << value_hash
        end
      else
        puts "LoanResponse #{response.id} value hash:"
        pp value_hash
        new_resonse_set.custom_data[new_question.id.to_s] = [value_hash]
      end
    end

    def combine_duplicates
      new_response_sets.values.each do |response_set|
        response_set.custom_data.each do |key, hashes|
          response_set.custom_data[key] =
            if hashes.size == 1
              hashes[0]
            else
              # There shouldn't be multiple hashes with certain keys.
              if (hashes.flat_map(&:keys).uniq - [:rating, :text, :url, :start_cell, :end_cell]).any?
                pp hashes.flat_map(&:keys).uniq
                raise "Duplicate answers with unexpected keys found for loan #{loan_id} and "\
                  "response set ID #{response_set_id}"
                {}
              else
                combined = {}
                text = hashes.map { |h| h[:text] }.join(DUPE_DIVIDER)
                rating = hashes.map { |h| h[:rating] }.compact.max
                url = hashes.map { |h| h[:url] }.compact.first
                start_cell = hashes.map { |h| h[:start_cell] }.compact.first
                end_cell = hashes.map { |h| h[:end_cell] }.compact.first
                combined[:text] = text
                combined[:rating] = rating if rating.present?
                combined[:url] = url if url.present?
                combined[:start_cell] = start_cell if start_cell.present?
                combined[:end_cell] = end_cell if end_cell.present?
                puts "Combined duplicates for loan #{loan_id} and response set ID #{response_set_id}:"\
                  "\n#{combined}"
                combined
              end
            end
        end
      end
    end

    def loan
      @loan ||= ::Loan.find_by(id: loan_id)
    end
  end
end

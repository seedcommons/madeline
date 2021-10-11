module Legacy
  class Migration
    def self.log
      @log ||= []
    end

    def self.skipped_identical_response_count
      @skipped_identical_response_count ||= 0
    end

    def self.skipped_identical_response_count=(value)
      @skipped_identical_response_count = value
    end

    def self.unexpected_errors
      @unexpected_errors ||= []
    end
  end
end

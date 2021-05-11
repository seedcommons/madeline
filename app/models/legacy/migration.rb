module Legacy
  class Migration
    def self.log
      @log ||= []
    end

    def self.unexpected_errors
      @unexpected_errors ||= []
    end
  end
end

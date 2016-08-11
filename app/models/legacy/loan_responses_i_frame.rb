# -*- SkipSchemaAnnotations
module Legacy

  class LoanResponsesIFrame < ActiveRecord::Base
    establish_connection :legacy
    include LegacyModel

    attr_accessor :start_cell
    attr_accessor :end_cell

    # Extract start and end cells from generated display url
    def parse_legacy_display_data
      return unless url
      # This block of code matches the original PHP logic, but the implied functionality actually
      # appears broken for all but the first few records in the system, and all of the applied
      # display parameters are simply ignored.
      parsed = /(.*)&single=true&range=(.*)%3A(.*)&output=html&gid=(.*)/.match(url)
      raise "unable to parse sheet url: #{url}" unless parsed
      if parsed
        if parsed.size != 5
          raise "unexpected result size parsing sheet url: #{url}, size: #{parsed.size}"
        end
        if original_url.present?
          if parsed[1] != original_url
            raise "original_url mismatch - parsed: #{parsed[1]}, expected: #{original_url}}"
          end
        else
          # There are a handful of migrations records missing the 'original_url' value
          self.original_url = parsed[1]
        end
        # Capture and honor the cell range entered into the legacy system.
        # Should perhaps confirm with Brendan if that is desired, given that this functionality was
        # broken in the legacy system.
        self.start_cell = parsed[2]
        self.end_cell = parsed[3]
        # Beware the gid appended to the tail of the legacy system url is usually bogus and irrelevant
      end
      self
    end

  end

end

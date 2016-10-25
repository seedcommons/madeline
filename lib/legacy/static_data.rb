module Legacy

  class StaticData

    def self.populate
    end


    # useful to remove the above data so that it can be re-run in isolation
    def self.purge
      Country.destroy_all rescue nil
      Currency.destroy_all rescue nil
      OptionSet.destroy_all rescue nil
    end
  end
end

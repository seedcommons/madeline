class FactoryStruct < OpenStruct
  def as_json(options = {})
    @table.as_json(options)
  end
end

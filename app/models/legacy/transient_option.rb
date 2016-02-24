# -*- SkipSchemaAnnotations
class Legacy::TransientOption

  attr_accessor :value, :label

  def initialize(value, label)
    @value = value
    @label = label
  end

end

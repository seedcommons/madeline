# Represents multi-value loan criteria or post analysis questionnaire response.
# Currently a wrapper around CustomFieldAddable data, but should perhaps refactor and promote
# to a its own db table

class LoanResponse

  attr_accessor :custom_field
  attr_accessor :text
  attr_accessor :number
  attr_accessor :boolean
  attr_accessor :rating
  attr_accessor :url
  attr_accessor :start_cell
  attr_accessor :end_cell
  attr_accessor :owner

  def initialize(field, hash, owner)
    @hash = HashWithIndifferentAccess.new(hash || {})
    @custom_field = field
    @text = @hash[:text]
    @number = @hash[:number]
    @boolean = @hash[:boolean]
    @rating = @hash[:rating]
    @url = @hash[:url]
    @start_cell = @hash[:start_cell]
    @end_cell = @hash[:end_cell]
    @owner = owner
  end

  def model_name
    'LoanResponse'
  end

  def original_hash
    @hash.to_json
  end

  def hash_data
    result = {}
    field_attributes.each do |attr|
      result[attr] = self.send(:attr)
    end
    result
  end

  def linked_document
    if url.present?
      LinkedDocument.new(url, start_cell: start_cell, end_cell: end_cell)
    else
      nil
    end
  end

  def field_attributes
    @field_attributes ||= @custom_field.value_types
  end

  def has_text?
    field_attributes.include?(:text)
  end

  def has_number?
    field_attributes.include?(:number)
  end

  def has_rating?
    field_attributes.include?(:rating)
  end

  def has_linked_document?
    field_attributes.include?(:url)
  end

  def has_boolean?
    field_attributes.include?(:boolean)
  end

  def blank?
    text.blank? && number.blank? && rating.blank? && boolean.blank? && url.blank?
  end

  # Allows for one line string field to also be presented for 'rating' typed fields
  def text_form_field_type
    @custom_field.data_type == 'text' ? :text : :string
  end

end

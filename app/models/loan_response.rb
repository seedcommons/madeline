# Represents multi-value loan criteria or post analysis questionnaire response.
# Currently a wrapper around CustomFieldAddable data, but should perhaps refactor and promote
# to a its own db table

class LoanResponse

  attr_accessor :custom_field
  attr_accessor :text
  attr_accessor :number
  attr_accessor :rating
  attr_accessor :embeddable_media_id

  def initialize(field, hash)
    @hash = HashWithIndifferentAccess.new(hash || {})
    @custom_field = field
    @text = @hash[:text]
    @number = @hash[:number]
    @rating = @hash[:rating]
    @embeddable_media_id = @hash[:embeddable_media_id]
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

  def embeddable_media
    embeddable_media_id ? EmbeddableMedia.find(embeddable_media_id) : nil
  end

  def embeddable_media=(record)
    @embeddable_media_id = record.try(:id)
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

  def has_sheet?
    field_attributes.include?(:embeddable_media)
  end

  # Allows for one line string field to also be presented for 'rating' typed fields
  def text_form_field_type
    @custom_field.data_type == 'text' ? :text : :string
  end

end

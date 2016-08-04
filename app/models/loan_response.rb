# Represents multi-value loan criteria or post analysis questionnaire response.
# Currently a wrapper around CustomFieldAddable data, but should perhaps refactor and promote
# to a its own db table

class LoanResponse
  include ProgressCalculable

  attr_accessor :custom_field
  attr_accessor :custom_value_set
  attr_accessor :text
  attr_accessor :number
  attr_accessor :boolean
  attr_accessor :rating
  attr_accessor :embeddable_media_id

  delegate :group?, :required?, to: :custom_field

  def initialize(custom_field:, custom_value_set:, data:)
    data = (data || {}).with_indifferent_access
    @custom_field = custom_field
    @custom_value_set = custom_value_set
    @text = data[:text]
    @number = data[:number]
    @boolean = data[:boolean]
    @rating = data[:rating]
    @embeddable_media_id = data[:embeddable_media_id]
  end

  def model_name
    'LoanResponse'
  end

  def embeddable_media
    embeddable_media_id.present? ? EmbeddableMedia.find(embeddable_media_id) : nil
  end

  def embeddable_media=(record)
    @embeddable_media_id = record.try(:id)
  end

  def field_attributes
    @field_attributes ||= custom_field.value_types
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

  def has_boolean?
    field_attributes.include?(:boolean)
  end

  def blank?
    text.blank? && number.blank? && rating.blank? && boolean.blank? &&
      (embeddable_media.blank? || embeddable_media.url.blank?)
  end

  def answered?
    !blank?
  end

  # Allows for one line string field to also be presented for 'rating' typed fields
  def text_form_field_type
    custom_field.data_type == 'text' ? :text : :string
  end

  private

  # Gets child responses of this response by asking CustomValueSet.
  # Assumes CustomValueSet's implementation will be super fast (not hitting DB everytime), else
  # performance will be horrible in recursive methods.
  def children
    @children ||= custom_value_set.children_of(self)
  end
end

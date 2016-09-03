# == Schema Information
#
# Table name: loan_response_sets
#
#  created_at  :datetime         not null
#  custom_data :json
#  id          :integer          not null, primary key
#  kind        :string
#  loan_id     :integer          not null
#  updated_at  :datetime         not null
#
class LoanResponseSet < ActiveRecord::Base
  include CustomFieldAddable, ProgressCalculable

  belongs_to :loan

  validates :loan, presence: true

  delegate :division, :division=, to: :loan

  def custom_field_set
    CustomFieldSet.find_by(internal_name: "loan_#{kind}")
  end

  # Ducktype interface override of default LoanResponseSettable resolve logic.
  # Assumes linkable associated field set assigned when instance was created.
  # Allows leverage of rest of LoanResponseSettable implementation
  def resolve_custom_field_set(required: true)
    custom_field_set
  end

  # Fetches urls of all embeddable media in the whole custom value set
  def embedded_urls
    return [] if custom_data.blank?
    custom_data.values.map { |v| v["url"].presence }.compact
  end

  # Gets LoanResponses whose CustomFields are children of the CustomField of the given LoanResponse.
  # LoanResponseSet knows about response data, while CustomField knows about field hierarchy, so placing
  # this responsibility in LoanResponseSet seemed reasonable.
  # Uses the `kids` method in CustomField that reduces number of database calls.
  # Returns [] if no children found.
  def kids_of(response)
    parent = response.custom_field
    parent.kids.map { |f| custom_value(f) }
  end

  # Needed to satisfy the ProgressCalculable duck type.
  # A LoanResponseSet is never required to be fully answered. Requiredness is determined by children.
  def required?
    false
  end

  # Needed to satisfy the ProgressCalculable duck type.
  # A LoanResponseSet behaves as a group.
  def group?
    true
  end

  # Needed to satisfy the ProgressCalculable duck type.
  # A LoanResponseSet behaves as a group so can never be answered.
  def answered?
    false
  end

  # Needed to satisfy the ProgressCalculable duck type.
  # Returns the LoanResponses for the top level questions in the set.
  def kids
    top_level_fields = custom_field_set.kids
    top_level_fields.map { |f| custom_value(f) }
  end

  private

  def is_number?(object)
    true if Float(object) rescue false
  end

  def is_number_or_blank?(object)
    true if object.blank? || Float(object) rescue false
  end
end

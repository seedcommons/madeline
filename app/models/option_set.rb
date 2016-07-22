# == Schema Information
#
# Table name: option_sets
#
#  created_at      :datetime         not null
#  division_id     :integer          not null
#  id              :integer          not null, primary key
#  model_attribute :string
#  model_type      :string
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_option_sets_on_division_id  (division_id)
#
# Foreign Keys
#
#  fk_rails_1565c19047  (division_id => divisions.id)
#

class OptionSet < ActiveRecord::Base

  # beware, for now it is expected that all OptionSets are owned by the root division
  belongs_to :division

  has_many :options, -> { order(:position) }, dependent: :destroy

  validates :division_id, presence: true

  # future: support division specific versions of the option sets
  def self.fetch(clazz, attribute)
    result = self.find_by(model_type: clazz.name, model_attribute: attribute)
    # create root division owned instance on demand if not present
    unless result
      result = OptionSet.create(division: Division.root, model_type: clazz.name, model_attribute: attribute)
      Rails.logger.info "note, OptionSet not found for #{clazz.name}.#{attribute} - default instance auto created: #{result.id}"
    end
    result
  end

  # Returns a list of options suitable for input to `options_for_select`
  def translated_list
    options.map { |option| [option.label, option.value] }
  end

  def option_by_value(value)
    return nil unless value.present?
    options.find_by(value: value)
  end


  def translated_label_by_value(value)
    return nil unless value.present?
    option = option_by_value(value)
    unless option
      return "missing option label - value: #{value}"  if true  # make this non-fatal for now
      #todo: confirm if RuntimeException is appropriate or other convention to follow
      raise "OptionSet[#{model_type}.#{model_attribute}] - option value not found: #{value}"  unless option
      # fallback to use value as label if option record not found
      #todo: confirm if reasonable to allow value as default label
      # Rais.logger.info "OptionSet[#{model_type}.#{model_attribute}] - option value not found: #{value} - using value as default label"
      # return value
    end

    option.label
  end

  # list all values. useful for test specs
  def values
    options.map(&:value)
  end

  def value_for_migration_id(migration_id)
    options.find_by(migration_id: migration_id).try(:value)
  end
end

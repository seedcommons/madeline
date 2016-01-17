# == Schema Information
#
# Table name: option_sets
#
#  id              :integer          not null, primary key
#  division_id     :integer          not null
#  model_type      :string
#  model_attribute :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_option_sets_on_division_id  (division_id)
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



  def translated_list(language_code=nil)
    options.map{ |option| { value: option.value, label: option.get_label(language_code) } }
  end


  def translated_label_by_value(value, language_code=nil)
    return nil  unless value
    option = options.find_by(value: value)
    unless option
      #todo: confirm if RuntimeException is appropriate or other convention to follow
      raise "OptionSet[#{model_type}.#{model_attribute}] - option value not found: #{value}"  unless option
      # fallback to use value as label if option record not found
      #todo: confirm if reasonable to allow value as default label
      # Rais.logger.info "OptionSet[#{model_type}.#{model_attribute}] - option value not found: #{value} - using value as default label"
      # return value
    end

    option.get_label(language_code)
  end


  # list all values. useful for test specs
  def values
    options.map(&:value)
  end


  def value_for_migration_id(migration_id)
    options.find_by(migration_id: migration_id).try(:value)
  end


  def create_option(data)
    # assign default 'position' value of not explictly provided
    unless data[:position]
      max = options.maximum(:position)
      data[:position] = (max || 0) + 1
    end
    # todo, confirm which style is prefered, the clever one-liner below, or multi-line with debuggable intermediary state above
    # data[:position] = (options.maximum(:position) || 0) + 1  unless data[:position]

    option = options.create(data)
    # if 'value' not explicitly provided, then default to primary key
    option.update(value: option.id)  unless data[:value]
    option
  end


end


#UNUSED
# not sure yet if these optimizations will be useful. will remove the dead code before final release if not
# #
# # Note, conceptually this data is static configuration data persisted to the database,
# # so fairly agressive caching is appropriate.
# # These instance objects are cached at the OptionSettable including class level.
# #
# def reset_cache
#   @cached_options = nil
#   @translated_option_lists = nil
#   @translated_option_maps = nil
# end
#
# def cached_options
#   @cached_options ||= options
# end
#
#
# def translated_option_lists
#   @translated_option_lists ||= Hash.new do |h, language_code|
#     list = cached_options.map{ |option| { value: option.value, label: option.get_label(language_code) } }
#     h[language_code] = list
#   end
# end
#
# def translated_option_maps
#   @translated_option_maps ||= Hash.new do |h, language_code|
#     map = {}
#     cached_options.each { |option| map[option.value] = option.get_label(language_code) }
#     h[language_code] = map
#   end
# end
#
#
# def translated_list(language_code=nil)
#   # translated_option_lists[language_code]
#   list = cached_options.map do |option|
#     # puts("option - label_list: #{option.label_list}")
#     { value: option.value, label: option.get_label(language_code) }
#   end
#   list
# end
#
# def translated_label(value, language_code=nil)
#   # translated_option_maps[language_code][value]
#   map = {}
#   cached_options.each { |option| map[option.value] = option.get_label(language_code) }
#   map[value]
# end
#
#
# # list all values. useful for test specs
# def values
#   cached_options.map(&:value)
# end
#
# # returns value associated with given value - useful for test specs
# def value_for_label(label)
#   translated_list.select{ |_| _[:label] == label }.first[:value]
# end
#




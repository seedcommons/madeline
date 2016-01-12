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

  has_many :options, -> { order(:position) }


  validates :division_id, presence: true


  # future: support division specific versions of the option sets
  def self.fetch(clazz, attribute)
    self.find_by(model_type: clazz.name, model_attribute: attribute)
  end


  def translated_list(language_code=nil)
    options.map{ |option| { value: option.value, label: option.get_label(language_code) } }
  end


  def translated_label(value, language_code=nil)
    option = options.find_by(value: value)
    #todo: confirm if RuntimeException is appropriate or other convention to follow
    raise "OptionSet[#{model_type}.#{model_attribute}] - option value not found: #{value}"  unless option
    option.get_label(language_code)
  end


  # list all values. useful for test specs
  def values
    options.map(&:value)
  end


  # returns value associated with given value - useful for test specs
  def value_for_label(label)
    translated_list.select{ |_| _[:label] == label }.first[:value]
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




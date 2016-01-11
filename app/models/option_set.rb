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


  belongs_to :division
  has_many :options, -> { order(:position) }


  validates :division_id, presence: true


  def self.fetch(clazz, attribute)
    self.find_by(model_type: clazz.name, model_attribute: attribute)
  end


  def reset_cache
    @cached_options = nil
    @translated_option_lists = nil
    @translated_option_maps = nil
  end

  def cached_options
    @cached_options ||= options
  end


  def translated_option_lists
    @translated_option_lists ||= Hash.new do |h, language_code|
      list = cached_options.map{ |option| { value: option.value, label: option.get_label(language_code) } }
      h[language_code] = list
    end
  end

  def translated_option_maps
    @translated_option_maps ||= Hash.new do |h, language_code|
      map = {}
      cached_options.each { |option| map[option.value] = option.get_label(language_code) }
      h[language_code] = map
    end
  end


  def translated_list(language_code=nil)
    translated_option_lists[language_code]
  end

  def translated_label(value, language_code=nil)
    translated_option_maps[language_code][value]
  end


  # list all values. useful for test specs
  def values
    cached_options.map(&:value)
  end

  # returns value associated with given value - useful for test specs
  def value_for_label(label)
    translated_list.select{ |_| _[:label] == label }.first[:value]
  end


end

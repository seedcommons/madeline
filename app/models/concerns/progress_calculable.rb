# Methods for calculating progress towards completion of LoanResponseSets.
# Assumes including classes implement required?, :group?, :answered?, and children.
module ProgressCalculable
  extend ActiveSupport::Concern

  def progress
    @progress ||= if progress_denominator == 0
      0
    else
      progress_numerator.to_f / progress_denominator.to_f
    end
  end

  protected

  # If this is a required node, the numerator is the number of answered, required child questions,
  # plus the numerators of any child groups.
  # If this is an optional node, the numerator is just the number of answered child questions,
  # plus the numerators of any child groups.
  def progress_numerator
    return @progress_numerator if @progress_numerator
    properties = {answered: true, group: false}
    properties[:required] = true if required?
    @progress_numerator = children.sum do |child|
      (child.has_properties?(properties) ? 1 : 0) + child.progress_numerator
    end
  end

  # If this is a required node, the denominator is the number of required child questions,
  # plus the denominators of any child groups.
  # If this is an optional node, the denominator is just the total number of child questions,
  # plus the denominators of any child groups.
  def progress_denominator
    return @progress_denominator if @progress_denominator
    properties = {group: false}
    properties[:required] = true if required?

    @progress_denominator = children.sum do |child|
      (child.has_properties?(properties) ? 1 : 0) + child.progress_denominator
    end
  end

  def has_properties?(properties)
    # If any of the following boolean expressions is true, we must return false.
    tests = [
      properties.has_key?(:required) && properties[:required] != required?,
      properties.has_key?(:answered) && properties[:answered] != answered?,
      properties.has_key?(:group) && properties[:group] != group?
    ]
    !tests.any? { |t| t }
  end
end

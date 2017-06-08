# Methods for calculating progress towards completion of LoanResponseSets.
# Assumes including classes implement :required?, :group?, :answered?, and :children.
module ProgressCalculable
  extend ActiveSupport::Concern

  def progress
    @progress ||= if progress_denominator == 0
      0
    else
      progress_numerator.to_f / progress_denominator.to_f
    end
  end

  def progress_pct
    @progress_pct ||= (progress * 100).round
  end

  def progress_type
    required? ? "normal" : "optional"
  end

  # Inactive questions only show when they are answered, and they are never required, so
  # progress makes no sense. Retired questions should never show, so they should be excluded as
  # well.
  def active_children
    children.select(&:active?)
  end

  protected

  # If this is a required node, the numerator is the number of answered, required child questions,
  # plus the numerators of any required child groups.
  # If this is an optional node, the numerator is just the number of answered child questions,
  # plus the numerators of any child groups.
  def progress_numerator
    return @progress_numerator if @progress_numerator
    properties = {answered: true, group: false}
    applicable_children = required? ? active_children.select(&:required?) : active_children

    @progress_numerator = applicable_children.sum do |c|
      (c.has_properties?(properties) ? 1 : 0) + c.progress_numerator
    end
  end

  # If this is a required node, the denominator is the number of required child questions,
  # plus the denominators of any required child groups.
  # If this is an optional node, the denominator is just the total number of child questions,
  # plus the denominators of any child groups.
  def progress_denominator
    return @progress_denominator if @progress_denominator
    properties = {group: false}
    applicable_children = required? ? active_children.select(&:required?) : active_children

    @progress_denominator = applicable_children.sum do |c|
      (c.has_properties?(properties) ? 1 : 0) + c.progress_denominator
    end
  end

  def has_properties?(properties)
    # If any of the following boolean expressions is true, we must return false.
    tests = [
      properties.has_key?(:required) && properties[:required] != required?,
      properties.has_key?(:answered) && properties[:answered] != answered?,
      properties.has_key?(:group) && properties[:group] != group?,
      properties.has_key?(:active) && properties[:active] != active?
    ]
    !tests.any? { |t| t }
  end
end

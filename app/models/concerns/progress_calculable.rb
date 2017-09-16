# Methods for calculating progress towards completion of LoanResponseSets.
# Assumes including classes implement :required?, :group?, :answered?, :active?, and :children.
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

  protected

  # If this is a required node, the numerator is the number of answered, required child questions,
  # plus the numerators of any required child groups.
  # If this is an optional node, the numerator is just the number of answered child questions,
  # plus the numerators of any child groups.
  def progress_numerator
    return @progress_numerator if @progress_numerator
    return @progress_numerator = 0 unless active?

    @progress_numerator = progress_applicable_children.sum do |c|
      (c.answered? && !c.group? ? 1 : 0) + c.progress_numerator
    end
  end

  # If this is a required node, the denominator is the number of required child questions,
  # plus the denominators of any required child groups.
  # If this is an optional node, the denominator is just the total number of child questions,
  # plus the denominators of any child groups.
  def progress_denominator
    return @progress_denominator if @progress_denominator
    return @progress_denominator = 0 unless active?

    @progress_denominator = progress_applicable_children.sum do |c|
      (!c.group? ? 1 : 0) + c.progress_denominator
    end
  end

  # Inactive and retired questions should be ignored. Inactive questions only show when they are
  # answered, and they are never required, so progress makes no sense. Retired questions should
  # never show, so they should be excluded as well.
  # If the current response is required, only count children that are also required.
  def progress_applicable_children
    children.select do |c|
      if self.required?
        c.active? && c.required?
      else
        c.active?
      end
    end
  end
end

# Methods for calculating progress towards completion of ResponseSets.
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
end

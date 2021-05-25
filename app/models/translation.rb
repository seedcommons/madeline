class Translation < ApplicationRecord
  belongs_to :translatable, polymorphic: true

  delegate :division, :division=, to: :translatable

  def blank?
    text.blank?
  end

  def to_s
    text
  end

  def empty?
    text.empty?
  end

  def strip
    text
  end

  def <=>(other)
    self.text <=> other.text
  end
end

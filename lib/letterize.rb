module Letterize
  LETTER_MAP = ('A'..'Z').to_a

  refine Integer do
    def letterize
      return "0" if self == 0
      multiplier = (self / 27) + 1
      letter = (self % 26) - 1

      return LETTER_MAP[letter] * multiplier
    end
  end
end

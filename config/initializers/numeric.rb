class Numeric
  def partition(n)
    array = []
    value = self
    (n-1).times do
      portion = rand(1..value/n).round(2)
      value -= portion
      array << portion
    end
    array << (self - array.sum).round(2)
    raise unless (array.sum.round(2) == self)
    return array.shuffle
  end
end

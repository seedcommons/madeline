module GeneralSpecHelpers
  def equal_money(amount)
    be_within(0.0001).of(amount)
  end
end

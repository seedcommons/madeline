module GeneralSpecHelpers
  def equal_money(amount)
    be_within(0.0001).of(amount)
  end

  # assigns ENV vars
  def with_env(vars)
    old = vars.map { |k, _| [k, ENV[k]] }.to_h
    vars.each_pair { |k, v| ENV[k] = v }
    yield
  ensure
    vars.each_pair do |k, _|
      if old[k].nil?
        ENV.delete(k)
      else
        ENV[k] = old[k]
      end
    end
  end
end

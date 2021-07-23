# frozen_string_literals: true

RSpec::Matchers.define(:have_errors) do |errors|
  match do |object|
    object.invalid? && errors.all? do |field, pattern|
      pattern.nil? ? object.errors[field].empty? : object.errors[field].join.match?(pattern)
    end
  end
  failure_message do |object|
    if object.valid?
      "expected object to be invalid but it was valid"
    else
      failing = errors.detect { |f, p| !object.errors[f].join.match?(p) }
      "expected errors on #{failing[0]} to match #{failing[1].inspect} "\
        "but was #{object.errors[failing[0]].inspect}"
    end
  end
end

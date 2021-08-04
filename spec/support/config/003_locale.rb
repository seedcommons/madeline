# frozen_string_literal: true

RSpec.configure do |config|
  config.around(:each, with_spanish_locale: true) do |example|
    # Tried to achieve this by setting locale on chromedriver. As of 2021-07-09, this was working
    # on my Mac but not on Ubuntu 20.04 on CI. Might be worth trying again later.
    with_env("STUB_LOCALE" => "es") do
      example.run
    end
  end
end

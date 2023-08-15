# frozen_string_literal: true

RSpec.configure do |config|
  Capybara.register_driver(:selenium_chrome_headless) do |app|
    args = %w(disable-gpu no-sandbox headless disable-site-isolation-trials window-size=1280x2048)
    options = Selenium::WebDriver::Chrome::Options.new(
      args: args,
      "goog:loggingPrefs": {browser: "ALL", client: "ALL", driver: "ALL", server: "ALL"},
    )
    options.add_preference(:download, prompt_for_download: false,
                                      default_directory: DownloadHelpers::PATH.to_s)
    options.add_preference(:browser, set_download_behavior: {behavior: "allow"})
    Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
  end

  config.before(:each, type: :system) do
    driven_by :rack_test
  end

  config.before(:each, type: :system, js: true) do
    driven_by :selenium_chrome_headless
  end
end

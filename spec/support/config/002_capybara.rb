# frozen_string_literal: true

RSpec.configure do |config|
  Capybara.register_driver(:selenium_chrome_headless_en) do |app|
    register_driver(app, "en")
  end

  Capybara.register_driver(:selenium_chrome_headless_es) do |app|
    register_driver(app, "es")
  end

  config.before(:each, type: :system) do
    driven_by :rack_test
  end

  config.before(:each, type: :system, js: true) do |example|
    if example.metadata[:with_spanish_browser]
      driven_by :selenium_chrome_headless_es
    else
      driven_by :selenium_chrome_headless_en
    end
  end

  def register_driver(app, language)
    args = %w(disable-gpu no-sandbox headless disable-site-isolation-trials window-size=1280x2048)
    args << "lang=#{language}"
    options = Selenium::WebDriver::Chrome::Options.new(
      args: args,
      loggingPrefs: {browser: "ALL", client: "ALL", driver: "ALL", server: "ALL"}
    )
    options.add_preference(:download, prompt_for_download: false,
                                      default_directory: DownloadHelpers::PATH.to_s)
    options.add_preference(:browser, set_download_behavior: {behavior: "allow"})
    options.add_preference("intl.accept_languages", language)
    Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
  end
end

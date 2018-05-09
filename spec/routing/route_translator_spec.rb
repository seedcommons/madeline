require 'rails_helper'

describe RouteTranslator do
  it "should route US test page correctly" do
    expect(get "/us/test").to route_to(
      controller: "public/static_pages",
      action: "test",
      locale: "en",
      site: "us",
    )
  end

  it "should route Argentina test page correctly" do
    expect(get "/argentina/prueba").to route_to(
      controller: "public/static_pages",
      action: "test",
      locale: "es",
      site: "argentina",
    )
  end

  it "should route Nicaragua test page correctly" do
    expect(get "/nicaragua/prueba").to route_to(
      controller: "public/static_pages",
      action: "test",
      locale: "es",
      site: "nicaragua",
    )
  end
end

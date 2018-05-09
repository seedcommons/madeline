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

  it "should route US loans page correctly" do
    expect(get "/us/loans").to route_to(
      controller: "public/loans",
      action: "index",
      locale: "en",
      site: "us",
    )
  end

  it "should route Nicaragua loans page correctly" do
    expect(get "/nicaragua/prestamos").to route_to(
      controller: "public/loans",
      action: "index",
      locale: "es",
      site: "nicaragua",
    )
  end

  it "should route Nicaragua gallery page correctly" do
    expect(get "/nicaragua/prestamos/123/galeria").to route_to(
      controller: "public/loans",
      action: "gallery",
      locale: "es",
      site: "nicaragua",
      id: "123",
    )
  end

end

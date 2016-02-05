class StaticPagesController < ApplicationController
  include WordpressEmbeddable

  def test
    render inline: "<% provide :title, 'Test' %><h1>Test Successful</h1>", layout: 'application'
  end
end

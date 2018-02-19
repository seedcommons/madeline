class Public::StaticPagesController < Public::PublicController
  include WordpressEmbeddable

  def test
    render inline: "<% provide :title, 'Test' %><h1>Test Successful</h1>"
  end
end

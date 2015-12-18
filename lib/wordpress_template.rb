module WordpressTemplate
  def self.update(division)
    template_url = Rails.configuration.wordpress_template[:template_urls][division]
    file = File.join(Rails.root, 'app', 'views', 'layouts', "wordpress-#{division}.html.erb")
    additional_substitutions = [
      [/<div class="post-content">(.*?)<p>(.*?)<\/p>(.*?)<\/div>/m, '\1\2\3'],
      ['<div class="article-single">', '<div>'],
    ]

    require 'open-uri'
    html = URI.parse(template_url).read
    html.gsub!(
      /(<!--\s*)?\[rails_(?<section>[\w\-]+?)\](.*\[\/rails_\k<section>\])?(\s*-->)?/m,
      '<%= yield :\k<section> %>'
    )
    additional_substitutions.each { |sub| html.gsub! *sub }
    File.open(file, 'w') { |f| f.write(html) }
  end
end

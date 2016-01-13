module WordpressTemplate
  def self.update(division:, base_uri:)
    if Rails.env.development? || Rails.env.test?
      html = File.read(Rails.root.join('spec', 'fixtures', 'wordpress-rails.html'))
    else
      html = self.fetch_template(division: division, base_uri: base_uri)
    end
    self.process_template(division: division, html: html)
  end

  def self.fetch_template(division:, base_uri:)
    require 'open-uri'
    template_path = Rails.configuration.x.wordpress_template[:template_paths][division]
    template_url = [base_uri, template_path].join
    html = URI.parse(template_url).read
  end

  def self.process_template(division:, html:)
    file = Rails.root.join('app', 'views', 'layouts', 'embedded', "wordpress-#{division}.html.erb")
    FileUtils.mkpath file.dirname
    
    additional_substitutions = [
      [/<div class="post-content">(.*?)<p>(.*?)<\/p>(.*?)<\/div>/m, '\1\2\3'],
      ['<div class="article-single">', '<div>'],
    ]
    html.gsub!(
      /(<!--\s*)?\[rails_(?<section>[\w\-]+?)\](.*\[\/rails_\k<section>\])?(\s*-->)?/m,
      '<%= yield :\k<section> %>'
    )
    additional_substitutions.each { |sub| html.gsub! *sub }
    File.open(file, 'w') { |f| f.write(html) }
  end
end

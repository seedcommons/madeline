module WordpressTemplate
  def self.update(division:)
    if Rails.env.test?
      html = File.read(Rails.root.join('spec', 'fixtures', 'wordpress-rails.html'))
    else
      base_uri = Rails.configuration.x.wordpress_template[:base_uri][division]
      html = self.fetch_template(division: division, base_uri: base_uri)
    end
    self.process_template(division: division, html: html)
  end

  def self.fetch_template(division:, base_uri:)
    require 'open-uri'
    template_path = Rails.configuration.x.wordpress_template[:template_paths][division.to_sym]
    template_url = [base_uri, template_path].join
    html = URI.parse(template_url).read
  end

  def self.process_template(division:, html:)
    file_path = Rails.root.join('app', 'views', 'layouts', 'public', 'wordpress', Rails.env)
    file = File.join(file_path, "wordpress-#{division}.html.erb")
    additional_substitutions = [
      [/<div class="post-content">(.*?)<p>(.*?)<\/p>(.*?)<\/div>/m, '\1\2\3'],
      ['<div class="article-single">', '<div>'],
    ]
    html.gsub!(
      /(<!--\s*)?\[rails_(?<section>[\w\-]+?)\](.*\[\/rails_\k<section>\])?(\s*-->)?/m,
      '<%= yield :\k<section> %>'
    )
    additional_substitutions.each { |sub| html.gsub! *sub }
    FileUtils.mkdir_p(file_path)
    File.open(file, 'w') { |f| f.write(html) }
  end
end

namespace :docs do
  desc 'document routes'
  task routes: :environment do
    route_file = Rails.root.join('docs', 'routes.txt')
    FileUtils.mkpath route_file.dirname
    route_file = File.open(route_file, 'w+')
    route_file << `bundle exec rake routes`
  end
end

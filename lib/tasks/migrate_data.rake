namespace :tww do

  desc "migrate TWW data from legacy mysql to new postgres db"
  task :migrate_all => :environment do
    Legacy::Migration.migrate_all
  end

  desc "migrate the core TWW data (divisions, coops, members, loans) from legacy mysql to new postgres db (much quicker than the full migration)"
  task :migrate_core => :environment do
    Legacy::Migration.migrate_core
  end

  desc "migrate the rest of the data (after migrate_core is run)"
  task :migrate_secondary => :environment do
    Legacy::Migration.migrate_secondary
  end

  desc "migrate media records and files.  note: expects base source media folder to be defined by the LEGACY_MEDIA_BASE_PATH system environment variable (defaults to ../legacymedia)"
  task :migrate_media => :environment do
    Legacy::Migration.migrate_media
  end

  # note, this task isn't really needed.  generally better to just drop the db,
  # but has been useful when retesting partial migrations during development
  desc "purge target (postgres) data"
  task :purge_migrated => :environment do
    Legacy::Migration.purge_migrated
  end


end

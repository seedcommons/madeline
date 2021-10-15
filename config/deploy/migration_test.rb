set :branch, -> { "develop" }
set :rails_env, -> { "production" }
server 'madeline-migration-test.sassafras.coop', user: 'deploy', roles: %w{app db web}

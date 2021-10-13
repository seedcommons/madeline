set :branch, -> { "develop" }
server 'madeline-migration-test.sassafras.coop', user: 'deploy', roles: %w{app db web}

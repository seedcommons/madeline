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

  desc 'migrate legacy files from /tmp/madeline{documents/contracts}'
  task migrate_files: :environment do
    root_path = ENV['LEGACY_DOCUMENT_BASE_PATH'] || '/tmp/madeline'
    Document = Struct.new(:full_path, :file_name, :document_name, :loan_id, :document_kind)

    documents_path = File.join root_path, 'documents'
    documents = Dir.entries(documents_path)
      .reject { |f| File.directory?(f) || f[0].include?('.') }
      .map do |doc|
        arr = doc.split('.')
        Document.new(File.join(documents_path, doc), doc, arr[0], arr[1], :document)
      end

    contracts_path = File.join root_path, 'contracts'
    contracts = Dir.entries(contracts_path)
      .reject { |f| File.directory?(f) || f[0].include?('.') }
      .map do |doc|
        arr = doc.split('.')
        Document.new(File.join(contracts_path, doc), doc, arr[0], arr[1], :contract)
      end

    files = [documents, contracts]
      .flatten
      .each_with_object({}) do |media_file, hash|
        media_file.loan_id = media_file.loan_id.to_i
        arr = hash[media_file.loan_id] || []
        arr << media_file
        hash[media_file.loan_id] = arr
      end

    files.each do |key, value|
      begin
        loan = Loan.find key

        value.each do |file|
          uploaded_file_name = file.file_name.tr(' ', '_') # Carrierwave will replace spaces with underscores
          if loan.media.exists?(item: uploaded_file_name)
            print '*'
          else
            print '.'
            loan.media.create(item: File.open(file.full_path), kind_value: file.document_kind)
          end
        end
        loan.save!
      rescue ActiveRecord::RecordNotFound
        puts "\r\nCould not find loan #{key} for file #{value.first.file_name}"
      end
    end
  end

  desc "migrate some test data from quickbooks"
  task migrate_test_qbo: :environment do
    Accounting::Quickbooks::AccountFetcher.new.fetch
    Accounting::Quickbooks::TransactionFetcher.new.fetch

    Accounting::Transaction.update_all(accounting_account_id: nil, project_id: nil)

    accounts = Accounting::Account.all
    sample_loans = Loan.where(status_value: 'active').where.not(signing_date: nil).order(signing_date: :desc).limit(5)

    puts "Assigning transactions to loans (#{sample_loans.pluck(:id).join(' ')})"

    sample_loans.each do |loan|
      sample_transactions = Accounting::Transaction.all.sample(3)
      loan.transactions << sample_transactions
      loan.save!

      sample_transactions.each do |transaction|
        transaction.update!(account: accounts.sample)
      end
    end
  end

  desc "migrate some test data from quickbooks"
  task migrate_organizations_to_qbo: :environment do
    qb_connection = Division.root.qb_connection

    customers = Quickbooks::Service::Customer.new(qb_connection.auth_details).all

    customer_hash = {}
    customers.each do |customer|
      customer_hash[customer.display_name] = customer
    end

    Organization.all.find_each do |org|
      customer = customer_hash[org.name]

      if customer
        if org.qb_id.blank?
          puts "Mapping organization '#{org.name}' to #{customer.id}"
          org.update!(qb_id: customer.id)
        else
          if org.qb_id != customer.id
            puts "ERROR! Duplicate #{org.name} found, skipping"
            next
          end
          puts "Organization '#{org.name}' already mapped to #{org.qb_id}"
        end
      else
        begin
        puts "Creating new customer for organization '#{org.name}'"
        customer_ref = Accounting::Quickbooks::Customer.new(organization: org, qb_connection: qb_connection).reference
        puts "Created customer #{customer_ref.entity_ref.value}"
        rescue Quickbooks::InvalidModelException, Quickbooks::IntuitRequestException => ex
          puts ex.message
          puts "ERROR! Could not create #{org.name}, skipping"
        end
      end
    end
  end
end

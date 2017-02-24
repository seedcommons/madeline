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
  task :migrate_test_qbo => :environment do
  qb_connection = Division.root.qb_connection
  auth_details = { access_token: qb_connection.access_token, company_id: qb_connection.realm_id }

    %w(JournalEntry Deposit Purchase).each do |transaction_type|
      transactions = Quickbooks::Service.const_get(transaction_type).new(auth_details).query
      transactions.each do |t|
        Accounting::Transaction.find_or_create_by qb_transaction_type: transaction_type, qb_transaction_id: t.id
      end
    end
  end
end

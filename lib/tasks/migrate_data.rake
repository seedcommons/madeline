namespace :tww do

  desc "migrate TWW data from legacy mysql to new postgres db"
  task :migrate_legacy => :environment do

    Legacy::Division.migrate_all

    # puts {"divisions: #{Legacy::Division.count}"}
    # Legacy::Division.all.each &:migrate
    # Division.connection.execute("SELECT setval('divisions_id_seq', (SELECT MAX(id) FROM divisions)+1)")
    #
    # puts "cooperatives: #{ Legacy::Cooperative.count }"
    # Legacy::Cooperative.all.each &:migrate
    # Organization.connection.execute("SELECT setval('organizations_id_seq', (SELECT MAX(id) FROM organizations)+1000)")
    #
    # puts "members: #{ Legacy::Member.count }"
    # Legacy::Member.all.each &:migrate
    # Person.connection.execute("SELECT setval('people_id_seq', (SELECT MAX(id) FROM people)+1000)")
    #
    # puts "loans: #{Legacy::Loan.count}"
    # Legacy::Loan.all.each &:migrate
    # Loan.connection.execute("SELECT setval('loans_id_seq', (SELECT MAX(id) FROM loans)+1000)")
    #
    # puts "loan translations: #{ Legacy::Translation.where('RemoteTable' => 'Loans').count }"
    # Legacy::Translation.where('RemoteTable' => 'Loans').each &:migrate
    # # Translation.connection.execute("SELECT setval('translations_id_seq', (SELECT MAX(id) FROM translations))")
    #
    # puts "project steps: #{Legacy::ProjectEvent.count}"
    # # make sure to precalibrate our project steps sequence since we'll be needing to add some default project steps
    # # on the fly to handle the orphaned logs
    # max = Legacy::ProjectEvent.connection.execute("select max(id) from ProjectEvents").first.first
    # puts "setting projects_step_id_seq to: #{max+1000}"
    # ProjectStep.connection.execute("SELECT setval('project_steps_id_seq', #{max+1000})")
    #
    # # note record 10155 has a malformed date (2013-12-00) which was causing low level barfage
    # Legacy::ProjectEvent.where("Type = 'Paso' and #{malformed_date_clause('Completed')}").each &:migrate
    #
    # # note there will be a few unneeded translation records migrated, but not enough to worry about
    # puts "step translations: #{ Legacy::Translation.where('RemoteTable' => 'ProjectEvents').count }"
    # Legacy::Translation.where('RemoteTable' => 'ProjectEvents').each &:migrate
    # # Translation.connection.execute("SELECT setval('translations_id_seq', (SELECT MAX(id) FROM translations))")
    #
    # puts "project logs: #{Legacy::ProjectLog.where('ProjectTable' => 'loans').count}"
    # # note, there is one more record with a wacked out date (2005-01-00)
    # Legacy::ProjectLog.where("ProjectTable = 'loans' and ProjectId > 0 and #{malformed_date_clause('Date')}").each &:migrate
    # ProjectLog.connection.execute("SELECT setval('project_logs_id_seq', (SELECT MAX(id) FROM project_logs)+1000)")
    #
    # # note, there will be a notable number of unneeded translations from basic project logs, consider pruning somehow
    # puts "projectlog translations: #{ Legacy::Translation.where('RemoteTable' => 'ProjectLogs').count }"
    # Legacy::Translation.where("RemoteTable = 'ProjectLogs' and RemoteID > 0").each &:migrate
    # # Translation.connection.execute("SELECT setval('translations_id_seq', (SELECT MAX(id) FROM translations))")
    #
    # puts "notes logs: #{Legacy::Note.where('NotedTable' => 'Cooperatives').count}"
    # Legacy::Note.where('NotedTable' => 'Cooperatives').each &:migrate
    # Note.connection.execute("SELECT setval('notes_id_seq', (SELECT MAX(id) FROM notes)+1000)")

  end

  desc "scratch migration logic"
  task :scratch_migration => :environment do
    # puts "Note.delete_all"
    # Note.delete_all
    #
    # puts "notes logs: #{Legacy::Note.where('NotedTable' => 'Cooperatives').count}"
    # Legacy::Note.where('NotedTable' => 'Cooperatives').each &:migrate
    # Note.connection.execute("SELECT setval('notes_id_seq', (SELECT MAX(id) FROM notes)+1000)")

  end

  desc "purge target (postgres) data"
  task :purge_migrated => :environment do

    Legacy::Division.purge_migrated


    # # puts "Translation.where(translatable_type: 'Loan').delete_all"
    # # Translation.where(translatable_type: 'Loan').delete_all
    # puts "Translation.delete_all"
    # Translation.delete_all
    #
    # puts "Note.delete_all"
    # Note.delete_all
    #
    # puts "ProjectLog.delete_all"
    # ProjectLog.delete_all
    #
    # puts "ProjectStep.delete_all"
    # ProjectStep.delete_all
    #
    # puts "Loan.delete_all"
    # Loan.delete_all
    #
    # puts "Person.delete_all"
    # Person.delete_all
    #
    # puts "OrganizationSnapshot.delete_all"
    # OrganizationSnapshot.delete_all
    #
    # puts "Organization.delete_all"
    # Organization.delete_all
    #
    # puts "Madeline::Division.where('id <> 99').delete_all"
    # Division.where('id <> 99').delete_all  # note, destroy_all seems to be behaving erratically here via rake task

  end

  # def malformed_date_clause(field)
  #   " not (#{field} is not null and dayofmonth(#{field}) = 0 and month(#{field}) > 0)"
  # end


end

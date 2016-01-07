# -*- SkipSchemaAnnotations
module Legacy

class Loan < ActiveRecord::Base
  establish_connection :legacy
  include LegacyModel

  belongs_to :cooperative, :foreign_key => 'CooperativeID'


  # beware, there are a lot of invalid '0' foreign key refs in the legacy data
  def nil_if_zero(val)
    val == 0 ? nil : val
  end

  def migration_data
    data = {
        id: self.id,
        division_id: source_division,
        organization_id: nil_if_zero(cooperative_id),
        name: name,
        # handled directly via Translations table
        # summary: short_description.translated_content,
        # details: description.translated_content,
        primary_agent_id: nil_if_zero(point_person),
        secondary_agent_id: nil_if_zero(second),
        status_option_id: ::Loan::MIGRATION_STATUS_OPTIONS.value_for(nivel),
        loan_type_option_id: loan_type,
        project_type_option_id: ::Loan::PROJECT_TYPE_OPTIONS.value_for(project_type),
        public_level_option_id: ::Loan::PUBLIC_LEVEL_OPTIONS.value_for(nivel_publico),
        amount: amount,
        rate: rate,
        length_months: length,
        representative_id: nil_if_zero(representative_id),
        signing_date: signing_date,
        first_interest_payment_date: first_interest_payment,
        first_payment_date: first_payment_date,
        target_end_date: fecha_de_finalizacion,
        projected_return: projected_return,
        # organization_size: cooperative_members,
        # poc_ownership_percent: poc_ownership,
        # women_ownership_percent: women_ownership,
        # environmental_impact_score: environmental_impact
    }
    data
  end

  def org_snapshot_data
    data = {
        date: signing_date,
        organization_id: nil_if_zero(cooperative_id),
        organization_size: cooperative_members,
        poc_ownership_percent: poc_ownership,
        women_ownership_percent: women_ownership,
        environmental_impact_score: environmental_impact
    }
    data
  end

  def migrate
    data = migration_data
    puts "#{data[:id]}: #{data[:amount]}"
    org_data = org_snapshot_data
    snapshot = ::OrganizationSnapshot.create(org_data)
    data[:organization_snapshot_id] = snapshot.id
    ::Loan.create(data)
  end

  def name
    # if self.cooperative then I18n.t :project_with, name: self.cooperative.Name
    # else I18n.t :project_id, id: self.ID.to_s end
    if self.cooperative
      return "Project with #{self.cooperative.Name}"
    else
      return "Project ID: #{self.ID}"
    end
  end


  def self.migrate_all
    puts "loans: #{self.count}"
    self.all.each &:migrate
    ::Loan.connection.execute("SELECT setval('loans_id_seq', (SELECT MAX(id) FROM loans)+1000)")

    puts "loan translations: #{ Legacy::Translation.where('RemoteTable' => 'Loans').count }"
    Legacy::Translation.where('RemoteTable' => 'Loans').each &:migrate
  end

  def self.purge_migrated
    puts "::Loan.delete_all"
    ::Loan.delete_all
    puts "::OrganizationSnapshot.delete_all"
    ::OrganizationSnapshot.delete_all
  end



end

end

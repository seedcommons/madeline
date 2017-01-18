class ConditionsGeneratorAgentFilter < Wice::Columns::ConditionsGeneratorColumn
  def generate_conditions(_table_alias, search_string)
    comparator = 'people.name ILIKE ? OR secondary_agents_projects.name ILIKE ?'
    param = "%#{search_string}%"
    [comparator, param, param]
  end
end

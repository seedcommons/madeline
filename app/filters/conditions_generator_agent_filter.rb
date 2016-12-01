class ConditionsGeneratorAgentFilter < Wice::Columns::ConditionsGeneratorColumn
  def generate_conditions(_table_alias, search_string)
    comparator = 'people.name ILIKE ? OR secondary_agents_loans.name ILIKE ?'
    param = '%' + search_string + '%'
    val = [comparator, param, param]
    val
  end
end

class UpdateDivisionWithShortName < ActiveRecord::Migration[5.1]
  def change
    div_without_short_names = Division.where(short_name: nil)
    div_without_short_names.each do |division|
      division.short_name = division.name.parameterize
      division.save
    end
  end
end

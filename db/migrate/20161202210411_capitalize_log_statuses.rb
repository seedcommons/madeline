class Option < ActiveRecord::Base; end

class CapitalizeLogStatuses < ActiveRecord::Migration
  def change
    Option.find_by(migration_id: -3).update(label_translations: {en: 'In need of changing its whole plan', es: 'Con necesidad de cambiar su plan completamente'})
    Option.find_by(migration_id: -2).update(label_translations: {en: 'In need of changing some events', es: 'Con necesidad de cambiar algunos eventos'})
    Option.find_by(migration_id: -1).update(label_translations: {en: 'Behind', es: 'Atrasado'})
    Option.find_by(migration_id: 1).update(label_translations: {en: 'On time', es: 'A tiempo'})
    Option.find_by(migration_id: 2).update(label_translations: {en: 'Ahead', es: 'Adelantado'})
  end
end

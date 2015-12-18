FactoryGirl.define do
  factory :basic_project do
    description nil
    length { rand(1..365) }
    name "Sin Nombre"
    nivel { %w[Completo Cambiado Congelado Cancelado Activo].sample }
    short_description ""
    start_date { Faker::Date.between(Date.civil(2004, 01, 01), Date.today) }
    type { %w[Basic Continuo].sample }

    factory :basic_project_active do
      nivel "Activo"
    end
  end
end

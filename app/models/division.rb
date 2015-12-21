class Division < ActiveRecord::Base
  has_many :subdivisions, class_name: 'Division', foreign_key: 'SuperDivision'
  belongs_to :super_division, class_name: 'Division', foreign_key: 'SuperDivision'
end

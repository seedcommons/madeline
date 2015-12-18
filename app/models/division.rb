class Division < ActiveRecord::Base
  include Legacy
  remove_method :super_division

  has_many :subdivisions, class_name: 'Division', foreign_key: 'SuperDivision'
  belongs_to :super_division, class_name: 'Division', foreign_key: 'SuperDivision'
end

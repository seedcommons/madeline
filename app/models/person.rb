class Person < ActiveRecord::Base
  belongs_to :primary_organization, class_name: 'Organization'
end

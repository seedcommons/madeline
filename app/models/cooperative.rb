class Cooperative < ActiveRecord::Base
  include Legacy

  has_many :loans, :foreign_key => 'CooperativeID'

  def verbose_name
    @verbose_name ||= (self.name =~ /#{I18n.t :cooperative}/i) ? self.name : I18n.t(:cooperative_name, name: self.name)
  end
end

# == Schema Information
#
# Table name: currencies
#
#  id           :integer          not null, primary key
#  code         :string
#  symbol       :string
#  short_symbol :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  name         :string
#

class Currency < ActiveRecord::Base
  def division
    Division.root # for permissions purposes, assume country model belongs to root division
  end
end

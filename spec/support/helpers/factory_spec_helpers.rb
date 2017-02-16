module FactorySpecHelpers
  def create_member(division)
    create(:person, :with_member_access, :with_password, division: division).user
  end

  def create_admin(division)
    create(:person, :with_admin_access, :with_password, division: division).user
  end
end

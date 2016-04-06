class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    division_member_or_admin
  end

  def show?
    division_member_or_admin && scope.where(id: record.id).exists?
  end

  def create?
    division_member_or_admin
  end

  def new?
    create?
  end

  def update?
    division_member_or_admin
  end

  def edit?
    update?
  end

  def destroy?
    division_admin
  end

  def scope
    Pundit.policy_scope!(user, record.class)
  end

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      scope
    end
  end

  protected

  def division_member(division: @record.division)
    check_self_and_ancestors_for_role(role: :member, division: division)
  end

  def division_admin(division: @record.division)
    check_self_and_ancestors_for_role(role: :admin, division: division)
  end

  def division_member_or_admin(division: @record.division)
    division_member(division: division) || division_admin(division: division)
  end

  def check_self_and_ancestors_for_role(role:, division: @record.division)
    division_and_ancestors = division.self_and_ancestors

    division_and_ancestors.each do |div|
      return true if @user.has_role? role, div
    end

    false
  end
end

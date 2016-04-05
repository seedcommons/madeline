class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    false
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

  def division_member
    @user.has_role? :member, @record.division
  end

  def division_admin
    @user.has_role? :admin, @record.division
  end

  def division_member_or_admin
    division_member || division_admin
  end
end

class MetadataNamespacePolicy < ApplicationPolicy
  def index?
    User.valid_user?(@user) && (@user.has_role?(:administrator))
  end

  def show?
    User.valid_user?(@user) && (@user.has_role?(:administrator))
  end

  def edit?
    update?
  end

  def update?
    User.valid_user?(@user) && (@user.has_role?(:administrator))
  end

  def new?
    create?
  end

  def create?
    User.valid_user?(@user) && (@user.has_role?(:administrator))
  end

  def destroy?
    User.valid_user?(@user) && (@user.has_role?(:administrator))
  end

end

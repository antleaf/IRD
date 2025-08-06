class BatchPolicy < ApplicationPolicy

  def index?
    User.valid_user?(@user) && @user.has_role?(:administrator)
  end

  def create?
    User.valid_user?(@user) && @user.has_role?(:administrator)
  end

  def new?
    User.valid_user?(@user) && @user.has_role?(:administrator)
  end

  def update?
    User.valid_user?(@user) && @user.has_role?(:administrator)
  end

  def edit?
    User.valid_user?(@user) && @user.has_role?(:administrator)
  end

  def destroy?
    User.valid_user?(@user) && @user.has_role?(:administrator)
  end

  def show?
    User.valid_user?(@user) && @user.has_role?(:administrator)
  end

  def generate_csv_for_download?
    User.valid_user?(@user) && @user.has_role?(:administrator)
  end

  def download_csv?
    User.valid_user?(@user) && @user.has_role?(:administrator)
  end

end

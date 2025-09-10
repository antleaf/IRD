class SystemPolicy < ApplicationPolicy

  def show?
    @record.publicly_viewable? || (User.valid_user?(@user) && (@user.has_role?(:administrator) || @user.has_role?(:superuser) || @user.can_curate?(@record)))
  end

  def suggest_new_system?
    User.valid_user?(@user)
  end

  def admin?
    User.valid_user?(@user) && @user.has_role?(:administrator) && !@record.is_locked?
  end

  def process_as_duplicate?
    User.valid_user?(@user) && @user.has_role?(:administrator) && !@record.is_locked?
  end

  def label?
    User.valid_user?(@user) && @user.has_role?(:administrator) && !@record.is_locked?
  end

  def tag?
    User.valid_user?(@user) && (@user.has_role?(:administrator) || @user.has_role?(:superuser)) && !@record.is_locked?
  end

  def set_record_verified?
    User.valid_user?(@user) && (@user.has_role?(:administrator) || @user.has_role?(:superuser) || @user.is_responsible_for?(@record)) && !@record.is_locked?
  end

  def set_record_archived?
    # User.valid_user?(@user) && (@user.has_role?(:administrator) || @user.has_role?(:superuser)) && !@record.is_locked?
    User.valid_user?(@user) && (@user.has_role?(:administrator) || @user.has_role?(:superuser) || @user.can_curate?(@record)) && !@record.is_locked?
  end

  def set_record_draft?
    User.valid_user?(@user) && @user.has_role?(:administrator) && !@record.is_locked?
  end

  def set_record_awaiting_review?
    User.valid_user?(@user) && @user.has_role?(:administrator) && !@record.is_locked?
  end

  def set_record_under_review?
    User.valid_user?(@user) && (@user.has_role?(:administrator) || @user.has_role?(:superuser) || @user.can_curate?(@record)) && !@record.is_locked?
  end

  def add_repo_id?
    User.valid_user?(@user) && @user.has_role?(:administrator) && !@record.is_locked?
  end

  def search?
    User.valid_user?(@user) && @user.has_role?(:administrator)
  end

  def network_check?
    User.valid_user?(@user) && @user.has_role?(:administrator) && !@record.is_locked?
  end

  def auto_curate?
    User.valid_user?(@user) && @user.has_role?(:administrator) && !@record.is_locked?
  end

  def check_url?
    User.valid_user?(@user) && @user.has_role?(:administrator) && !@record.is_locked?
  end

  def check_oai_pmh_identify?
    curate?
  end

  def check_oai_pmh_formats?
    curate?
  end

  def check_oai_pmh_combined?
    curate?
  end

  def get_thumbnail?
    User.valid_user?(@user) && @user.has_role?(:administrator) && !@record.is_locked?
  end

  def remove_thumbnail?
    User.valid_user?(@user) && @user.has_role?(:administrator) && !@record.is_locked?
  end

  def flag_as_defunct?
    update?
  end

  def curate?
    update? && !@record.is_locked?
  end

  def edit?
    update? && !@record.is_locked?
  end

  def allowed_to_curate_if_record_not_locked?
    # this is necessary to allow the user to be told that they cannot curate a record that is locked, even if normally they can
    User.valid_user?(@user) && (@user.has_role?(:administrator) || @user.has_role?(:superuser) || @user.can_curate?(@record))
  end

  def authorise_user?
    User.valid_user?(@user) && (@user.has_role?(:administrator) || @user.has_role?(:superuser) || @user.is_responsible_for?(@record)) && !@record.is_locked?
  end

  def change_record_status?
    User.valid_user?(@user) && @user.has_role?(:administrator) && !@record.is_locked?
  end

  def change_system_status?
    User.valid_user?(@user) && (@user.has_role?(:administrator) || @user.has_role?(:superuser) || @user.is_responsible_for?(@record)) && !@record.is_locked?
  end

  def change_oai_status?
    User.valid_user?(@user) && @user.has_role?(:administrator) && !@record.is_locked?
    # should not need to be changed by curator since can be fully automatically tested and is not subject to robots problem
  end

  def change_rp?
    User.valid_user?(@user) && (@user.has_role?(:administrator) || @user.has_role?(:superuser)) && !@record.is_locked?
  end

  def autocomplete?
    public_access_to_data?
  end

  def update?
    User.valid_user?(@user) && (@user.has_role?(:administrator) || @user.has_role?(:superuser) || @user.can_curate?(@record))
  end

  def ark?
    show?
  end

  def view_audit?
    User.valid_user?(@user) && (@user.has_role?(:administrator) || @user.has_role?(:superuser))
  end


end

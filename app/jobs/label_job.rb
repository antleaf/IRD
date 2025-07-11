# frozen_string_literal: true

class LabelJob < ApplicationJob
  queue_as :default

  def perform(system_id, label, add_or_remove)
    system = System.includes(:network_checks, :repoids, :users).find(system_id)
    if add_or_remove == :add
      system.label_list.add label
    elsif add_or_remove == :remove
      system.label_list.remove label
    end
    Audited.audit_class.as_user(User.system_user) do
      system.save!
    end # this is needed
  end
end

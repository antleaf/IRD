# frozen_string_literal: true

class MarkRecordReviewedJob < ApplicationJob
  queue_as :default

  def perform(system_id)
    system = System.includes(:network_checks,:repoids,:users).find(system_id)
    system.mark_reviewed!
    Audited.audit_class.as_user(User.system_user) do
      system.save!
    end
  end
end

# frozen_string_literal: true

class PurgeThumbnailJob < ApplicationJob
  queue_as :default

  def perform(system_id)
    system = System.includes(:network_checks, :repoids, :users).find(system_id)
    system.thumbnail.purge
    Audited.audit_class.as_user(User.system_user) do
      system.save!
    end
  end
end


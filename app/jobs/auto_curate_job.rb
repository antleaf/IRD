# frozen_string_literal: true

class AutoCurateJob < ApplicationJob
  queue_as :default

  def perform(system_id)
    system = System.includes(:network_checks, :repoids, :users).find(system_id)
    service_result = Curation::SystemCuratorService.call(system)
    if service_result.success?
      system = service_result.payload
    end
    Audited.audit_class.as_user(User.system_user) do
      system.save!
    end
  end
end

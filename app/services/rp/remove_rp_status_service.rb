# frozen_string_literal: true
module Rp
  class RemoveRpStatusService < ApplicationService

    def call(org)
      begin
        unless org.id == Organisation.default_rp_id
          org.rp = false
          org.responsibilities.each do |system|
            remove_rp_status(system)
          end
        end
        success org
      rescue StandardError => e
        Rails.logger.error e.message
        failure e
      end
    end

    private

    def remove_rp_status(system)
      system = AllocateRpService.call!(system.id, Organisation.default_rp_id,true).payload
      Audited.audit_class.as_user(User.system_user) do
        system.save!
      end
    end
  end
end

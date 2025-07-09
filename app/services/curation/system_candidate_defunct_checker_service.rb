# frozen_string_literal: true
module Curation
  class SystemCandidateDefunctCheckerService < ApplicationService
    def call(system)
      begin
        nc_oai = system.network_checks.oai_pmh_identify_failed.first
        if system.system_status_online?
          system.label_list.remove("candidate-defunct")
        else
          nc_homepage = system.network_checks.homepage_url_failed.first
          if nc_homepage&.errors_past_threshold? && nc_oai&.errors_past_threshold?
            system.label_list.add("candidate-defunct")
            system.set_record_under_review! if system.record_status_verified?
          else
            system.label_list.remove("candidate-defunct")
          end
        end

        if system.oai_status_online?
          system.label_list.remove("candidate-out-of-scope")
        else
          if nc_oai&.errors_past_threshold?
            system.label_list.add("candidate-out-of-scope")
            system.set_record_under_review! if system.record_status_verified?
          else
            system.label_list.remove("candidate-out-of-scope")
          end
        end
      end
      success system
    rescue Exception => e
      Rails.logger.error("Error in CheckCandidateDefunctService: #{e.message}")
      failure e
    end
  end
end

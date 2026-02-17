# frozen_string_literal: true
require "nokogiri"

module OaiPmh
  class OaiPmhRecordCountService < ApplicationService
    def call(system_id, redirect_limit = 6)
      repositoryItemCount = 0
      url_with_verb_list_identifiers = ""
        begin
        @system = System.includes(:network_checks, :repoids, :users).find(system_id)
        original_url = @system.oai_base_url
        conn = Utilities::HttpClientConnectionWrapper.new(redirect_limit)
        resumptionToken = nil
        loop do
          url_with_verb_list_identifiers = Utilities::OaiPmhUrlFormatter.with_verb_list_identifiers(original_url, resumptionToken)
          # Rails.logger.debug("Running OAI-PMH List Identifiers on #{url_with_verb_list_identifiers}")
          response = conn.get(url_with_verb_list_identifiers)
          if response.status == 200
            doc = Nokogiri::XML(response.body)
            doc.remove_namespaces!
            resumptionTokenElement = doc.at_xpath("//resumptionToken")
            if resumptionTokenElement.present?
              completeListSizeAttribute = resumptionTokenElement["completeListSize"]
              if completeListSizeAttribute
                completeListSize = completeListSizeAttribute.to_i
                if completeListSize && completeListSize > 0
                  repositoryItemCount += completeListSize
                  break
                end
              end
              resumptionToken = resumptionTokenElement.text
            end
            headerElements = doc.xpath("//header")
            if headerElements.present?
              repositoryItemCount += headerElements.size
            else
              Rails.logger.warn("No header elements found in OAI-PMH List Identifiers response for #{@system.oai_base_url}")
            end
          end
          unless resumptionToken.present?
            break
          end
          # puts "Resumption token: #{resumptionToken}"
        end
      rescue Faraday::Error, StandardError => e
        Rails.logger.warn("#{e} for OAI-PMH List Identifiers #{url_with_verb_list_identifiers}")
        failure e
      else
        success @system
      end
    ensure
      begin
        if repositoryItemCount > 0
          @system.item_count = repositoryItemCount
          Audited.audit_class.as_user(User.system_user) do
            @system.save!
          end
          Rails.logger.debug("Updated item count for #{@system.oai_base_url} to #{repositoryItemCount}")
        end
      rescue Exception => e2
        Rails.logger.error("OAI-PMH Identify: #{e2.message}")
      end
    end
  end

end

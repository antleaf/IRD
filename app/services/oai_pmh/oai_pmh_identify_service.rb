# frozen_string_literal: true
require "nokogiri"

module OaiPmh
  class OaiPmhIdentifyService < ApplicationService

    def call(system_id, redirect_limit = 6)
      begin
        @system = System.includes(:network_checks, :repoids, :users).find(system_id)
        original_url = @system.oai_base_url
        unless original_url.present?
          generate_unconfirmed_oai_pmh_url_base_url
          original_url = @system.metadata["unconfirmed_oai_pmh_url_base_url"]
        end
        unless original_url.present?
          Rails.logger.debug("OAI-PMH Base URL not present for system #{@system.id}")
          @system.write_network_check(:oai_pmh_identify, false, "Missing OAI-PMH Base URL", 0)
          if @system.platform&.oai_support
            @system.oai_status = :not_enabled
          else
            @system.oai_status = :unsupported
          end
          raise StandardError.new("OAI-PMH Base URL not set")
        end
        original_url_with_verbs_removed = Utilities::OaiPmhUrlFormatter.without_verbs(original_url)
        if original_url_with_verbs_removed.to_s != @system.oai_base_url
          @system.oai_base_url = original_url_with_verbs_removed.to_s
          Rails.logger.debug "OAI-PMH Base updated from #{@system.oai_base_url} to #{original_url_with_verbs_removed.to_s}"
        end
        url_with_verb_identify = Utilities::OaiPmhUrlFormatter.with_verb_identify(original_url)
        Rails.logger.debug("Running OAI-PMH Identify on #{url_with_verb_identify}")
        conn = Utilities::HttpClientConnectionWrapper.new(redirect_limit)
        response = conn.get(url_with_verb_identify)
        Rails.logger.debug("Ran OAI-PMH Identify on #{conn.new_url}")

        @system.write_network_check(:oai_pmh_identify, true, "", response.status)
        @system.oai_status = :online
        Utilities::HttpHeadersProcessor.process_tags_from_headers(@system.tag_list, response.headers, :oai_pmh)
        parse_metadata(response)

      rescue Faraday::ResourceNotFound => e # 404
        Rails.logger.warn("#{e} for OAI-PMH Identify #{url_with_verb_identify}")
        @system.write_network_check(:oai_pmh_identify, false, e.message, e.response[:status])
        if @system.platform&.oai_support
          @system.oai_status = :not_enabled
        else
          @system.oai_status = :unsupported
        end
        failure e
      rescue Faraday::ForbiddenError => e # 403
        Rails.logger.warn("#{e} for OAI-PMH Identify #{url_with_verb_identify}")
        @system.write_network_check(:oai_pmh_identify, false, e.message, e.response[:status])
        @system.oai_status = :offline
        Utilities::HttpHeadersProcessor.process_tags_from_headers(@system.tag_list, e.response[:headers], :oai_pmh)
        failure e
      rescue Faraday::FollowRedirects::RedirectLimitReached => e
        Rails.logger.warn("#{e} for OAI-PMH Identify #{url_with_verb_identify}")
        @system.write_network_check(:oai_pmh_identify, false, e.message, 0)
        @system.oai_base_url = nil
        @system.oai_status = :offline
        failure e
      rescue Faraday::ClientError => e # 4xx
        Rails.logger.warn("#{e} for OAI-PMH Identify #{url_with_verb_identify}")
        @system.write_network_check(:oai_pmh_identify, false, e.message, e.response[:status])
        @system.oai_status = :offline
        failure e
      rescue Faraday::TimeoutError => e
        Rails.logger.warn("#{e} for OAI-PMH Identify #{url_with_verb_identify}")
        @system.write_network_check(:oai_pmh_identify, false, e.message, 0)
        @system.oai_status = :offline
        failure e
      rescue Faraday::NilStatusError => e
        Rails.logger.warn("#{e} for OAI-PMH Identify #{url_with_verb_identify}")
        @system.write_network_check(:oai_pmh_identify, false, e.message, 0)
        @system.oai_status = :offline
        failure e
      rescue Faraday::ServerError => e # 5xx
        Rails.logger.warn("#{e} for OAI-PMH Identify #{url_with_verb_identify}")
        @system.write_network_check(:oai_pmh_identify, false, e.message, e.response[:status])
        @system.oai_status = :offline
        failure e
      rescue Faraday::SSLError => e
        Rails.logger.warn("#{e} for OAI-PMH Identify #{url_with_verb_identify}")
        @system.write_network_check(:oai_pmh_identify, false, e.message, 0)
        @system.oai_status = :offline
        failure e
      rescue Faraday::ConnectionFailed => e
        Rails.logger.warn("#{e} for OAI-PMH Identify #{url_with_verb_identify}")
        @system.write_network_check(:oai_pmh_identify, false, e.message, 0)
        @system.oai_status = :not_enabled
        # @system.oai_base_url = nil
        # if @system.metadata["unconfirmed_oai_pmh_url_base_url"].blank?
        #   @system.oai_status = :unsupported
        # else
        #   @system.oai_status = :not_enabled
        # end
        failure e
      rescue Faraday::Error, StandardError => e
        Rails.logger.warn("#{e} for OAI-PMH Identify #{url_with_verb_identify}")
        @system.write_network_check(:oai_pmh_identify, false, e.message, 0)
        @system.oai_status = :unknown
        failure e
      else
        success @system
      ensure
        begin
          @system.metadata.except!("unconfirmed_oai_pmh_url_base_url") # if @system.metadata["unconfirmed_oai_pmh_url_base_url"]
          Audited.audit_class.as_user(User.system_user) do
            @system.save!
          end
        rescue Exception => e2
          Rails.logger.error("OAI-PMH Identify: #{e2.message}")
        end
      end

    end

    private

    def generate_unconfirmed_oai_pmh_url_base_url
      if @system.platform&.oai_support
        oai_pmh_url_suffix = @system.platform.oai_suffix unless @system.platform.blank?
        unless oai_pmh_url_suffix.blank?
          unconfirmed_oai_pmh_url_base_url = (Utilities::UrlUtility.get_url_without_trailing_slash(@system.url) + oai_pmh_url_suffix)
          unconfirmed_oai_pmh_url_base_url = Utilities::UrlUtility.get_url_with_parent_folder_redirect_removed(unconfirmed_oai_pmh_url_base_url)
          @system.metadata["unconfirmed_oai_pmh_url_base_url"] = unconfirmed_oai_pmh_url_base_url
        end
      end
    end

    def parse_metadata(response)
      doc = Nokogiri::XML(response.body)
      doc.remove_namespaces!
      base_url_reported_by_oai_pmh_identify = doc.at_xpath("//baseURL").text
      Rails.logger.warn("Base URL reported by OAI-PMH Identify is #{base_url_reported_by_oai_pmh_identify} which is different to known Base URL #{@system.oai_base_url}") if base_url_reported_by_oai_pmh_identify != @system.oai_base_url
      @system.metadata["oai_repo_name"] = doc.at_xpath("//repositoryName").text
      @system.metadata["oai_contact"] = doc.at_xpath("//adminEmail").text if doc.at_xpath("//adminEmail")
      doc.xpath("//description").each do |desc|
        repo_id = desc.at_xpath("//repositoryIdentifier")
        if repo_id
          @system.metadata["oai_id"] = ("oai:" + repo_id.text)
          break
        end
      end
      unless @system.metadata.empty?
        if @system.metadata["oai_id"]
          @system.add_repo_id(:OAI, @system.metadata["oai_id"])
        end
        if !@system.contact && @system.metadata["oai_contact"]
          @system.contact = @system.metadata["oai_contact"]
        end
        if !@system.description && @system.metadata["description"]
          @system.description = @system.metadata["description"]
        end
      end
    end
  end
end
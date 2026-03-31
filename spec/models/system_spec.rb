require 'rails_helper'

RSpec.describe System, type: :model do
  describe "enums" do
    it "defaults record_status to draft" do
      expect(System.new.record_status).to eq("draft")
    end

    it "defaults system_status to unknown" do
      expect(System.new.system_status).to eq("unknown")
    end

    it "defaults oai_status to unknown" do
      expect(System.new.oai_status).to eq("unknown")
    end

    it "defaults system_category to unknown" do
      expect(System.new.system_category).to eq("unknown")
    end
  end

  describe "associations" do
    it "belongs to a platform" do
      expect(systems(:zenodo).platform).to be_a(Platform)
    end

    it "belongs to a country" do
      expect(systems(:zenodo).country).to be_a(Country)
    end

    it "has many network_checks" do
      expect(systems(:zenodo).network_checks).to be_a(ActiveRecord::Associations::CollectionProxy)
    end

    it "has many repoids" do
      expect(systems(:zenodo).repoids).to be_a(ActiveRecord::Associations::CollectionProxy)
    end
  end

  describe "validations" do
    it "is invalid without a name" do
      system = systems(:zenodo)
      system.name = nil
      expect(system).not_to be_valid
      expect(system.errors[:name]).to be_present
    end

    it "is invalid without a url" do
      system = systems(:zenodo)
      system.url = nil
      expect(system).not_to be_valid
      expect(system.errors[:url]).to be_present
    end
  end

  describe "scopes" do
    it ".publicly_viewable excludes draft records" do
      expect(System.publicly_viewable).not_to include(systems(:hidden_draft))
    end

    it ".publicly_viewable includes verified records" do
      expect(System.publicly_viewable).to include(systems(:zenodo))
    end

    it ".has_owner returns only systems with an owner" do
      expect(System.has_owner).to include(systems(:zenodo))
    end

    it ".in_country filters by country_id" do
      expect(System.in_country("CH")).to include(systems(:zenodo))
    end
  end

  describe "#publicly_viewable?" do
    it "returns true for a verified system" do
      expect(systems(:zenodo).publicly_viewable?).to be true
    end

    it "returns false for a draft system" do
      expect(systems(:hidden_draft).publicly_viewable?).to be false
    end
  end

  describe "#display_name" do
    it "returns short_name when present" do
      expect(systems(:zenodo).display_name).to eq("Zenodo")
    end

    it "returns name when short_name is blank" do
      system = systems(:zenodo)
      system.short_name = ""
      expect(system.display_name).to eq("Zenodo")
    end
  end

  describe "#review_due?" do
    it "returns true when never reviewed" do
      system = systems(:hidden_draft)
      system.reviewed = nil
      expect(system.review_due?).to be true
    end

    it "returns false when recently reviewed" do
      system = systems(:zenodo)
      system.reviewed = 1.day.ago
      expect(system.review_due?).to be false
    end

    it "returns true when review is overdue" do
      system = systems(:zenodo)
      system.reviewed = 2.years.ago
      expect(system.review_due?).to be true
    end
  end

  describe "record status transitions" do
    it "#set_record_draft! sets record_status to draft" do
      system = systems(:zenodo)
      system.set_record_draft!
      expect(system.record_status).to eq("draft")
    end

    it "#set_record_verified! sets record_status to verified and marks reviewed" do
      system = systems(:hidden_draft)
      system.set_record_verified!
      expect(system.record_status).to eq("verified")
      expect(system.reviewed).to be_within(1.second).of(Time.zone.now)
    end

    it "#set_record_under_review! sets record_status to under_review" do
      system = systems(:zenodo)
      system.set_record_under_review!
      expect(system.record_status).to eq("under_review")
    end

    it "#set_record_awaiting_review! sets record_status to awaiting_review" do
      system = systems(:zenodo)
      system.set_record_awaiting_review!
      expect(system.record_status).to eq("awaiting_review")
    end
  end

  describe "#unknown_platform?" do
    it "returns false for a system with a known platform" do
      expect(systems(:zenodo).unknown_platform?).to be false
    end
  end

  describe "#mark_reviewed!" do
    it "sets reviewed to the current time" do
      system = systems(:zenodo)
      system.mark_reviewed!
      expect(system.reviewed).to be_within(1.second).of(Time.zone.now)
    end
  end
end

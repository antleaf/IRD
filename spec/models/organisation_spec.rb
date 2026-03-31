require 'rails_helper'

RSpec.describe Organisation, type: :model do
  let(:ird_system_org) { organisations(:"a1e87a55-b200-49b0-95a0-0f36832730c5") }
  let(:cern)           { organisations(:"4ab4ad1a-0d3d-40ef-824c-cd20b3173e78") }
  let(:coar)           { organisations(:"d0dafe16-fbe7-4392-aa11-c5c3466ba8d7") }

  describe "associations" do
    it "belongs to a country" do
      expect(cern.country).to be_a(Country)
    end

    it "has many ownerships (systems it owns)" do
      expect(cern.ownerships).to include(systems(:zenodo))
    end

    it "has many responsibilities (systems it is RP for)" do
      expect(ird_system_org.responsibilities).to be_a(ActiveRecord::Associations::CollectionProxy)
    end
  end

  describe "scopes" do
    it ".rps returns only RP organisations" do
      rps = Organisation.rps
      expect(rps).to all(have_attributes(rp: true))
      expect(rps).to include(ird_system_org)
      expect(rps).not_to include(cern)
    end

    it ".in_country filters by country_id" do
      result = Organisation.in_country("CH")
      expect(result).to include(cern)
      expect(result).not_to include(ird_system_org)
    end
  end

  describe "validations" do
    it "is invalid when ror is duplicated" do
      dup = Organisation.new(
        name: "Duplicate ROR Org",
        ror: cern.ror,
        country: countries(:CH)
      )
      expect(dup).not_to be_valid
      expect(dup.errors[:ror]).to be_present
    end

    it "allows multiple organisations with blank ror" do
      org1 = Organisation.create!(name: "Org One", ror: "", country: countries(:GB))
      org2 = Organisation.new(name: "Org Two", ror: "", country: countries(:GB))
      expect(org2).to be_valid
    end
  end

  describe "#is_rp?" do
    it "returns true for an RP organisation" do
      expect(ird_system_org.is_rp?).to be true
    end

    it "returns false for a non-RP organisation" do
      expect(cern.is_rp?).to be false
    end
  end

  describe "#make_rp!" do
    it "sets rp to true and persists" do
      cern.make_rp!
      expect(cern.reload.is_rp?).to be true
    end
  end

  describe "#display_name" do
    it "returns short_name when present" do
      expect(cern.display_name).to eq("CERN")
    end

    it "returns name when short_name is blank" do
      org = Organisation.create!(name: "No Short Name Org", short_name: "", country: countries(:GB))
      expect(org.display_name).to eq("No Short Name Org")
    end
  end

  describe ".rp_for_country" do
    it "returns the single RP for a country when exactly one exists" do
      # COAR has country_id '--' and is an RP; IRD System also has '--'
      # so there are two RPs for '--'; result should be nil
      expect(Organisation.rp_for_country("--")).to be_nil
    end
  end

  describe "before_save callbacks" do
    it "extracts a short_name from aliases when short_name is blank" do
      org = Organisation.create!(
        name: "Long Organisation Name That Has No Short Name",
        short_name: "",
        aliases: ["ShortAlias"],
        country: countries(:GB)
      )
      expect(org.short_name).to eq("ShortAlias")
    end

    it "deduplicates aliases on save" do
      org = Organisation.create!(
        name: "Dedup Org",
        aliases: ["Alias One", "Alias One", "Alias Two"],
        country: countries(:GB)
      )
      expect(org.aliases).to eq(["Alias One", "Alias Two"])
    end
  end
end

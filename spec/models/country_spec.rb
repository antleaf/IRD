require 'rails_helper'

RSpec.describe Country, type: :model do
  describe "associations" do
    it "has many organisations" do
      country = countries(:GB)
      expect(country.organisations).to be_a(ActiveRecord::Associations::CollectionProxy)
    end

    it "has many systems" do
      country = countries(:GB)
      expect(country.systems).to be_a(ActiveRecord::Associations::CollectionProxy)
    end
  end

  describe "continent enum" do
    it "has the expected continent values" do
      expect(Country.continents.keys).to include("global", "africa", "antarctica", "asia",
                                                 "central_america", "europe", "north_america",
                                                 "oceania", "south_america")
    end

    it "defaults to global" do
      expect(Country.new.continent).to eq("global")
    end

    it "returns a translated continent label" do
      country = countries(:GB)
      expect(country.translated_continent).to be_a(String)
      expect(country.translated_continent).not_to be_empty
    end
  end

  describe ".default_id" do
    it "returns '--'" do
      expect(Country.default_id).to eq('--')
    end
  end

  describe ".default" do
    it "returns the country with id '--'" do
      default_country = Country.default
      expect(default_country.id).to eq('--')
    end
  end

  describe "#responsible_parties" do
    it "returns only organisations with rp: true" do
      country = countries(:GB)
      rps = country.responsible_parties
      expect(rps).to all(have_attributes(rp: true))
    end
  end

  describe "#system_count" do
    it "returns the number of systems for the country" do
      country = countries(:GB)
      expect(country.system_count).to eq(country.systems.count)
    end
  end

  describe "MachineReadability" do
    it "defines machine_readable_attributes" do
      attrs = Country.machine_readable_attributes
      expect(attrs).to be_a(MachineReadability::MachineReadableAttributeSet)
    end

    it "includes id, name, and repositories labels" do
      labels = Country.machine_readable_attributes.labels
      expect(labels).to include(:id, :name, :repositories)
    end
  end
end
require 'rails_helper'

RSpec.describe Platform, type: :model do
  describe "associations" do
    it "has many systems" do
      platform = platforms(:dspace)
      expect(platform.systems).to be_a(ActiveRecord::Associations::CollectionProxy)
    end

    it "has many generators, deleted when platform is destroyed" do
      platform = platforms(:dspace)
      expect(platform.generators).to be_a(ActiveRecord::Associations::CollectionProxy)
    end
  end

  describe "#trusted?" do
    it "returns true for a trusted platform" do
      expect(platforms(:dspace).trusted?).to be true
    end

    it "returns false for an untrusted platform" do
      expect(platforms(:drupal).trusted?).to be false
    end
  end

  describe "on creation" do
    it "sets the id from the name when no id is given" do
      platform = Platform.create!(name: "My New Platform")
      expect(platform.id).to eq("my-new-platform")
    end

    it "keeps an explicitly set id" do
      platform = Platform.create!(id: "custom-id", name: "Something")
      expect(platform.id).to eq("custom-id")
    end
  end

  describe "initialise_for_saving" do
    it "sets matchers to an empty array when nil" do
      platform = Platform.create!(name: "No Matchers Platform")
      expect(platform.matchers).to eq([])
    end

    it "sets generator_patterns to an empty array when nil" do
      platform = Platform.create!(name: "No Patterns Platform")
      expect(platform.generator_patterns).to eq([])
    end

    it "sets match_order to 100 when nil" do
      platform = Platform.create!(name: "Default Order Platform")
      expect(platform.match_order).to eq(100.0)
    end

    it "deduplicates matchers on save" do
      platform = Platform.create!(name: "Dedup Matchers", matchers: ["/foo/i", "/foo/i", "/bar/i"])
      expect(platform.matchers).to eq(["/foo/i", "/bar/i"])
    end
  end

  describe "validation" do
    it "is valid with a valid matcher regex" do
      platform = Platform.new(name: "Valid Matchers", matchers: ["/dspace/i"])
      expect(platform).to be_valid
    end

    it "is invalid with a non-regex matcher" do
      platform = Platform.new(name: "Bad Matchers", matchers: ["not_a_regex"])
      expect(platform).not_to be_valid
      expect(platform.errors[:matchers]).to be_present
    end

    it "is valid with a valid generator_pattern regex" do
      platform = Platform.new(name: "Valid Patterns", generator_patterns: ["/^DSpace (.*)/"])
      expect(platform).to be_valid
    end

    it "is invalid with a non-regex generator_pattern" do
      platform = Platform.new(name: "Bad Patterns", generator_patterns: ["not_a_regex"])
      expect(platform).not_to be_valid
      expect(platform.errors[:generator_patterns]).to be_present
    end

    it "is valid with no matchers or generator_patterns" do
      platform = Platform.new(name: "Empty Arrays")
      expect(platform).to be_valid
    end
  end

  describe "MachineReadability" do
    it "defines machine_readable_attributes" do
      attrs = Platform.machine_readable_attributes
      expect(attrs).to be_a(MachineReadability::MachineReadableAttributeSet)
    end

    it "includes id, name, and repositories labels" do
      labels = Platform.machine_readable_attributes.labels
      expect(labels).to include(:id, :name, :repositories)
    end
  end
end
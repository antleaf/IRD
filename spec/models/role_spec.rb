require 'rails_helper'

RSpec.describe Role, type: :model do
  describe "associations" do
    it "has and belongs to many users" do
      expect(roles(:administrator).users).to include(users(:administrator))
    end
  end

  describe "on creation" do
    it "creates a valid ID from the name" do
      role = Role.create!(name: "Test Role")
      expect(role.id).to eq('test-role')
    end

    it "keeps an explicitly set id" do
      role = Role.create!(id: "custom-role", name: "Custom Role")
      expect(role.id).to eq("custom-role")
    end
  end
end

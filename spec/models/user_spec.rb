require 'rails_helper'

RSpec.describe User, type: :model do
  describe "validations" do
    it "is invalid without an email" do
      user = User.new(fore_name: "Test", last_name: "User")
      expect(user).not_to be_valid
      expect(user.errors[:email]).to be_present
    end

    it "is invalid without a fore_name" do
      user = User.new(email: "test@example.com", last_name: "User")
      expect(user).not_to be_valid
      expect(user.errors[:fore_name]).to be_present
    end

    it "is invalid without a last_name" do
      user = User.new(email: "test@example.com", fore_name: "Test")
      expect(user).not_to be_valid
      expect(user.errors[:last_name]).to be_present
    end

    it "is invalid with a duplicate email" do
      user = User.new(email: users(:administrator).email, fore_name: "Dupe", last_name: "User")
      expect(user).not_to be_valid
      expect(user.errors[:email]).to be_present
    end
  end

  describe "on creation" do
    it "generates a UUID as id" do
      user = User.create!(email: "new@example.com", fore_name: "New", last_name: "User")
      expect(user.id).to match(/\A[0-9a-f-]{36}\z/)
    end
  end

  describe "#display_name" do
    it "concatenates fore_name and last_name" do
      expect(users(:administrator).display_name).to eq("PW Admin")
    end
  end

  describe "#name" do
    it "is an alias for display_name" do
      user = users(:administrator)
      expect(user.name).to eq(user.display_name)
    end
  end

  describe "#access_revoked?" do
    it "returns false when access is not revoked" do
      expect(users(:administrator).access_revoked?).to be false
    end

    it "returns true after revoking access" do
      user = users(:user)
      user.revoke_access!
      expect(user.access_revoked?).to be true
    end
  end

  describe "#revoke_access! / #restore_access!" do
    it "revokes and restores access" do
      user = users(:user)
      user.revoke_access!
      expect(user.access_revoked?).to be true
      user.restore_access!
      expect(user.access_revoked?).to be false
    end
  end

  describe ".valid_user?" do
    it "returns true for a valid, non-revoked user" do
      expect(User.valid_user?(users(:administrator))).to be true
    end

    it "returns false for a non-User argument" do
      expect(User.valid_user?("not-a-user")).to be false
    end

    it "returns false for a revoked user" do
      user = users(:user)
      user.revoke_access!
      expect(User.valid_user?(user)).to be false
    end
  end

  describe "#has_role?" do
    it "returns true when the user has the given role" do
      expect(users(:administrator).has_role?(:administrator)).to be true
    end

    it "returns false when the user does not have the given role" do
      expect(users(:user).has_role?(:administrator)).to be false
    end
  end

  describe "#is_agent_for?" do
    it "returns false when the user has no organisations" do
      expect(users(:user).is_agent_for?(organisations(:"4ab4ad1a-0d3d-40ef-824c-cd20b3173e78"))).to be false
    end

    it "returns false when passed nil" do
      expect(users(:user).is_agent_for?(nil)).to be false
    end
  end

  describe "#generate_and_return_api_key" do
    it "returns a new UUID key and saves a hashed version" do
      user = users(:administrator)
      key = user.generate_and_return_api_key
      expect(key).to match(/\A[0-9a-f-]{36}\z/)
      expect(user.authenticate_api_key(key)).to be_truthy
    end
  end
end

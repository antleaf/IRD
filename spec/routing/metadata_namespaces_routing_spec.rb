require "rails_helper"

RSpec.describe MetadataNamespacesController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/metadata_namespaces").to route_to("metadata_namespaces#index")
    end

    it "routes to #new" do
      expect(get: "/metadata_namespaces/new").to route_to("metadata_namespaces#new")
    end

    it "routes to #show" do
      expect(get: "/metadata_namespaces/1").to route_to("metadata_namespaces#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/metadata_namespaces/1/edit").to route_to("metadata_namespaces#edit", id: "1")
    end


    it "routes to #create" do
      expect(post: "/metadata_namespaces").to route_to("metadata_namespaces#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/metadata_namespaces/1").to route_to("metadata_namespaces#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/metadata_namespaces/1").to route_to("metadata_namespaces#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/metadata_namespaces/1").to route_to("metadata_namespaces#destroy", id: "1")
    end
  end
end

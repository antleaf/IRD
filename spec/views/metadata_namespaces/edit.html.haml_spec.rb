require 'rails_helper'

RSpec.describe "metadata_namespaces/edit", type: :view do
  let(:metadata_namespace) {
    MetadataNamespace.create!(
      metadata_format: nil
    )
  }

  before(:each) do
    assign(:metadata_namespace, metadata_namespace)
  end

  it "renders the edit metadata_namespace form" do
    render

    assert_select "form[action=?][method=?]", metadata_namespace_path(metadata_namespace), "post" do

      assert_select "input[name=?]", "metadata_namespace[metadata_format_id]"
    end
  end
end

require 'rails_helper'

RSpec.describe "metadata_namespaces/new", type: :view do
  before(:each) do
    assign(:metadata_namespace, MetadataNamespace.new(
      metadata_format: nil
    ))
  end

  it "renders new metadata_namespace form" do
    render

    assert_select "form[action=?][method=?]", metadata_namespaces_path, "post" do

      assert_select "input[name=?]", "metadata_namespace[metadata_format_id]"
    end
  end
end

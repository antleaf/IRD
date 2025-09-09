require 'rails_helper'

RSpec.describe "metadata_namespaces/show", type: :view do
  before(:each) do
    assign(:metadata_namespace, MetadataNamespace.create!(
      metadata_format: nil
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(//)
  end
end

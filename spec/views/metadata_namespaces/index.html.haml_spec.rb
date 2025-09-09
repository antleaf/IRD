require 'rails_helper'

RSpec.describe "metadata_namespaces/index", type: :view do
  before(:each) do
    assign(:metadata_namespaces, [
      MetadataNamespace.create!(
        metadata_format: nil
      ),
      MetadataNamespace.create!(
        metadata_format: nil
      )
    ])
  end

  it "renders a list of metadata_namespaces" do
    render
    cell_selector = 'div>p'
    assert_select cell_selector, text: Regexp.new(nil.to_s), count: 2
  end
end

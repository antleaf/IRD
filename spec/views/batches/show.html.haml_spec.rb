require 'rails_helper'

RSpec.describe "batches/show", type: :view do
  before(:each) do
    assign(:batch, Batch.create!(
      filename: "Filename",
      user: nil,
      rp: nil,
      locking: false,
      notes: "MyText"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Filename/)
    expect(rendered).to match(//)
    expect(rendered).to match(//)
    expect(rendered).to match(/false/)
    expect(rendered).to match(/MyText/)
  end
end

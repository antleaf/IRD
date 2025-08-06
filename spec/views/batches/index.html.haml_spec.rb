require 'rails_helper'

RSpec.describe "batches/index", type: :view do
  before(:each) do
    assign(:batches, [
      Batch.create!(
        filename: "Filename",
        user: nil,
        rp: nil,
        locking: false,
        notes: "MyText"
      ),
      Batch.create!(
        filename: "Filename",
        user: nil,
        rp: nil,
        locking: false,
        notes: "MyText"
      )
    ])
  end

  it "renders a list of batches" do
    render
    cell_selector = 'div>p'
    assert_select cell_selector, text: Regexp.new("Filename".to_s), count: 2
    assert_select cell_selector, text: Regexp.new(nil.to_s), count: 2
    assert_select cell_selector, text: Regexp.new(nil.to_s), count: 2
    assert_select cell_selector, text: Regexp.new(false.to_s), count: 2
    assert_select cell_selector, text: Regexp.new("MyText".to_s), count: 2
  end
end

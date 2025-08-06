require 'rails_helper'

RSpec.describe "batches/edit", type: :view do
  let(:batch) {
    Batch.create!(
      filename: "MyString",
      user: nil,
      rp: nil,
      locking: false,
      notes: "MyText"
    )
  }

  before(:each) do
    assign(:batch, batch)
  end

  it "renders the edit batch form" do
    render

    assert_select "form[action=?][method=?]", batch_path(batch), "post" do

      assert_select "input[name=?]", "batch[filename]"

      assert_select "input[name=?]", "batch[user_id]"

      assert_select "input[name=?]", "batch[rp_id]"

      assert_select "input[name=?]", "batch[locking]"

      assert_select "textarea[name=?]", "batch[notes]"
    end
  end
end

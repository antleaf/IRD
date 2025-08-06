require 'rails_helper'

RSpec.describe "batches/new", type: :view do
  before(:each) do
    assign(:batch, Batch.new(
      filename: "MyString",
      user: nil,
      rp: nil,
      locking: false,
      notes: "MyText"
    ))
  end

  it "renders new batch form" do
    render

    assert_select "form[action=?][method=?]", batches_path, "post" do

      assert_select "input[name=?]", "batch[filename]"

      assert_select "input[name=?]", "batch[user_id]"

      assert_select "input[name=?]", "batch[rp_id]"

      assert_select "input[name=?]", "batch[locking]"

      assert_select "textarea[name=?]", "batch[notes]"
    end
  end
end

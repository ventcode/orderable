# frozen_string_literal: true

RSpec.describe "Configuration option :order" do
  before { create_list(:asc_order_model, 3) }

  it "returns records in asc order" do
    expect(AscOrderModel.ordered.pluck(:position)).to eq([0, 1, 2])
  end
end

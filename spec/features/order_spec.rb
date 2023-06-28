# frozen_string_literal: true

RSpec.describe "Orderable field scope with argument" do
  before { create_list(:basic_model, 3) }

  context "when ascending order set" do
    it "returns records proper order" do
      expect(BasicModel.ordered.pluck(:position)).to eq([0, 1, 2])
    end
  end

  context "when order not specified in scope" do
    it "returns records in descending order" do
      expect(BasicModel.ordered(:desc).pluck(:position)).to eq([2, 1, 0])
    end
  end
end

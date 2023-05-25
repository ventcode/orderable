# frozen_string_literal: true

RSpec.describe "Order modification" do
  before { create_list(:basic_model, 4) }

  let(:names) { BasicModel.order(:position).pluck(:name) }
  let(:positions) { BasicModel.order(:position).pluck(:position) }

  context "when creating a new record" do
    before { create(:basic_model, name: "e", position: 2) }

    it "pushes all later positions" do
      expect(names).to eq(%w[a b e c d])
    end

    it "keeps the sequential order" do
      expect(positions).to eq((0..4).to_a)
    end
  end

  context "when updating to a higher position" do
    before { BasicModel.find_by(name: "a").update(position: 2) }

    it "shifts objects around" do
      expect(names).to eq(%w[b c a d])
    end

    it "keeps the sequential order" do
      expect(positions).to eq((0..3).to_a)
    end
  end

  context "when updating to a lower position" do
    before { BasicModel.find_by(name: "c").update(position: 0) }

    it "shifts objects around" do
      expect(names).to eq(%w[c a b d])
    end

    it "keeps the sequential order" do
      expect(positions).to eq((0..3).to_a)
    end
  end

  context "when destroying a record" do
    before { BasicModel.find_by(name: "c").destroy }

    it "pulls all later positions" do
      expect(names).to eq(%w[a b d])
    end

    it "keeps the sequential order" do
      expect(positions).to eq((0..2).to_a)
    end
  end
end

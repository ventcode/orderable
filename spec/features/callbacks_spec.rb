# frozen_string_literal: true

RSpec.describe "Callbacks" do
  before do
    create_list(:basic_model, 5)
  end

  describe "on #initialize" do
    subject { build(:basic_model) }

    it "sets the position value as increased by 1 from the previous maximum value" do
      expect(subject.position).to eq(BasicModel.maximum(:position) + 1)
    end
  end

  describe "on #destroy" do
    subject { record.destroy }
    let!(:record) { create(:basic_model, position: 0) }

    it "decreases the position of other records by 1" do
      expect { subject }
        .to change { BasicModel.ordered.pluck(:name, :position).to_h }
        .from(
          {
            "e" => 5,
            "d" => 4,
            "c" => 3,
            "b" => 2,
            "a" => 1,
            "f" => 0
          }
        ).to(
          {
            "e" => 4,
            "d" => 3,
            "c" => 2,
            "b" => 1,
            "a" => 0
          }
        )
    end
  end
end

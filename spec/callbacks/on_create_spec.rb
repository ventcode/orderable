# TODO: Add case to create record with position 1 when there are any others

# frozen_string_literal: true

RSpec.describe "on #create" do
  context "model without additional scope" do
    subject { create(:basic_model, attrs) }
    let(:attrs) { {} }

    before do
      create_list(:basic_model, 5)
    end

    it "sets the position value as the maxium one" do
      expect(subject.position).to eq(BasicModel.maximum(:position))
    end

    context "when position attribute manually changed" do
      let(:attrs) { { position: 3 } }

      it "sets the record position as 3 and increments the position of upper records by 1" do
        expect { subject }
          .to change { BasicModel.ordered.pluck(:name, :position).to_h }
          .from(
            {
              "e" => 4,
              "d" => 3,
              "c" => 2,
              "b" => 1,
              "a" => 0
            }
          ).to(
            {
              "e" => 5,
              "d" => 4,
              "f" => 3,
              "c" => 2,
              "b" => 1,
              "a" => 0
            }
          )
      end
    end
  end

  context "model with many scopes" do
    subject { create(:model_with_many_scopes, group: group) }
    let(:group) { "first" }

    before do
      create_list(:model_with_many_scopes, 3, group: group)
    end

    context "creating record within a scope" do
      it "sets the position value as the maxium one" do
        expect { subject }
          .to change { ModelWithManyScopes.ordered.pluck(:name, :position, :group) }
          .from(
            [
              ["a", 2, "first"],
              ["b", 1, "first"],
              ["c", 0, "first"]
            ]
          )
          .to(
            [
              ["a", 3, "first"],
              ["b", 2, "first"],
              ["c", 1, "first"],
              ["d", 0, "first"]
            ]
          )
      end
    end
  end
end

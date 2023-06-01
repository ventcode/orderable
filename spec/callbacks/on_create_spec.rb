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

    context "when position attribute manually changed and is too big" do
      let(:attrs) { { position: 6 } }

      it "raises validation error" do
        expect { subject }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    context "when position attribute manually changed and is too low" do
      let(:attrs) { { position: -1 } }

      it "raises validation error" do
        expect { subject }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end

  context "model with many scopes" do
    subject { create(:model_with_many_scopes, group: group) }

    before do
      create_list(:model_with_many_scopes, 3, group: "first")
    end

    context "creating record within a scope" do
      let(:group) { "first" }

      it "sets the position value to a new maximum" do
        expect { subject }
          .to change { ModelWithManyScopes.ordered.pluck(:name, :position, :group) }
          .from(
            [
              ["c", 2, "first"],
              ["b", 1, "first"],
              ["a", 0, "first"]
            ]
          )
          .to(
            [
              ["d", 3, "first"],
              ["c", 2, "first"],
              ["b", 1, "first"],
              ["a", 0, "first"]
            ]
          )
      end
    end

    context "creating record out of a scope" do
      let(:group) { "second" }

      it "sets the position to zero and doesn't change other records" do
        expect { subject }
          .to change { ModelWithManyScopes.ordered.pluck(:name, :position, :group) }
          .from(
            [
              ["c", 2, "first"],
              ["b", 1, "first"],
              ["a", 0, "first"]
            ]
          )
          .to(
            [
              ["c", 2, "first"],
              ["b", 1, "first"],
              ["a", 0, "first"],
              ["d", 0, "second"]
            ]
          )
      end
    end
  end

  context "model without validation" do
    subject { create(:no_validation_model, position: position) }

    before do
      create_list(:no_validation_model, 3)
      (7..9).each { |p| create(:no_validation_model, position: p) }
    end

    context "when record is between other records" do
      let(:position) { 1 }

      it "sets the record position to 1 and increment records above by one" do
        expect { subject }
          .to change { NoValidationModel.ordered.pluck(:name, :position).to_h }
          .from(
            {
              "f" => 9,
              "e" => 8,
              "d" => 7,
              "c" => 2,
              "b" => 1,
              "a" => 0
            }
          ).to(
            {
              "f" => 10,
              "e" => 9,
              "d" => 8,
              "c" => 3,
              "b" => 2,
              "g" => 1,
              "a" => 0
            }
          )
      end
    end

    context "when position attribute is not specified" do
      let(:position) { nil }

      it "sets the record position to maximum + 1 and don't do anything with other records" do
        expect { subject }
          .to change { NoValidationModel.ordered.pluck(:name, :position).to_h }
          .from(
            {
              "f" => 9,
              "e" => 8,
              "d" => 7,
              "c" => 2,
              "b" => 1,
              "a" => 0
            }
          ).to(
            {
              "g" => 10,
              "f" => 9,
              "e" => 8,
              "d" => 7,
              "c" => 2,
              "b" => 1,
              "a" => 0
            }
          )
      end
    end
  end
end

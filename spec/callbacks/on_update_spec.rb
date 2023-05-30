# frozen_string_literal: true

RSpec.describe "on #update" do
  context "model without additional scope" do
    subject { record.update!(position: position) }
    let(:record) { create(:basic_model) }
    let(:position) { 0 }

    before do
      create_list(:basic_model, 5)
    end

    it "sets record position as 0 and increments position of other records by 1" do
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
            "c" => 3,
            "b" => 2,
            "a" => 1,
            "f" => 0
          }
        )
    end

    context "position value set as the middle value" do
      let(:position) { 3 }

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
    before do
      create_list(:model_with_many_scopes, 3, group: "first")
    end

    context "scope property & position updated" do
      subject { record.update!(group: "first", position: position) }
      let!(:record) { create(:model_with_many_scopes, group: "second") }
      let(:position) { 1 }

      it "sets record position as 1 and increments position of records above by 1" do
        expect { subject }
          .to change { ModelWithManyScopes.ordered.pluck(:name, :position, :group) }
          .from(
            [
              ["a", 2, "first"],
              ["b", 1, "first"],
              ["c", 0, "first"],
              ["d", 0, "second"]
            ]
          )
          .to(
            [
              ["a", 3, "first"],
              ["b", 2, "first"],
              ["d", 1, "first"], # updated record
              ["c", 0, "first"]
            ]
          )
      end

      context "position value set as the maximum one" do
        let(:position) { ModelWithManyScopes.maximum(:position) }

        it "sets the record position as the maximum one and increments the position of records above by 1" do
          expect { subject }
            .to change { ModelWithManyScopes.ordered.pluck(:name, :position, :group) }
            .from(
              [
                ["a", 2, "first"],
                ["b", 1, "first"],
                ["c", 0, "first"],
                ["d", 0, "second"]
              ]
            )
            .to(
              [
                ["a", 3, "first"],
                ["d", 2, "first"], # updated record
                ["b", 1, "first"],
                ["c", 0, "first"]
              ]
            )
        end
      end
    end

    context "only scope property updated" do
      subject { record.update!(group: "first") }
      let!(:record) { create(:model_with_many_scopes, group: "second") }

      it "sets record position as 0 by default and increments position of other records in scope by 1" do
        expect { subject }
          .to change { ModelWithManyScopes.ordered.pluck(:name, :position, :group) }
          .from(
            [
              ["a", 2, "first"],
              ["b", 1, "first"],
              ["c", 0, "first"],
              ["d", 0, "second"]
            ]
          )
          .to(
            [
              ["a", 3, "first"],
              ["b", 2, "first"],
              ["c", 1, "first"],
              ["d", 0, "first"] # updated record
            ]
          )
      end
    end
  end
end

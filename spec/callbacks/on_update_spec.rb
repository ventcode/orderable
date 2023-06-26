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

    context "position value is too big" do
      let(:position) { 6 }

      it "raises validation error" do
        expect { subject }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    context "position value is too big" do
      let(:position) { -1 }

      it "raises validation error" do
        expect { subject }.to raise_error(ActiveRecord::RecordInvalid)
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
              ["c", 2, "first"],
              ["b", 1, "first"],
              ["a", 0, "first"],
              ["d", 0, "second"]
            ]
          )
          .to(
            [
              ["c", 3, "first"],
              ["b", 2, "first"],
              ["d", 1, "first"], # updated record
              ["a", 0, "first"]
            ]
          )
      end

      context "position value set as the maximum one" do
        let(:position) { 2 }

        it "sets the record position as the maximum one and increments the position of records above by 1" do
          expect { subject }
            .to change { ModelWithManyScopes.ordered.pluck(:name, :position, :group) }
            .from(
              [
                ["c", 2, "first"],
                ["b", 1, "first"],
                ["a", 0, "first"],
                ["d", 0, "second"]
              ]
            )
            .to(
              [
                ["c", 3, "first"],
                ["d", 2, "first"], # updated record
                ["b", 1, "first"],
                ["a", 0, "first"]
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
              ["c", 2, "first"],
              ["b", 1, "first"],
              ["a", 0, "first"],
              ["d", 0, "second"]
            ]
          )
          .to(
            [
              ["d", 3, "first"], # updated record
              ["c", 2, "first"],
              ["b", 1, "first"],
              ["a", 0, "first"]
            ]
          )
      end
    end

    context "other property updated" do
      subject { record.update!(name: "new name") }
      let!(:record) { create(:model_with_many_scopes, group: "first") }

      it "sets record name to new name and change neither position nor scope" do
        expect { subject }
          .to change { ModelWithManyScopes.ordered.pluck(:name, :position, :group) }
          .from(
            [
              ["d", 3, "first"],
              ["c", 2, "first"],
              ["b", 1, "first"],
              ["a", 0, "first"]
            ]
          )
          .to(
            [
              ["new name", 3, "first"],
              ["c", 2, "first"],
              ["b", 1, "first"],
              ["a", 0, "first"]
            ]
          )
      end
    end

    context "only scope property updated" do
      subject { record.update!(group: "second") }
      let!(:record) { create(:model_with_many_scopes, group: "first", position: 2) }

      it "sets record position as 0 by default and increments position of other records in scope by 1" do
        expect { subject }
          .to change { ModelWithManyScopes.ordered.pluck(:name, :position, :group) }
          .from(
            [
              ["c", 3, "first"],
              ["d", 2, "first"],
              ["b", 1, "first"],
              ["a", 0, "first"]
            ]
          )
          .to(
            [
              ["c", 2, "first"],
              ["b", 1, "first"],
              ["a", 0, "first"],
              ["d", 0, "second"] # updated record
            ]
          )
      end
    end
  end

  context "model with many scopes - considering descending sequence" do
    before do
      create_list(:decremental_sequence_model_with_many_scopes, 3, group: "first")
    end

    context "scope property & position updated" do
      subject { record.update!(group: "first", position: position) }
      let!(:record) { create(:decremental_sequence_model_with_many_scopes, group: "second") }
      let(:position) { 9 }

      it "sets record position as 9 and decrements position of records below by 1" do
        expect { subject }
          .to change { DecrementalSequenceModelWithManyScopes.ordered.pluck(:name, :position, :group) }
          .from(
            [
              ["c", 8, "first"],
              ["b", 9, "first"],
              ["a", 10, "first"],
              ["d", 10, "second"]
            ]
          )
          .to(
            [
              ["c", 7, "first"],
              ["b", 8, "first"],
              ["d", 9, "first"], # updated record
              ["a", 10, "first"]
            ]
          )
      end

      context "when error while mobing record from given scope to another" do
        before do
          create(:decremental_sequence_model_with_many_scopes, group: "second")
          allow_any_instance_of(Orderable::Executor)
            .to receive(:adjust_in_current_scope).and_raise(StandardError)
        end

        let!(:expected_result) do
          [
            ["c", 8, "first"],
            ["b", 9, "first"],
            ["e", 9, "second"],
            ["a", 10, "first"],
            ["d", 10, "second"]
          ]
        end

        it "restores positions in previouse scope" do
          expect(DecrementalSequenceModelWithManyScopes.ordered.pluck(:name, :position, :group))
            .to eq(expected_result)
          expect { subject }.to raise_error(StandardError)
          expect(DecrementalSequenceModelWithManyScopes.ordered.pluck(:name, :position, :group))
            .to eq(expected_result)
        end
      end

      context "position value set as the maximum one" do
        let(:position) { 10 }

        it "sets the record position as the maximum one and increments the position of records above by 1" do
          expect { subject }
            .to change { DecrementalSequenceModelWithManyScopes.ordered.pluck(:name, :position, :group) }
            .from(
              [
                ["c", 8, "first"],
                ["b", 9, "first"],
                ["a", 10, "first"],
                ["d", 10, "second"]
              ]
            )
            .to(
              [
                ["c", 7, "first"],
                ["b", 8, "first"],
                ["a", 9, "first"],
                ["d", 10, "first"] # updated record
              ]
            )
        end
      end
    end

    context "only scope property updated" do
      subject { record.update!(group: "first") }
      let!(:record) { create(:decremental_sequence_model_with_many_scopes, group: "second") }

      it "sets record position as 0 by default and increments position of other records in scope by 1" do
        expect { subject }
          .to change { DecrementalSequenceModelWithManyScopes.ordered.pluck(:name, :position, :group) }
          .from(
            [
              ["c", 8, "first"],
              ["b", 9, "first"],
              ["a", 10, "first"],
              ["d", 10, "second"]
            ]
          )
          .to(
            [
              ["d", 7, "first"], # updated record
              ["c", 8, "first"],
              ["b", 9, "first"],
              ["a", 10, "first"]
            ]
          )
      end
    end

    context "other property updated" do
      subject { record.update!(name: "new name") }
      let!(:record) { create(:decremental_sequence_model_with_many_scopes, group: "first") }

      it "sets record name to new name and change neither position nor scope" do
        expect { subject }
          .to change { DecrementalSequenceModelWithManyScopes.ordered.pluck(:name, :position, :group) }
          .from(
            [
              ["d", 7, "first"],
              ["c", 8, "first"],
              ["b", 9, "first"],
              ["a", 10, "first"]
            ]
          )
          .to(
            [
              ["new name", 7, "first"],
              ["c", 8, "first"],
              ["b", 9, "first"],
              ["a", 10, "first"]
            ]
          )
      end
    end
  end

  context "model without validation" do
    subject { record.update(position: position) }

    before do
      create_list(:no_validation_model, 3)
      (7..9).each { |p| create(:no_validation_model, position: p) }
    end

    context "when record is being moved between other records" do
      let!(:record) { create(:no_validation_model) }
      let(:position) { 1 }

      it "sets the record position to 1 and adjust affected records" do
        expect { subject }
          .to change { NoValidationModel.ordered.pluck(:name, :position).to_h }
          .from(
            {
              "g" => 10,
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
  end

  context "model without validation and with one scope" do
    subject { record.update(kind: "first", position: position) }

    before do
      create_list(:no_validation_model_with_one_scope, 3, kind: "first")
      (7..9).each { |p| create(:no_validation_model_with_one_scope, position: p, kind: "first") }
    end

    context "when changing scope" do
      let!(:record) { create(:no_validation_model_with_one_scope, kind: "second") }

      context "when position attribute isn't specified" do
        let(:position) { nil }

        it "sets the record position to maximum_of_scope + 1 and don't do anything with other records" do
          expect { subject }
            .to change { NoValidationModelWithOneScope.ordered.pluck(:name, :position, :kind) }
            .from(
              [
                ["f", 9, "first"],
                ["e", 8, "first"],
                ["d", 7, "first"],
                ["c", 2, "first"],
                ["b", 1, "first"],
                ["a", 0, "first"],
                ["g", 0, "second"]
              ]
            ).to(
              [
                ["g", 10, "first"],
                ["f", 9, "first"],
                ["e", 8, "first"],
                ["d", 7, "first"],
                ["c", 2, "first"],
                ["b", 1, "first"],
                ["a", 0, "first"]
              ]
            )
        end
      end

      context "when record is being moved next to other records" do
        let(:position) { 1 }

        it "sets the record position to 1 and adjust affected records" do
          expect { subject }
            .to change { NoValidationModelWithOneScope.ordered.pluck(:name, :position, :kind) }
            .from(
              [
                ["f", 9, "first"],
                ["e", 8, "first"],
                ["d", 7, "first"],
                ["c", 2, "first"],
                ["b", 1, "first"],
                ["a", 0, "first"],
                ["g", 0, "second"]
              ]
            ).to(
              [
                ["f", 10, "first"],
                ["e", 9, "first"],
                ["d", 8, "first"],
                ["c", 3, "first"],
                ["b", 2, "first"],
                ["g", 1, "first"],
                ["a", 0, "first"]
              ]
            )
        end
      end
    end

    context "when changing position inside scope" do
      let!(:record) { create(:no_validation_model_with_one_scope, kind: "first") }

      context "when record is being moved next to other records" do
        let(:position) { 1 }

        it "sets the record position to 1 and adjust affected records" do
          expect { subject }
            .to change { NoValidationModelWithOneScope.ordered.pluck(:name, :position, :kind) }
            .from(
              [
                ["g", 10, "first"],
                ["f", 9, "first"],
                ["e", 8, "first"],
                ["d", 7, "first"],
                ["c", 2, "first"],
                ["b", 1, "first"],
                ["a", 0, "first"]
              ]
            ).to(
              [
                ["f", 10, "first"],
                ["e", 9, "first"],
                ["d", 8, "first"],
                ["c", 3, "first"],
                ["b", 2, "first"],
                ["g", 1, "first"],
                ["a", 0, "first"]
              ]
            )
        end
      end
    end
  end
end

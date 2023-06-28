# frozen_string_literal: true

RSpec.describe "Function :reorder" do
  context "with unsupported adapter" do
    before { allow(ModelWithManyScopes.connection).to receive(:adapter_name).and_return("SQLite3") }

    it "should throw an exception if the adapter is not supported" do
      expect { ModelWithManyScopes.reorder }.to raise_error(Orderable::AdapterError)
    end
  end

  context "with supported adapter" do
    before do
      create_list(:model_with_many_scopes, 3, :random_position)
      create_list(:model_with_many_scopes, 3, :random_position, kind: "beta")
    end

    let(:alpha_positions) { ModelWithManyScopes.ordered.where(kind: "alpha").pluck(:position) }
    let(:beta_positions) { ModelWithManyScopes.ordered.where(kind: "beta").pluck(:position) }

    before { ModelWithManyScopes.reorder }

    it "reset the positions and keeps the sequential order" do
      expect(alpha_positions).to eq((0..2).to_a)
      expect(beta_positions).to eq((0..2).to_a)
    end
  end

  context "without validation" do
    context "with incremental sequence" do
      context "with random positions" do
        before do
          create_list(:no_validation_model_with_many_scopes, 3, :random_position)
          create_list(:no_validation_model_with_many_scopes, 3, :random_position, kind: "beta")
        end

        let(:alpha_positions) { NoValidationModelWithManyScopes.ordered.where(kind: "alpha").pluck(:position) }
        let(:beta_positions) { NoValidationModelWithManyScopes.ordered.where(kind: "beta").pluck(:position) }

        before { NoValidationModelWithManyScopes.reorder }

        it "reset the positions and keeps the sequential order" do
          expect(alpha_positions).to eq((0..2).to_a)
          expect(beta_positions).to eq((0..2).to_a)
        end
      end

      context "with preset positions" do
        before do
          [1, 4, 8].each { |position| create(:no_validation_model_with_many_scopes, position: position) }
          [2, 5, 9].each { |position| create(:no_validation_model_with_many_scopes, position: position, kind: "beta") }
        end

        let(:alpha_positions) { NoValidationModelWithManyScopes.ordered.where(kind: "alpha").pluck(:position) }
        let(:beta_positions) { NoValidationModelWithManyScopes.ordered.where(kind: "beta").pluck(:position) }

        before { NoValidationModelWithManyScopes.reorder }

        it "reset the positions and keeps the sequential order" do
          expect(alpha_positions).to eq((0..2).to_a)
          expect(beta_positions).to eq((0..2).to_a)
        end
      end
    end

    context "with decremental sequence" do
      context "with random positions" do
        before do
          create_list(:decremental_sequence_no_validation_model_with_many_scopes, 3, :random_position)
          create_list(:decremental_sequence_no_validation_model_with_many_scopes, 3, :random_position, kind: "beta")
        end

        let(:alpha_positions) do
          DecrementalSequenceNoValidationModelWithManyScopes.ordered.where(kind: "alpha").pluck(:position)
        end
        let(:beta_positions) do
          DecrementalSequenceNoValidationModelWithManyScopes.ordered.where(kind: "beta").pluck(:position)
        end

        before { DecrementalSequenceNoValidationModelWithManyScopes.reorder }

        it "reset the positions and keeps the sequential order" do
          expect(alpha_positions).to eq((8..10).to_a)
          expect(beta_positions).to eq((8..10).to_a)
        end
      end

      context "with preset positions" do
        before do
          [8, 4, -2].each do |position|
            create(:decremental_sequence_no_validation_model_with_many_scopes, position: position)
          end
          [7, 2, -6].each do |position|
            create(:decremental_sequence_no_validation_model_with_many_scopes, position: position, kind: "beta")
          end
        end

        let(:alpha_positions) do
          DecrementalSequenceNoValidationModelWithManyScopes.ordered.where(kind: "alpha").pluck(:position)
        end
        let(:beta_positions) do
          DecrementalSequenceNoValidationModelWithManyScopes.ordered.where(kind: "beta").pluck(:position)
        end

        before { DecrementalSequenceNoValidationModelWithManyScopes.reorder }

        it "reset the positions and keeps the sequential order" do
          expect(alpha_positions).to eq((8..10).to_a)
          expect(beta_positions).to eq((8..10).to_a)
        end
      end
    end
  end

  context "with decremental sequence" do
    let(:alpha_positions) do
      DecrementalSequenceModelWithManyScopes.ordered.where(kind: "alpha").pluck(:position)
    end
    let(:beta_positions) do
      DecrementalSequenceModelWithManyScopes.ordered.where(kind: "beta").pluck(:position)
    end

    before do
      create_list(:decremental_sequence_model_with_many_scopes, 3, :random_position)
      create_list(:decremental_sequence_model_with_many_scopes, 3, :random_position, kind: "beta")
      DecrementalSequenceModelWithManyScopes.reorder
    end

    it "reset the positions and keeps the sequential order" do
      expect(alpha_positions).to eq((8..10).to_a)
      expect(beta_positions).to eq((8..10).to_a)
    end
  end
end

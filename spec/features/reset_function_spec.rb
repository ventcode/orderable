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
      expect(alpha_positions).to eq((0..2).to_a.reverse)
      expect(beta_positions).to eq((0..2).to_a.reverse)
    end
  end

  # TODO: Add more explicit tests
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

# frozen_string_literal: true

require "support/database_helper"
require "support/models"
require "factories/basic_model"

RSpec.describe "Function :reset" do
  context "with unsupported adapter" do
    before { allow(ModelWithManyScopes.connection).to receive(:adapter_name).and_return("SQLite3") }

    it "should throw an exception if the adapter is not supported" do
      expect { ModelWithManyScopes.reset_position }.to raise_error(Orderable::AdapterError)
    end
  end

  context "with supported adapter" do
    before do
      create_list(:model_with_many_scopes, 3, :random_position)
      create_list(:model_with_many_scopes, 3, :random_position, kind: "beta")
    end

    let(:alpha_positions) { ModelWithManyScopes.where(kind: "alpha").order(:position).pluck(:position) }
    let(:beta_positions) { ModelWithManyScopes.where(kind: "beta").order(:position).pluck(:position) }

    before { ModelWithManyScopes.reset_position }

    it "reset the positions and keeps the sequential order" do
      expect(alpha_positions).to eq((0..2).to_a)
      expect(beta_positions).to eq((0..2).to_a)
    end
  end
end

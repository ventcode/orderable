# frozen_string_literal: true

RSpec.describe "Configuration option :scope_name" do
  before { create_list(:custom_scope_name_model, 3) }

  it "executes custom scope name provided by the user" do
    expect(CustomScopeNameModel.ordered_by_orderable.pluck(:position))
      .to eq([2, 1, 0])
  end

  context "when default scope is used" do
    it "results in no method error" do
      expect { CustomScopeNameModel.ordered }.to raise_error(NoMethodError)
    end
  end
end

# frozen_string_literal: true

require "support/models"
require "factories/basic_model"

RSpec.shared_examples "does not affect outside of scope" do
  it "does not affect records outside of scope" do
    expect { action }.not_to change { out_of_scope.reload.position }
  end
end

RSpec.describe "Configuration option :scope" do
  context "for model with one scope" do
    before { create_list(:model_with_one_scope, 3) }

    let(:out_of_scope) { create(:model_with_one_scope, name: "other", position: 0, kind: "beta") }

    context "when creating a new record" do
      let(:action) { create(:model_with_one_scope, name: "d", position: 0) }

      include_examples "does not affect outside of scope"
    end

    context "when updating a record" do
      let(:action) { ModelWithOneScope.where(kind: "alpha").last.update(position: 0) }

      include_examples "does not affect outside of scope"
    end

    context "when destroying a record" do
      let(:action) { ModelWithOneScope.where(kind: "alpha").last.destroy }

      include_examples "does not affect outside of scope"
    end
  end

  context "for model with many scopes" do
    before { create_list(:model_with_many_scopes, 3) }

    let(:out_of_scope) { create(:model_with_many_scopes, name: "other", position: 0, kind: "beta", group: "b") }

    context "when creating a new record" do
      let(:action) { create(:model_with_many_scopes, name: "d", position: 0) }

      include_examples "does not affect outside of scope"
    end

    context "when updating a record" do
      let(:action) { ModelWithManyScopes.where(kind: "alpha", group: "a").last.update(position: 0) }

      include_examples "does not affect outside of scope"
    end

    context "when destroying a record" do
      let(:action) { ModelWithManyScopes.where(kind: "alpha", group: "a").last.destroy }

      include_examples "does not affect outside of scope"
    end
  end
end

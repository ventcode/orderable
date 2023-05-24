# frozen_string_literal: true

require "support/database_helper"
require "support/models"
require "factories/basic_model"

RSpec.describe "#destroy_all" do
  before do
    create_list(:model_with_many_scopes, 3, :random_position)
    create_list(:model_with_many_scopes, 3, :random_position, kind: "beta")
  end

  it "destroy all records" do
    expect { ModelWithManyScopes.destroy_all }.to change(ModelWithManyScopes, :count).to(0)
  end
end
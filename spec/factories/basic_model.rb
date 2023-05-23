# frozen_string_literal: true

require "support/models"

FactoryBot.define do
  factory :basic_model, class: BasicModel do
    sequence(:name, "a")
    sequence(:position, 0)

    factory :no_validation_model, class: NoValidationModel
    factory :no_default_push_last_model, class: NoDefaultPushLastModel
    factory :model_with_many_scopes, class: ModelWithManyScopes do
      group { "a" }
      kind { "alpha" }

      trait :random_position do
        position { rand(10) }
        to_create { |instance| instance.save(validate: false) }
      end
    end
    factory :model_with_one_scope, class: ModelWithOneScope do
      kind { "alpha" }
    end
  end
end

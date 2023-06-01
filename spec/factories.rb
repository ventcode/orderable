# frozen_string_literal: true

require_relative "./support/models"

FactoryBot.define do
  factory :basic_model, class: BasicModel do
    sequence(:name, "a")
  end

  factory :model_with_one_scope, class: ModelWithOneScope do
    sequence(:name, "a")
    kind { "alpha" }
  end

  factory :model_with_many_scopes, class: ModelWithManyScopes do
    sequence(:name, "a")
    group { "a" }
    kind { "alpha" }

    trait :random_position do
      position { rand(10) }
      to_create { |instance| instance.save(validate: false) }
    end
  end

  factory :no_validation_model, class: NoValidationModel do
    sequence(:name, "a")
  end

  factory :no_validation_model_with_one_scope, class: NoValidationModelWithOneScope do
    sequence(:name, "a")
    kind { "alpha" }
  end

  factory :no_default_push_front_model, class: NoDefaultPushFrontModel do
    sequence(:name, "a")
  end
end

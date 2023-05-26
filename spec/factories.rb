# frozen_string_literal: true

require_relative "./support/models"

FactoryBot.define do
  factory :basic_model, class: BasicModel do
    sequence(:name, "a")
    sequence(:position, 0)
  end

  factory :model_with_one_scope, class: ModelWithOneScope do
    sequence(:name, "a")
    sequence(:position, 0)
    kind { "alpha" }
  end

  factory :model_with_many_scopes, class: ModelWithManyScopes do
    sequence(:name, "a")
    sequence(:position, 0)
    group { "a" }
    kind { "alpha" }

    trait :random_position do
      position { rand(10) }
      to_create { |instance| instance.save(validate: false) }
    end
  end

  factory :no_validation_model, class: NoValidationModel do
    sequence(:name, "a")
    sequence(:position, 0)
  end

  factory :no_default_push_front_model, class: NoDefaultPushLastModel do
    sequence(:name, "a")
    sequence(:position, 0)
  end
end

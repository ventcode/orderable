# frozen_string_literal: true

require_relative "./support/models"

FactoryBot.define do
  factory :basic_model, class: BasicModel do
    sequence(:name, "a")

    factory :no_validation_model, class: NoValidationModel
    factory :no_auto_set_model, class: NoDefaultPushFrontModel
    factory :from_model, class: FromModel
    factory :decremental_sequence_model, class: DecrementalSequenceModel
  end

  factory :model_with_one_scope, class: ModelWithOneScope do
    sequence(:name, "a")
    kind { "alpha" }

    factory :no_validation_model_with_one_scope, class: NoValidationModelWithOneScope
  end

  factory :model_with_many_scopes, class: ModelWithManyScopes do
    sequence(:name, "a")
    group { "a" }
    kind { "alpha" }

    trait :random_position do
      position { rand(10) }
      to_create { |instance| instance.save(validate: false) }
    end

    factory :no_validation_model_with_many_scopes, class: NoValidationModelWithManyScopes
    factory :decremental_sequence_no_validation_model_with_many_scopes,
            class: DecrementalSequenceNoValidationModelWithManyScopes
    factory :decremental_sequence_model_with_many_scopes, class: DecrementalSequenceModelWithManyScopes
  end
end

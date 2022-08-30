# frozen_string_literal: true

require 'support/models'

FactoryBot.define do
  factory :scopes_model, class: ModelWithManyScopes do
    sequence(:name, 'a')
    sequence(:position, 0)
    group { 'a' }
    kind { 'alpha' }

    trait :random_position do
      position { rand(10) }
      to_create { |instance| instance.save(validate: false) }
    end
  end
end

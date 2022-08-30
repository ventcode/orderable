# frozen_string_literal: true

require 'support/models'

FactoryBot.define do
  factory :basic_model, class: BasicModel do
    sequence(:name, 'a')
    sequence(:position, 0) { |n| n }

    factory :no_validation_model, class: NoValidationModel
    factory :no_default_push_last_model, class: NoDefaultPushLastModel
  end
end

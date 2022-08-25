# frozen_string_literal: true

FactoryBot.define do
  trait :random_position do
    position { (0..20).to_a.sample }
  end
end

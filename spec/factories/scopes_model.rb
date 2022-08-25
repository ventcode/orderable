# frozen_string_literal: true

require 'support/models'
require 'support/factory_bot_helper'

include FactoryBotHelper

FactoryBot.define do
  factory :ScopesModel do
    name { generate_string(length: 2) }
    kind {  generate_string(length: 3) }
    group { generate_string(length: 1) }
    position { 0 }
  end

  trait :random_position do
    position { (0..20).to_a.sample }
  end
end

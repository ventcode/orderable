# frozen_string_literal: true

require 'support/models'
require 'support/factory_bot_helper'

include FactoryBotHelper

FactoryBot.define do
  factory :NoValidationModel do
    name { generate_string(length: 3) }
    position { 0 }
  end
end

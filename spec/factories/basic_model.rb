# frozen_string_literal: true

require 'support/models'
require 'support/factory_bot_helper'

FactoryBot.define do
  factory :BasicModel do
    name { FactoryBotHelper.generate_string(length: 3) }
    position { 0 }
  end
end

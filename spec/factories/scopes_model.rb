# frozen_string_literal: true

require 'support/models'
require 'support/factory_bot_helper'

FactoryBot.define do
  factory :ScopesModel do
    name { FactoryBotHelper.generate_string(length: 2) }
    kind {  FactoryBotHelper.generate_string(length: 3) }
    group { FactoryBotHelper.generate_string(length: 1) }
    position { 0 }
  end
end

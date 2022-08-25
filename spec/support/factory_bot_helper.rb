# frozen_string_literal: true

module FactoryBotHelper
  def self.generate_string(length: 5)
    raise StandardError, 'length must be greater or equal to 1' if length < 1

    name = []
    length.times { name << ('a'..'z').to_a[(0..25).to_a.sample] }
    name.join
  end
end

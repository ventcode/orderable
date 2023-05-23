# frozen_string_literal: true

RSpec.describe Orderable do
  it "has a version number" do
    expect(Orderable::VERSION).not_to be nil
  end

  it "extends ActiveRecord::Base" do
    expect(ActiveRecord::Base).to respond_to(:orderable)
  end
end

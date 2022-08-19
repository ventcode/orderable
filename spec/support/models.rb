# frozen_string_literal: true

class BasicModel < ActiveRecord::Base
  has_many :addons

  orderable :position
end

class Addon < ActiveRecord::Base
  belongs_to :BasicModel

  orderable :position, scope: :basic_model_id
end

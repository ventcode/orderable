# frozen_string_literal: true

class BasicModel < ActiveRecord::Base
  has_many :addons

  orderable :position
end

class NoValidationModel < ActiveRecord::Base
  self.table_name = 'basic_models'

  orderable :position, validate: false
class Addon < ActiveRecord::Base
  belongs_to :BasicModel

  orderable :position, scope: :basic_model_id
end

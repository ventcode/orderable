# frozen_string_literal: true

class BasicModel < ActiveRecord::Base
  orderable :position
end

class NoValidationModel < ActiveRecord::Base
  self.table_name = 'basic_models'

  orderable :position, validate: false
end

class NoDefaultPushLastModel < ActiveRecord::Base
  self.table_name = 'basic_models'

  orderable :position, default_push_last: false
end

class NoDefaultModel < ActiveRecord::Base
  orderable :position, default_push_last: false
end

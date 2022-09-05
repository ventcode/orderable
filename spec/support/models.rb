# frozen_string_literal: true

class BasicModel < ActiveRecord::Base
  orderable :position
end

class ModelWithOneScope < ActiveRecord::Base
  orderable :position, scope: :kind
end

class ModelWithManyScopes < ActiveRecord::Base
  orderable :position, scope: %i[kind group]
end

class NoValidationModel < ActiveRecord::Base
  self.table_name = 'basic_models'

  orderable :position, validate: false
end

class NoDefaultPushLastModel < ActiveRecord::Base
  self.table_name = 'basic_models'

  orderable :position, default_push_last: false
end

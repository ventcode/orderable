# frozen_string_literal: true

class DefaultModel < ActiveRecord::Base
  self.table_name = "basic_models"
end

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
  self.table_name = "basic_models"

  orderable :position, validate: false
end

class NoValidationModelWithOneScope < ActiveRecord::Base
  self.table_name = "model_with_one_scopes"

  orderable :position, scope: :kind, validate: false
end

class NoDefaultPushFrontModel < ActiveRecord::Base
  self.table_name = "basic_models"

  orderable :position, auto_set: false
end

class CustomScopeNameModel < ActiveRecord::Base
  self.table_name = "basic_models"

  orderable :position, scope_name: :ordered_by_orderable
end

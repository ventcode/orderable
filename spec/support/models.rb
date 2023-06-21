# frozen_string_literal: true

class BasicModel < ActiveRecord::Base
  orderable :position
end

class FromModel < ActiveRecord::Base
  self.table_name = "basic_models"

  orderable :position, from: 100
end

class DescDirectionModel < ActiveRecord::Base
  self.table_name = "basic_models"

  orderable :position, direction: :desc, from: 10
end

class ModelWithOneScope < ActiveRecord::Base
  orderable :position, scope: :kind
end

class ModelWithManyScopes < ActiveRecord::Base
  orderable :position, scope: %i[kind group]
end

class DescModelWithManyScopes < ActiveRecord::Base
  self.table_name = "model_with_many_scopes"

  orderable :position, scope: %i[kind group], direction: :desc, from: 10
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

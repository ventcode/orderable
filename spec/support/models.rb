# frozen_string_literal: true

class BasicModel < ActiveRecord::Base
  orderable :position
end

class FromModel < ActiveRecord::Base
  self.table_name = "basic_models"

  orderable :position, from: 100
end

class DecrementalSequenceModel < ActiveRecord::Base
  self.table_name = "basic_models"

  orderable :position, sequence: :decremental, from: 10
end

class NoValidationModel < ActiveRecord::Base
  self.table_name = "basic_models"

  orderable :position, validate: false
end

class NoDefaultPushFrontModel < ActiveRecord::Base
  self.table_name = "basic_models"

  orderable :position, auto_set: false
end

class ModelWithOneScope < ActiveRecord::Base
  orderable :position, scope: :kind
end

class NoValidationModelWithOneScope < ActiveRecord::Base
  self.table_name = "model_with_one_scopes"

  orderable :position, scope: :kind, validate: false
end

class ModelWithManyScopes < ActiveRecord::Base
  orderable :position, scope: %i[kind group]
end

class DecrementalSequenceModelWithManyScopes < ActiveRecord::Base
  self.table_name = "model_with_many_scopes"

  orderable :position, scope: %i[kind group], sequence: :decremental, from: 10
end

class NoValidationModelWithManyScopes < ActiveRecord::Base
  self.table_name = "model_with_many_scopes"

  orderable :position, scope: %i[kind group], validate: false
end

class DecrementalSequenceNoValidationModelWithManyScopes < ActiveRecord::Base
  self.table_name = "model_with_many_scopes"

  orderable :position, scope: %i[kind group], validate: false, sequence: :decremental, from: 10
end

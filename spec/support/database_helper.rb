# frozen_string_literal: true

ActiveRecord::Base.establish_connection(
  adapter: 'postgresql',
  database: 'orderable_development'
)

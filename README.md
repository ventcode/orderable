# Orderable

A gem that makes it easy to change the default order of Postgresql database rows by the addition of a modifiable integer column.

### Example of usage
Lets consider the AR **image** model that implements the `orderable` method. Its position field name is set as `position` and it has only 2 properties - `id` and `name`. **Images** table content is presented below.

| id | name | position |
|----|-----|----------|
|1|"A"|1|
|2|"B"|2|
|3|"C"|0|

```ruby
class Image < ApplicationRecord
  orderable :position
end

Image.pluck(:name, :position) # => [["A", 1], ["B", 2], ["C", 0]]
Image.ordered.pluck(:name) # => ["B", "A", "C"]

# On create
image = Image.create(name: "D")
image.position # => 3
Image.ordered.pluck(:name) #=> ["D", B", "A", "C"]

# On update
image.update(position: 2)
Image.ordered.pluck(:name) # => ["B", "D", "A", "C"]

# On destroy
image.destroy
Image.ordered.pluck(:name) #=> ["B", "A", "C"]
```
## Features

- Generate migration to add positioning field
- Automatic reordering on CRUD operations of the Active Record models
- Configurable positioning

## Installation

### Install gem
Add this line to your application's Gemfile:

```ruby
gem 'orderable'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install orderable

### Use `structure.sql` instead of `schema.rb`
This is helpful for rebuilding your DB and maintain correct indexes.
If you already use `structure.sql` you can skip this point.

If not, add this line to your `config/application.rb`:
```ruby
module YourApp
  class Application < Rails::Application
    config.load_defaults 6.0

    # Add this line:
    config.active_record.schema_format = :sql
  end
end
```
Now run:
```sh
    $ rails db:migrate
```
After execution you should see `db/structure.sql` file.

## Usage
### 1. Add positioning field to your table
For this purpose we recommend using our migration generator. In your rails' project directory type command:
```sh
    $ rails generate orderable:migration {ModelName}:{FieldName} {Scopes} 
```
- `ModelName`: name of model to be made orderable [^1]
- `FieldName`: name of field to be created and used as positioning field
- `Scopes`: additional scopes separated with spaces for uniqueness index for `FieldName`

[^1]: to be precise it is singularized table name. If you have set the custom table_name property at your AR model you can specify TableName here or simply change it manually in migration to correct value.

Generated migration should be in your `db/migrate` directory.

**Example:**
Consider an `Image` model with foreign keys for `Owner` and `Project`, we run command
```sh
    $ rails generate orderable:migration Image:position owner_id project_id
```
This will generate migration adding `position` field on `images` with unique index on `position`, `owner_id` and `project_id`. 
It should look like that:
```ruby
class AddUniqueOrderablePositionToImage < ActiveRecord::Migration[6.1]
  def up
    add_column :images, :position, :integer

    execute <<-SQL
      ALTER TABLE "images"
        ADD UNIQUE("position", "owner_id", "project_id") DEFERRABLE INITIALLY DEFERRED
    SQL
  end
  def down
    remove_column :images, :position
  end
end
```
Next step is to migrate database with:
```sh
    $ rails db:migrate
```
If everything was configured properly, after command execution you should see your new field and index in `db/structure.sql`

### 2. Use Orderable in your model
To use orderable on added column you need to specify it in model by calling `orderable` method:
```ruby
orderable {fieldNameHash}
```
Optional named arguments:
| Attribute | Value | Description |
| - | - | - |
| `scope` | array of hashes | scope same as in unique index (uniqueness of this fields combintion would be ensured) |
| `validate` | boolean | if `true` validates numericality of positioning field and being in range `0 <= value <= M` where `M` is biggest correct value for operation |
| `default_push_front` | boolean | if `true`, when positioning field is not specified during creation, by default it adds it on front (the new biggest value of this field) |
|`scope_name`| symbol | based on this property additional scope is added to AR model - by default scope_name is set to `ordered`

```ruby
class Image < ActiveRecord::Base
    orderable :position, scope: %i[owner_id product_id]
    
    # ...
end
```
## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

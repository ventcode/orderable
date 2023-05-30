# Orderable

A gem that makes it easy to change the default order of Postgresql database rows by the addition of a modifiable integer column.

### Usage example
Let's consider the AR **image** model that implements the `orderable` method. Its position field name is set as `position` and it has only 2 properties - `id` and `name`. **Images** table content is presented below.

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
image.destroy()
Image.ordered.pluck(:name) #=> ["B", "A", "C"]
```
## Features

- Migration generation to add positioning field
- Automatic reordering on CRUD operations of the Active Record models
- Configurable record positioning

## Installation

### Install gem
Install the orderable gem from Rubygems:

    $ gem install orderable
    
_or_

Add this line to your application's Gemfile:

```ruby
gem 'orderable', 'VERSION'
```

Then run:

    $ bundle install

## Usage
### 1. Generate Migration
To do this, we recommend using our migration generator. In the rails project directory, type the command:
```sh
    $ rails generate orderable:migration model_name:field_name scopes
```
- `model_name`: name of the AR model to make it orderable [^1]
- `field_name`: name of the field that will be used for positioning
- `scopes`: additional scopes separated with spaces used to put unique index on the group

[^1]: to be precise it is singularized table name. If you have set the custom table_name property at your AR model you can specify TableName here or simply change it manually in migration to correct value.

Generated migration will be placed in your default `db/migrate` directory.

**Example:**
Let's consider a `Image` model with foreign keys for `Owner` and `Project`. The following command is run:
```sh
    $ rails generate orderable:migration Image:position owner_id project_id
```
This will generate migration adding `position` column to `images` table with unique index on `position`, `owner_id` and `project_id`. 

The next step is to migrate database with:
```sh
    $ rails db:migrate
```

**Note**
Currently, the default Rails `schema` does not support [deferrable unique index](www.o2.pl). If you want to ensure uniqueness on orderable field, you need to change it to `structure schema`. For more information on how to do it, see the [link](https://guides.rubyonrails.org/active_record_migrations.html#types-of-schema-dumps).

### 2. Include Orderable in your model
To use orderable on added column you need to specify it in model by calling `orderable` method:
```ruby
orderable :[orderable_field_name]
```
Optional named arguments:
| Attribute | Value | Description |
| - | - | - |
| `scope` | array of hashes | scope same as in unique index (uniqueness of this fields combintion would be ensured) |
| `validate` | boolean | if `true` validates numericality of positioning field and being in range `0 <= value <= M` where `M` is biggest correct value for operation |
| `default_push_front` | boolean | if `true`, when positioning field is not specified during creation, by default it adds it on front (the new biggest value of this field) |
|`scope_name`| symbol | based on this property additional scope is added to AR model - by default scope_name is set to `ordered`

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

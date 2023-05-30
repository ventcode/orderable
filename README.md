# Orderable

A gem that makes it easy to change the default order of PostgreSQL database rows by the addition of a modifiable integer column.

## Features

- Automatic reordering on Active Record CRUD operations
- Configurable record positioning
- Positioning field migration generator

## Table of contents

* [Basic usage](#usage)
* [Installation](#installation)
* [Generate migration](#generate-migration)
* [Include orderable in AR model](#include-orderable-in-ar-model)
* [Usage examples](#usage-examples)
  * [Model with scope](#model-with-scope)
  * [Default push front](#default-push-front)
	* [Disabling validation](#disabling-validation)
	* [Custom scope name](#custom-scope-name)
* [License](#license)
### Basic usage
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

# on create
image = Image.create(name: "D")
image.position # => 3
Image.ordered.pluck(:name) #=> ["D", B", "A", "C"]

# on update
image.update(position: 2)
Image.ordered.pluck(:name) # => ["B", "D", "A", "C"]

# on destroy
image.destroy()
Image.ordered.pluck(:name) #=> ["B", "A", "C"]
```
### Installation

Install the orderable gem from Rubygems:

    $ gem install orderable
    
_or_

Add this line to your application's Gemfile:

```ruby
gem 'orderable', 'VERSION'
```

Then run:

    $ bundle install

### Generate migration
In the *Rails* project directory, type the command:
```sh
    $ rails generate orderable:migration model_name:field_name scopes
```
- `model_name`: name of the AR model to make it orderable [^1]
- `field_name`: name of the field that will be used for positioning
- `scopes`: additional scopes separated with spaces used to put unique index on the group

[^1]: to be precise it is singularized table name. If you have set the custom `table_name` property at your AR model you can specify TableName here or simply change it manually in migration to correct value.

Generated migration will be placed in your default migrations directory `db/migrate` .

**Example:**
Let's consider an `Image` model with foreign keys for `Owner` and `Project`. The following command should be run:
```sh
    $ rails generate orderable:migration Image:position owner_id project_id
```
This will generate migration adding `position` column to `images` table with unique index on `position`, `owner_id` and `project_id`. 

The next step is to migrate database with:
```sh
    $ rails db:migrate
```

***Note***
*Currently, the default Rails `schema` does not support [deferrable unique index](https://dba.stackexchange.com/questions/166082/deferrable-unique-index-in-postgres). If you want to ensure uniqueness on orderable field, you need to change it to `structure schema`. For more information on how to do it, see the [link](https://guides.rubyonrails.org/active_record_migrations.html#types-of-schema-dumps).*

### Include orderable in AR model
To use orderable on added column you need to specify it in model by calling `orderable` method:
```ruby
orderable :orderable_field_name
```
Optional named arguments:
| Attribute | Value | Description |
| - | - | - |
| `scope` | array of symbols | scope same as in unique index (uniqueness of this fields combintion would be ensured) |
| `validate` | boolean | if `true`, it validates numericality of positioning field, as well as being in range `<0, M>`, where `M` stands for the biggest positioning field value |
| `default_push_front` | boolean | if `true`, it sets a new record in front of other records unless position field is passed directly
|`scope_name`| symbol | based on this property additional scope is added to AR model - by default it is set to `ordered`

### Usage Examples

#### Model with scope

```ruby
class Image < ActiveRecord::Base
  orderable :position, scope: :group
end

Image.pluck(:name, :position, :group) # => [["A", 0, "G_1"], ["E", 1, "G_2"], ["C", 2, "G_1"], ["B", 1, "G_1"], ["D", 0, "G_2"]]
Image.ordered.pluck(:name) # => ["C", "B", "A", "E", "D"]

# on create
image = Image.create(name: "F", group: "G_1")
image.position # => 3
Image.ordered.pluck(:name) #=> ["F" ,"C", "B", "A", "E", "D"]

# on update
image.update(group: "G_2")
image.position # => 2
Image.ordered.pluck(:name) #=> ["C", "B", "A", "F", "E", "D"]

image.update(position: 1)
Image.ordered.pluck(:name) #=> ["C", "B", "A", "E", "F", "D"]

# on destroy
image.destroy()
Image.ordered.pluck(:name) #=> ["F" ,"C", "B", "A", "E", "D"]
```
#### Default push front

```ruby
class Image < ActiveRecord::Base
  orderable :position, default_push_front: false
end

Image.create(name: "A") # => validation error (position is not specified)
Image.create(name: "A", position: 0) # => OK
Image.create(name: "B", position: 0) # => OK
Image.ordered.pluck(:name, :position) # => [["A", 1], ["B", 0]]
```
#### Disabling validation

```ruby
class Image < ActiveRecord::Base
  orderable :position, validation: true # by default
end

class Post < ActiveRecord::Base
  orderable :position, validation: false
end

Image.count # => 0
Post.count # => 0

Image.create(name: "A", position: -1)  # => validation error (cannot be negative)
Image.create(name: "A", position: 1) # =>  validation error (no image with position 0)
Post.create(title: "A title", position: -1) # => OK
```
#### Custom scope name

```ruby
class Image < ActiveRecord::Base
  orderable :position, scope_name: :ordered_by_orderable
end

Image.pluck(:name, :position) # => [["A", 0], ["B, 1"]]
Image.ordered_by_orderable.pluck(:name, :position) # => [["B", 1], ["A", 0]]
```

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

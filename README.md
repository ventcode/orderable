# Orderable
[![Test Coverage](https://ventcode.github.io/orderable/test-coverage.svg)](#)
[![Ruby Style Guide](https://img.shields.io/badge/code_style-rubocop-brightgreen.svg)](https://github.com/rubocop/rubocop)
[![Test and Coverage Workflow](https://github.com/ventcode/orderable/actions/workflows/coverage.yml/badge.svg)](.github/workflows/coverage.yml)


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
  * [Model with a scope](#model-with-a-scope)
  * [Auto set](#auto-set)
  * [Disabling validation](#disabling-validation)
  * [Setting from value](#setting-from-value)
  * [Decremental sequence](#decremental-sequence)
* [License](#license)
### Basic usage
Let's consider the AR **image** model that implements the `orderable` method. Its positioning field name is set as `position` and it has only 2 properties - `id` and `label`. **Images** table content is presented below.

| id | name | position |
|----|-----|----------|
|1|"A"|1|
|2|"B"|2|
|3|"C"|0|

```ruby
class Image < ApplicationRecord
  orderable :position
end

Image.pluck(:label, :position) # => [["A", 1], ["B", 2], ["C", 0]]
Image.ordered.pluck(:label) # => ["C", "A", "B"]

# on create
image = Image.create(label: "D")
image.position # => 3
Image.ordered.pluck(:label) # => ["C", "A", "B", "D"]

# on update
image.update(position: 2)
Image.ordered.pluck(:label) # => ["C", "A", "D", "B"]

# on destroy
image.destroy()
Image.ordered.pluck(:label, :position) # => [["C", 0], ["A", 1], ["B", 2]]
```

Notice that you can pass direction `:asc`/`:desc` to `ordered` scope as parameter:
```ruby
Image.pluck(:label, :position) # => [["A", 1], ["B", 2], ["C", 0]]

# :asc by default
Image.ordered.pluck(:label) # => ["C", "A", "B"]
Image.ordered(:asc).pluck(:label) # => ["C", "A", "B"]

# :desc
Image.ordered(:desc).pluck(:label) # => ["B", "A", "C"]
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

    $ rails generate orderable:migration table_name:field_name scopes

- `table_name`: name of the table for which positioning field migration will be generated
- `field_name`: name of the new column that will be added and used for positioning
- `scopes`: additional scopes separated with spaces used to put unique index on the whole group

Generated migration will be placed in your default migrations directory `db/migrate` .

**Example:**
Let's consider an `Image` model with foreign keys for `Owner` and `Project`. The following command should be run:

    $ rails generate orderable:migration Image:position owner_id project_id

This will generate migration adding `position` column to `images` table with unique index on `position`, `owner_id` and `project_id`. 

The next step is to migrate database with:

    $ rails db:migrate

***Note***
*Currently, the default Rails `schema` does not support [deferrable unique index](https://dba.stackexchange.com/questions/166082/deferrable-unique-index-in-postgres). If you want to ensure uniqueness on orderable field after rebuilding the database from schema, you need to change it to `structure schema`. For more information on how to do it, see the [link](https://guides.rubyonrails.org/active_record_migrations.html#types-of-schema-dumps).*

### Include orderable in AR model
To use orderable on added column you need to specify it in model by calling `orderable` method:
```ruby
orderable :orderable_field_name
```
**Optional named arguments:**
| Attribute | Value | Default | Description |
| - | - | - | - |
| `scope` | array of symbols | `[]` | scope same as in unique index (uniqueness of this fields combination would be ensured) |
| `auto_set` | boolean | `true` | if `true` and positioning field value is not specified, it inserts a new record on the bottom for decremental sequence or on the top for incremental sequence on create |
| `sequence` | `:incremental` or `:decremental` | `:incremental` | value used to determine positioning sequence |
| `validate` | boolean | `true` | if `true`, it validates numericality of positioning field value, as well as being in range `<0, M>`, where `M` stands for the biggest positioning field value |
|`from`| integer | 0 | base value from which sequence starts |

### Usage Examples

#### Model with a scope
Let's say a user has few cover and profile photos. Using *orderable* with scope will allow user to customize their order separately.

```ruby
class Photo < ActiveRecord::Base
  orderable :position, scope: :type

  scope :profile, -> { where(type: 'profile') }
  scope :cover, -> { where(type: 'cover') }
end

Photo.pluck(:label, :position, :type) # => [["A", 0, "profile"], ["E", 1, "cover"], ["C", 2, "profile"], ["B", 1, "profile"], ["D", 0, "cover"]]
Photo.ordered.pluck(:label) # => ["A", "B",  "C", "D", "E"]
Photo.profile.ordered.pluck(:label, :position) # => [["A", 0], ["B", 1],  ["C", 2]]
Photo.cover.ordered.pluck(:label, :position) # => [["D", 0], ["E", 1]]

# on create
photo = Photo.create(label: "F", type: "profile")
photo.position # => 3
Photo.profile.ordered.pluck(:label, :position) # => [["A", 0], ["B", 1],  ["C", 2], ["F", 3]]
Photo.cover.ordered.pluck(:label, :position) # => [["D", 0], ["E", 1]]

# on update
photo.update(type: "cover")
photo.position # => 2
Photo.profile.ordered.pluck(:label, :position) # => [["A", 0], ["B", 1],  ["C", 2]]
Photo.cover.ordered.pluck(:label, :position) # => [["D", 0], ["E", 1], ["F", 2]]

photo.update(position: 1)
Photo.profile.ordered.pluck(:label, :position) # => [["A", 0], ["B", 1],  ["C", 2]]
Photo.cover.ordered.pluck(:label, :position) # => [["D", 0], ["F", 1], ["E", 2]]

# on destroy
photo.destroy()
Photo.profile.ordered.pluck(:label, :position) # => [["A", 0], ["B", 1],  ["C", 2]]
Photo.cover.ordered.pluck(:label, :position) # => [["D", 0], ["E", 1]]
```
#### Auto set

```ruby
class Image < ActiveRecord::Base
  orderable :position, auto_set: true # by default
end

image = Image.create(label: "A") # => OK
image.position # => 0
image = Image.create(label: "B") # => OK
Image.ordered.pluck(:label, :position) # => [["A", 0], ["B", 1]]


class Post < ActiveRecord::Base
  orderable :position, auto_set: false
end

Post.create(title: "A") # => validation error (position is not specified)
Post.create(title: "A", position: 0) # => OK
Post.create(title: "B", position: 0) # => OK
Post.ordered.pluck(:title, :position) # => [["B", 0], ["A", 1]]
```
#### Disabling validation

```ruby
class Image < ActiveRecord::Base
  orderable :position, validation: true # by default
end

Image.count # => 0
Image.create(label: "A", position: -1)  # => validation error (cannot be negative)
Image.create(label: "A", position: 1) # =>  validation error (no image with position 0)


class Post < ActiveRecord::Base
  orderable :position, validation: false
end

Post.count # => 0
Post.create(title: "A title", position: -1) # => OK
```
#### Setting from value

```ruby
class Image < ActiveRecord::Base
  orderable :position, from: 10
end

Image.create(label: "A")
Image.create(label: "B")
Image.ordered.pluck(:label, :position) # => [["A", 10], ["B", 11]]
```

#### Decremental sequence

```ruby
class Image < ActiveRecord::Base
  orderable :position, from: 10, sequence: :decremental
end

Image.create(label: "A")
Image.create(label: "B")
Image.create(label: "C")
Image.ordered.pluck(:label, :position) # => [["C", 8], ["B", 9], ["A", 10]]
```

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

# Validation Delegation

Validation delegation allows an object to proxy validations to other objects. This facilitates [composition](http://en.wikipedia.org/wiki/Object_composition) and prevents the duplication of validation logic.

## Installation

Add this line to your application's Gemfile:

    gem 'validation_delegation'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install validation_delegation

## Usage

An example use case for validation delegation is a `SignUp` object which simultaneously creates a `User` and an `Organization`. The `SignUp` object is only valid if both the user and organization are valid.

```Ruby
class User < ActiveRecord::Base
  validates :email, presence: true
end

class Organization < ActiveRecord::Base
  validates :name, presence: true
end

class SignUp
  include ActiveModel::Validations
  include ValidationDelegation

  # delegate validation to the user
  delegate_validation to: :user

  # and also delegate validation to the organization
  delegate_validation to: :organization

  attr_reader :user, :organization

  def initialize
    @user = user
    @organization = organization
  end

  def email=(email)
    @user.email = email
  end

  def name=(name)
    @organization.name = name
  end
end
```

Assigning invalid user and organization attributes, which are in turn assigned to the `@user` and `@organization` instance variables, invalidates the `SignUp`, and faithfully copies the user and organization errors.

```Ruby
signup = SignUp.new
signup.email = ""
signup.name = ""

signup.valid?
# => false

signup.errors.full_messages
# => ["email can't be blank", "name can't be blank"]

```

```Ruby
signup.email = "email@example.com"
signup.name = "My Organization"

signup.valid?

```

If you do not want to copy errors directly onto the composing object, you can specify to which attribute the errors should apply. In this case, we copy errors onto the "organization" attribute. This is useful for nesting forms via `fields_for`.

```Ruby
class SignUp
  include ActiveModel::Model
  include ValidationDelegation

  delegate_validation :organization, to: :organization

  attr_reader :organization

  def initialize
    @organization = Organization.new
  end

  def name=(name)
    @organization.name = name
  end
end

signup = SignUp.new
signup.name = ""
signup.valid?
# => false

signup.errors.full_messages
# => ["organization name can't be blank"]
```

### Options

`delegate_validation` accepts several options.

- `:if` - errors are only copied if the method specified by the `:if` option returns true

```Ruby
class SignUp
  # ...

  delegate_validation to: :user, if: :validate_user?

  def validate_user?
    # logic
  end
end
```

- `:unless` - errors are only copied if the method specified by the `:unless` option returns false

```Ruby
class SignUp
  # ...

  delegate_validation to: :user, unless: :skip_validation?

  def skip_validation?
    # logic
  end
end
```

- `:only` - a whitelist of errors to be copied

```Ruby
class SignUp
  # ...

  delegate_validation to: :user, only: :email
end

signup = SignUp.new
signup.user.errors.add(:email, :required)
signup.user.errors.add(:phone_number, :required)

signup.valid?
signup.errors.full_messages
# => ["email can't be blank"]
```

- `:except` - a blacklist of errors to be copied

```Ruby
class SignUp
  # ...

  delegate_validation to: :user, except: :email
end

signup = SignUp.new
signup.user.errors.add(:email, :required)
signup.user.errors.add(:phone_number, :required)

signup.valid?
signup.errors.full_messages
# => ["phone number can't be blank"]
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## About Foraker Labs

![Foraker Logo](http://assets.foraker.com/attribution_logo.png)

Foraker Labs builds exciting web and mobile apps in Boulder, CO. Our work powers a wide variety of businesses with many different needs. We love open source software, and we're proud to contribute where we can. Interested to learn more? [Contact us today](https://www.foraker.com/contact-us).

This project is maintained by Foraker Labs. The names and logos of Foraker Labs are fully owned and copyright Foraker Design, LLC.

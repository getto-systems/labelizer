# Labelizer

[![Build Status](https://travis-ci.org/getto-systems/labelizer.svg?branch=master)](https://travis-ci.org/getto-systems/labelizer)
[![Gem Version](https://badge.fury.io/rb/labelizer.svg)](https://badge.fury.io/rb/labelizer)

add labels to attribute

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'labelizer'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install labelizer

## Usage

```ruby
# config/initializers/labelizer.rb
Labelizer.configure do |config|
  config.labels = %w(label description color)
end
```

```yaml
# config/locales/labelizer.ja.yml
ja:
  labelizer:
    customer:
      registration_state:
        starting:
          label: start
          description: registration starting...
          color: label label-info
        confirming:
          label: start
          description: registration confirming...
          color: label label-warning
        completed:
          label: start
          description: registration completed!!
          color: label label-success
```

```ruby
# app/models/my_model.rb
class Customer < ApplicationModel
  enum registration_state: {
    starting: 0,
    confirming: 1,
    completed: 2,
  }

  include Labelizer

  labelize :registration_state
end
```

```erb
# app/views/customers/show.html.erb
<% customer = Customer.find id %>

<%# status label %>
<span class="<%= customer.registration_state_color %>"><%= customer.registration_state_label %></span>

<% labels = customer.registration_state_labelized %>
<span class="<%= labels[:color] %>"><%= labels[:label] %></span>

<% labels = customer.labelized[:registration_state] %>
<span class="<%= labels[:color] %>"><%= labels[:label] %></span>

<%# description %>
<ul>
  <%# Customer.registration_states # => define by enum %>
  <% Customer.registration_states.each do |state,value| %>
    <% labels = Customer.labelized[:registration_state][state] %>
    <li><%= labels[:label] %> : <%= labels[:description] %></li>
  <% end %>
</ul>
```

## Converters

Convert label:

```ruby
# config/initializers/labelizer.rb
Labelizer.configure do |config|
  config.converter = {
    color: ->(value){
      # value : attribute value
      "label label-#{value}"
    },
  }
end
```

```yaml
ja:
  labelizer:
    customer:
      registration_state:
        starting:
          color: info
```

```ruby
Customer.starting.last.color # => "label label-info"
```

## default labels

```yaml
ja:
  labelizer:
    color: ... # <= global default
    customer:
      color: ... # <= model default
      registration_state:
        color: ... # <= attribute default
        starting:
          color: ...
```

## outside rails

```ruby
class Customer
  include Labelizer

  def self.model_name
    OpenStruct.new i18n_key: :customer
  end

  labelize ...
end
```


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/getto-systems/labelizer.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).


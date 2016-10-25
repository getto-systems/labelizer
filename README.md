# Labelizer

add labels to enum

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
  config.file_path = Rails.root("config/labelizer.yml")
  config.cache = Rails.env.production? # cache yml
  config.labels = %w(label description color)
end
```

```yaml
# config/labelizer.yml
ja:
  labelizer:
    customer:
      registration_state:
        starting:
          label: start
          description: registration starting...
          color: info
        confirming:
          label: start
          description: registration confirming...
          color: warning
        completed:
          label: start
          description: registration completed!!
          color: success
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
<span class="label label-<%= customer.registration_state_color %>"><%= customer.registration_state_label %></span>

<% labels = customer.registration_state_labelized %>
<span class="label label-<%= labels[:color] %>"><%= labels[:label] %></span>

<% labels = customer.labelized[:registration_state] %>
<span class="label label-<%= labels[:color] %>"><%= labels[:label] %></span>

<% labels.keys #=> [:value, :label, :description, :color] %>
<% labels[:value] #=> "starting" or "confirming" or "completed" %>

<%# description %>
<ul>
  <% Customer.registration_state_labelized.each do |state,labels| %>
    <%# state => "starting" or "confirming" or "completed" %>
    <li><%= labels[:label] %> : <%= labels[:description] %></li>
  <% end %>
</ul>

<ul>
  <% Customer.labelized[:registration_state].each do |state,labels| %>
    <%# state => "starting" or "confirming" or "completed" %>
    <li><%= labels[:label] %> : <%= labels[:description] %></li>
  <% end %>
</ul>
```

### without enum

```ruby
# app/models/my_model.rb
class Customer
  def self.registration_states
    {
      "starting" => 0,
      "confirming" => 1,
      "completed" => 2,
    }
  end

  include Labelizer

  labelize :registration_state
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/getto-systems/labelizer. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).


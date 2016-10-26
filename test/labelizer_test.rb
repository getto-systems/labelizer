require 'test_helper'

class LabelizerTest < Minitest::Test
  class Customer
    include Labelizer

    def self.states
      {
        "starting" => 0,
      }
    end
    def self.roles
      ["all","admin","user"]
    end

    labelize :state, %w(label_color color icon note description), converter: {
      label_color: ->(color){
        "label label-#{color}"
      },
    }
    labelize :roles, %w(note)

    attr_reader :state, :roles

    def initialize(state: nil, roles: [])
      @state = state
      @roles = roles
    end
  end
  class MyCustomer
    include Labelizer

    def self.my_states
      ["starting"]
    end

    labelize :my_state, %w(label_color color icon note description)

    attr_reader :my_state

    def initialize(state)
      @my_state = state
    end
  end

  def setup
    ::I18n.load_path = Dir[File.expand_path("../locales/*.yml",__FILE__)]
    ::I18n.default_locale = :ja
    ::I18n.backend.load_translations
  end

  def test_that_it_has_a_version_number
    refute_nil ::Labelizer::VERSION
  end

  def test_labelizer
    customer = Customer.new state: "starting", roles: ["all","admin","user"]
    assert_equal "label label-info", customer.state_label_color
    assert_equal "starting color", customer.state_color
    assert_equal "state icon", customer.state_icon
    assert_equal "customer note", customer.state_note
    assert_equal "global description", customer.state_description

    labelized = customer.state_labelized
    assert_equal "starting", labelized.value
    assert_equal "starting", labelized[:value]
    assert_equal "starting color", labelized.color
    assert_equal "starting color", labelized[:color]
    assert_equal "state icon", labelized.icon
    assert_equal "state icon", labelized[:icon]
    assert_equal "customer note", labelized.note
    assert_equal "customer note", labelized[:note]
    assert_equal "global description", labelized.description
    assert_equal "global description", labelized[:description]

    assert_raises(KeyError) { labelized[:unknown] }

    assert_equal %i{label_color color icon note description value}, labelized.map{|key,label| key}

    labelized = customer.labelized.state
    assert_equal "starting color", labelized.color
    assert_equal "starting color", labelized[:color]
    assert_equal "state icon", labelized.icon
    assert_equal "state icon", labelized[:icon]
    assert_equal "customer note", labelized.note
    assert_equal "customer note", labelized[:note]
    assert_equal "global description", labelized.description
    assert_equal "global description", labelized[:description]

    assert_raises(KeyError) { labelized[:unknown] }

    labelized = customer.labelized[:state]
    assert_equal "starting color", labelized.color
    assert_equal "starting color", labelized[:color]
    assert_equal "state icon", labelized.icon
    assert_equal "state icon", labelized[:icon]
    assert_equal "customer note", labelized.note
    assert_equal "customer note", labelized[:note]
    assert_equal "global description", labelized.description
    assert_equal "global description", labelized[:description]

    assert_raises(KeyError) { customer.labelized[:unknown] }

    assert_equal %i{state roles}, customer.labelized.map{|key,label| key}

    labelized = Customer.labelized
    assert_equal "starting color", labelized.state["starting"].color
    assert_equal "starting color", labelized.state["starting"][:color]
    assert_equal "starting color", labelized[:state]["starting"].color
    assert_equal "starting color", labelized[:state]["starting"][:color]
    assert_equal "state icon", labelized.state["starting"].icon
    assert_equal "state icon", labelized.state["starting"][:icon]
    assert_equal "state icon", labelized[:state]["starting"].icon
    assert_equal "state icon", labelized[:state]["starting"][:icon]
    assert_equal "customer note", labelized.state["starting"].note
    assert_equal "customer note", labelized.state["starting"][:note]
    assert_equal "customer note", labelized[:state]["starting"].note
    assert_equal "customer note", labelized[:state]["starting"][:note]
    assert_equal "global description", labelized.state["starting"].description
    assert_equal "global description", labelized.state["starting"][:description]
    assert_equal "global description", labelized[:state]["starting"].description
    assert_equal "global description", labelized[:state]["starting"][:description]

    assert_raises(KeyError) { labelized[:unknown] }

    assert_equal %w{starting}, labelized.state.map{|key,label| key}

    assert_equal ["full access", "admin access", "user access"], customer.roles_note

    assert_equal %w{all admin user}, labelized.roles.map{|key,label| key}

    assert_equal "full access", labelized.roles["all"].note
    assert_equal ["admin access", "user access"], labelized.roles[["admin","user"]].note

    assert_equal [["customer note","label label-info","global description"]], labelized.state.pluck(:note,:label_color,:description)
    assert_equal [["all","full access"], ["admin","admin access"], ["user","user access"]], labelized.roles.pluck(:value,:note)
    assert_equal [["full access","all"], ["admin access","admin"], ["user access","user"]], labelized.roles.pluck(:note,:value)

    assert_equal 3, labelized.roles.size

    customer = MyCustomer.new "starting"
    assert_equal "", customer.my_state_color
    assert_equal "", customer.my_state_icon
    assert_equal "", customer.my_state_note
    assert_equal "global description", customer.my_state_description
  end
end

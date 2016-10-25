require 'test_helper'

class LabelizerTest < Minitest::Test
  class Customer
    include Labelizer

    def self.model_name
      OpenStruct.new i18n_key: :customer
    end

    labelize :state, %w(label_color color icon note description), converter: {
      label_color: ->(color){
        "label label-#{color}"
      },
    }

    attr_reader :state

    def initialize(state)
      @state = state
    end
  end
  class MyCustomer
    include Labelizer

    def self.model_name
      OpenStruct.new i18n_key: :my_customer
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
    customer = Customer.new "starting"
    assert_equal "label label-info", customer.state_label_color
    assert_equal "starting color", customer.state_color
    assert_equal "state icon", customer.state_icon
    assert_equal "customer note", customer.state_note
    assert_equal "global description", customer.state_description

    labelized = customer.state_labelized
    assert_equal "starting color", labelized[:color]
    assert_equal "starting color", labelized["color"]
    assert_equal "state icon", labelized[:icon]
    assert_equal "state icon", labelized["icon"]
    assert_equal "customer note", labelized[:note]
    assert_equal "customer note", labelized["note"]
    assert_equal "global description", labelized[:description]
    assert_equal "global description", labelized["description"]

    labelized = Customer.labelized
    assert_equal "starting color", labelized[:state]["starting"][:color]
    assert_equal "starting color", labelized[:state]["starting"]["color"]
    assert_equal "starting color", labelized["state"]["starting"][:color]
    assert_equal "starting color", labelized["state"]["starting"]["color"]
    assert_equal "state icon", labelized[:state]["starting"][:icon]
    assert_equal "state icon", labelized[:state]["starting"]["icon"]
    assert_equal "state icon", labelized["state"]["starting"][:icon]
    assert_equal "state icon", labelized["state"]["starting"]["icon"]
    assert_equal "customer note", labelized[:state]["starting"][:note]
    assert_equal "customer note", labelized[:state]["starting"]["note"]
    assert_equal "customer note", labelized["state"]["starting"][:note]
    assert_equal "customer note", labelized["state"]["starting"]["note"]
    assert_equal "global description", labelized[:state]["starting"][:description]
    assert_equal "global description", labelized[:state]["starting"]["description"]
    assert_equal "global description", labelized["state"]["starting"][:description]
    assert_equal "global description", labelized["state"]["starting"]["description"]

    customer = Customer.new "running"
    assert_equal "running", customer.state_color
    assert_equal "state icon", customer.state_icon
    assert_equal "customer note", customer.state_note
    assert_equal "global description", customer.state_description

    customer = Customer.new 1
    assert_equal 1, customer.state_color

    customer = Customer.new nil
    assert_equal nil, customer.state_color

    customer = MyCustomer.new "state"
    assert_equal "state", customer.my_state_color
    assert_equal "state", customer.my_state_icon
    assert_equal "state", customer.my_state_note
    assert_equal "global description", customer.my_state_description
  end
end

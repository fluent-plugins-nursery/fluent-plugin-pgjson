require 'helper'

class PgJsonOutputTest < Test::Unit::TestCase
  def setup
    Fluent::Test.setup
  end

  CONFIG = %[
    type pgjson
    host localhost
    port 5432
    database fluentd
    table fluentd
    user postgres
    password postgres
    time_col time
    tag_col tag
    record_col record
  ]

  def create_driver(conf = CONFIG, tag='test')
    Fluent::Test::BufferedOutputTestDriver.new(Fluent::PgJsonOutput, tag).configure(conf)
  end

  def test_configure
    d = create_driver

    assert_equal "localhost", d.instance.host
    assert_equal 5432, d.instance.port
    assert_equal "fluentd", d.instance.database
    assert_equal "fluentd", d.instance.table
    assert_equal "postgres", d.instance.user
    assert_equal "postgres", d.instance.password
    assert_equal "time", d.instance.time_col
    assert_equal "tag", d.instance.tag_col
    assert_equal "record", d.instance.record_col
  end

  def test_format
    d = create_driver
  end

  def test_write
    d = create_driver
  end
end

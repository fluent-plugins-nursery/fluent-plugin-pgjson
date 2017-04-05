require 'fluent/plugin/output'
require 'pg'

module Fluent::Plugin

class PgJsonOutput < Fluent::Output
  Fluent::Plugin.register_output('pgjson', self)

  helpers :compat_parameters

  DEFAULT_BUFFER_TYPE = "memory"

  config_param :host       , :string  , :default => 'localhost'
  config_param :port       , :integer , :default => 5432
  config_param :sslmode    , :string  , :default => 'prefer'
  config_param :database   , :string
  config_param :table      , :string
  config_param :user       , :string  , :default => nil
  config_param :password   , :string  , :default => nil , :secret => true
  config_param :time_col   , :string  , :default => 'time'
  config_param :tag_col    , :string  , :default => 'tag'
  config_param :record_col , :string  , :default => 'record'
  config_param :msgpack    , :bool    , :default => false
  config_section :buffer do
    config_set_default :@type, DEFAULT_BUFFER_TYPE
    config_set_default :chunk_keys, ['tag']
  end

  def initialize
    super
    @conn = nil
  end

  def configure(conf)
    compat_parameters_convert(conf, :buffer)
    super
  end

  def shutdown
    super

    if ! @conn.nil? and ! @conn.finished?
      @conn.close()
    end
  end

  def formatted_to_msgpack_binary
    true
  end

  def format(tag, time, record)
    [time, record].to_msgpack
  end

  def write(chunk)
    init_connection
    @conn.exec("COPY #{@table} (#{@tag_col}, #{@time_col}, #{@record_col}) FROM STDIN WITH DELIMITER E'\\x01'")
    begin
      tag = chunk.metadata.tag
      chunk.msgpack_each do |time, record|
        @conn.put_copy_data "#{tag}\x01#{Time.at(time).to_s}\x01#{record_value(record)}\n"
      end
    rescue => err
      errmsg = "%s while copy data: %s" % [ err.class.name, err.message ]
      @conn.put_copy_end( errmsg )
      @conn.get_result
      raise
    else
      @conn.put_copy_end
      res = @conn.get_result
      raise res.result_error_message if res.result_status!=PG::PGRES_COMMAND_OK
    end
  end

  private
  def init_connection
    if @conn.nil?
      $log.debug "connecting to PostgreSQL server #{@host}:#{@port}, database #{@database}..."

      begin
        @conn = PGconn.new(:dbname => @database, :host => @host, :port => @port, :sslmode => @sslmode, :user => @user, :password => @password)
      rescue
        if ! @conn.nil?
          @conn.close()
          @conn = nil
        end
        raise "failed to initialize connection: #$!"
      end
    end
  end

  def record_value(record)
    if @msgpack
      "\\#{@conn.escape_bytea(record.to_msgpack)}"
    else
      json = record.to_json
      json.gsub!(/\\/){ '\\\\' }
      json
    end
  end
end

end

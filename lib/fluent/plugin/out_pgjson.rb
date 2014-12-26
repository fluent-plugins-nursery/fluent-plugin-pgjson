module Fluent

class PgJsonOutput < Fluent::BufferedOutput
  Fluent::Plugin.register_output('pgjson', self)

  config_param :host       , :string  , :default => 'localhost'
  config_param :port       , :integer , :default => 5432
  config_param :sslmode    , :string  , :default => 'prefer'
  config_param :database   , :string
  config_param :table      , :string
  config_param :user       , :string  , :default => nil
  config_param :password   , :string  , :default => nil
  config_param :time_col   , :string  , :default => 'time'
  config_param :tag_col    , :string  , :default => 'tag'
  config_param :record_col , :string  , :default => 'record'
  config_param :messagepack, :bool  , :default => false

  def initialize
    super
    require 'pg'
    @conn = nil
  end

  def configure(conf)
    super
  end

  def shutdown
    super

    if ! @conn.nil? and ! @conn.finished?
      @conn.close()
    end
  end

  def format(tag, time, record)
    [tag, time, record].to_msgpack
  end

  def write(chunk)
    init_connection
    begin
      @conn.exec("COPY #{@table} (#{@tag_col}, #{@time_col}, #{@record_col}) FROM STDIN WITH DELIMITER E'\\x01'")
      chunk.msgpack_each do |tag, time, record|
        @conn.put_copy_data "#{tag}\x01#{Time.at(time).to_s}\x01#{record_value(record)}\n"
      end
      @conn.put_copy_end
    rescue
      if ! @conn.nil?
        @conn.close()
        @conn = nil
      end
      raise "failed to send data to postgres: #$!"
    end
  end

  private
  def init_connection
    if @conn.nil?
      $log.debug "connecting to PostgreSQL server #{@host}:#{@port}, database #{@database}..."

      begin
        @conn = PGconn.new(:dbname => @database, :host => @host, :port => @port, :sslmode => @sslmode, :user => @user, :password => @password)
        @conn.setnonblocking(true)
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
      record.to_json
    end
  end
end

end

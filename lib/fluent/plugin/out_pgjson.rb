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
    begin
      init_connection
      @conn.exec("COPY #{@table} (#{@tag_col}, #{@time_col}, #{@record_col}) FROM STDIN WITH DELIMITER E'\\x01'")
      chunk.msgpack_each do |tag, time, record|
        @conn.put_copy_data "#{tag}\x01#{Time.at(time).to_s}\x01#{record.to_json}\n"
      end
      @conn.put_copy_end
    rescue
      begin
        @conn.close()
      rescue
      end

      @conn = nil
      raise
    end
  end

  private
  def init_connection
    if @conn.nil?
      $log.debug "Connecting to PostgreSQL server #{@host}:#{@port}, database #{@database}..."

      begin
        @conn = PGconn.new(:dbname => @database, :host => @host, :port => @port, :sslmode => @sslmode, :user => @user, :password => @password)
        @conn.setnonblocking(true)
      rescue
        if ! @conn.nil?
          begin
            @conn.close()
          rescue
          end

          @conn = nil
        end

        raise
      end
    end
  end
end

end

module Fluent

class PgJsonOutput < Fluent::BufferedOutput
  Fluent::Plugin.register_output('pgjson', self)

  config_param :host       , :string  , :default => 'localhost'
  config_param :port       , :integer , :default => 5432
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
  end

  def configure(conf)
    super
    @stmt_name = 'insert'
  end

  def start
    super
    init_connection
  end

  def shutdown
    super
    if !@conn.nil? and !@conn.finished?
      @conn.close()
    end
  end

  def format(tag, time, record)
    [tag, time, record].to_msgpack
  end

  def write(chunk)
    begin
      sql = build_sql(chunk)
      @conn.exec(sql)
    rescue
      #TODO
      raise
    end
  end

  private
  def init_connection
    begin
      @conn = PGconn.new(:dbname => @database, :host => @host, :port => @port, :user => @user, :password => @password)
      @conn.setnonblocking(true)
    rescue
      raise Fluent::ConfigError, "failed to connect PostgreSQL Server at #{@host}:#{@port}"
    end
  end

  def prepare_statement
    begin
      @conn.prepare(@stmt_name, sql)
    rescue
      #TODO
      raise
    end
  end

  def build_sql(chunk)
    values = build_values(chunk)
    sql =<<"SQL"
INSERT INTO #{@table} (#{@tag_col}, #{@time_col}, #{@record_col})
VALUES #{values};
SQL
  end

  def build_values(chunk)
    tmp = []
    chunk.msgpack_each do |tag, time, record|
      tmp << ("("+[tag, Time.at(time), record.to_json].map{|s| @conn.escape_literal(s.to_s)}.join(',')+")")
    end
    tmp.join(',')
  end
end

end

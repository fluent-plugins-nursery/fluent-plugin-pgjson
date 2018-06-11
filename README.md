# Fluent::Plugin::PgJson, a plugin for [Fluentd](http://fluentd.org)

Output Plugin for PostgreSQL Json Type.

<b>Json type is availble in PostgreSQL version over 9.2</b>

## Installation

`$ fluent-gem install fluent-plugin-pgjson`

## Schema

Specified table must have this schema.

|col|type|
|---|---|
|{tag_col}|Text|
|{time_col}|Timestamp WITH TIME ZONE|
|{record_col}|Json|

### Example

```
CREATE TABLE fluentd (
    tag Text
    ,time Timestamptz
    ,record Json
);
```
### JSONB?

Yes! Just define a record column as JSONB type.

```
CREATE TABLE fluentd (
    tag Text
    ,time Timestamptz
    ,record Jsonb
);
```

### Configurable JSON Encoder

Fluentd's standard JSON encoder is `yajl`.
`yajl` is robust for invalid byte sequence.
But this plugin's default value is `json` which is Ruby standard JSON encoder for backward compatibility.

## Configuration

### Example

```
<match **>
  type pgjson
  host localhost
  port 5432
  sslmode require
  database fluentd
  table fluentd
  user postgres
  password postgres
  time_col time
  tag_col tag
  record_col record
</match>
```

### Parameter

|parameter|description|default|
|---|---|---|
|host|postgres server hostname|localhost|
|port|postgres server port number|5432|
|sslmode|use ssl (disable/allow/prefer/require)|prefer||
|database|database name to which records will be inserted||
|table|table name to which records will be inserted||
|user|user name used to connect database|nil|
|password|password uset to connect database|nil|
|time_col|column name to insert time|time|
|tag_col|column name to insert tag|tag|
|record_col|column name to insert record|record|
|msgpack|use msgpack format for inserting records|false|
|encoder|choose prefer JSON encoder (yajl/json)|json|

## Copyright

* Copyright (c) 2014- OKUNO Akihiro
* License
    * Apache License, version 2.0

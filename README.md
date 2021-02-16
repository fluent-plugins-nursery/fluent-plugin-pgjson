# Fluent::Plugin::PgJson, a plugin for [Fluentd](http://fluentd.org)

![linux](https://github.com/fluent-plugins-nursery/fluent-plugin-pgjson/workflows/linux/badge.svg?branch=master)

Output Plugin for PostgreSQL Json Type.

<b>Json type is availble in PostgreSQL version over 9.2</b>

## Requirements

| fluent-plugin-pgjson | fluentd    | Ruby   |
|----------------------|------------|--------|
| >= 1.0.0             | >= v1.0.0  | >= 2.2 |
|  < 1.0.0             | >= v0.12.0 | >= 1.9 |

## Installation

```
$ fluent-gem install fluent-plugin-pgjson
```

## Schema

Specified table must have following schema:

| col          | type                     |
|--------------|--------------------------|
| {tag_col}    | Text                     |
| {time_col}   | Timestamp WITH TIME ZONE |
| {record_col} | Json                     |

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

## Configuration

### Example

```
<match **>
  @type pgjson
  #host localhost
  #port 5432
  #sslmode prefer
  database fluentd
  table fluentd
  user postgres
  password postgres
  #time_col time
  #tag_col tag
  #record_col record
  #msgpack false
  #encoder yajl
</match>
```

### Parameter

|parameter|description|default|
|---|---|---|
|host|The hostname of PostgreSQL server|localhost|
|port|The port of PostgreSQL server|5432|
|sslmode|Set the sslmode to enable Eavesdropping protection/MITM protection. See [PostgreSQL Documentation](https://www.postgresql.org/docs/10/static/libpq-ssl.html) for more details. (`disable`, `allow`, `prefer`, `require`, `verify-ca`, `verify-full`)|`prefer`|
|database|The database name to connect||
|table|The table name to insert records||
|user|The user name to connect database|nil|
|password|The password to connect database|nil|
|time_col|The column name for the time|`time`|
|tag_col|The column name for the tag|`tag`|
|record_col|The column name for the record|`record`|
|msgpack|If true, insert records formatted as msgpack|`false`|
|encoder|JSON encoder (`yajl`, `json`)|`yajl`|

## Copyright

* Copyright (c) 2014- OKUNO Akihiro
* License
    * Apache License, version 2.0

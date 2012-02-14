Db = require('mongodb').Db
Connection = require('mongodb').Connection
Server = require('mongodb').Server
Mongo = require('mongodb')

db = new Db 'dbs', new Server('127.0.0.1', 34006, {})

db.open (err, db) ->
	db.dropCollection
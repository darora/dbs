Db = require('mongodb').Db
Connection = require('mongodb').Connection
Server = require('mongodb').Server
Mongo = require('mongodb')
express = require('express')
jsdom  = require('jsdom')
fs     = require('fs')
path = require('path')

require('./coffee/handlers.js')

global.db = new Db 'dbs', new Server('127.0.0.1', 34006, {})

app = express.createServer()

app.configure () ->
	app.set('view_engine', 'jade')
	app.set('layout')
	# app.use allowCrossDomain
	app.use '/public', express.static(__dirname + '/public')
	app.use express.bodyParser()

# app.get '/', dbs.indexHandler
app.get '/', (req, res) ->
	# locals = message: "Express + Haml working", pageTitle: "Express and Jade", youAreUsingJade: true
	# res.render 'index.jade', {locals: locals, layout: null}
	db.open (err, db) ->
		if err
			console.log err + "no open err"
			return null
		items = []
		db.collection 'data', (err, collection) ->
			collection.find {}, {}, (err, cursor) ->
				if err
					console.log "Error in collection find" + err
				cursor.toArray (err, items) ->
					if err
						console.log "Error in iteration" + err
					res.render 'index.jade', {locals: {items: items}, layout: null}
				# db.close()

app.get '/getJson', (req, res) ->
	db.open (err, db) ->
		if err
			console.log err + "no open err"
			return null
		items = []
		db.collection 'data', (err, collection) ->
			collection.find {}, {}, (err, cursor) ->
				if err
					console.log "Error in collection find" + err
				cursor.toArray (err, items) ->
					if err
						console.log "Error in iteration" + err
					res.write JSON.stringify(items)
					res.end()
	

app.get '/login', (req, res) ->
	res.send "login page"

app.post '/data', (req, res) ->
	res.header 'Access-Control-Allow-Origin', '*'
	data = req.body['data']
	db.open (err, db) ->
		if err is true
			return null
		db.collection 'data', (err, collection) ->
			for e in data
				console.log e
				collection.insert e
		db.close()

app.listen 3000
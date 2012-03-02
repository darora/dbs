dbs ?= {}
db = global.db
dbs.indexHandler = (req, res) ->
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

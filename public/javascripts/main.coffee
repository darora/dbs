dbs ?= {}

dbs.transaction = Backbone.Model.extend
	defaults:
		transactionDate: null
		transactionType: null
		referenceNumber: null
		withdrawalAmount: null
		debitAmount: null
		hours: null
		processed: false
		render: true
	initialize: () ->
		_.bindAll @, 'amount', 'processDate'
	amount: () ->
		if @get('withdrawalAmount')?
			-@get('withdrawalAmount')
		else if @get('debitAmount')?
			@get('debitAmount')
		else 0.00
	processCurrency: () ->
		str = @get 'withdrawalAmount'
		if str?
			str = str.substring 1
			@set 'withdrawalAmount':str
		else
			str = @get 'debitAmount'
			if str?
				str = str.substring 1
				@set 'debitAmount':str
			else null

	processDate: () ->
		strDate = @get 'transactionDate'
		date = strDate.substring 0, strDate.indexOf ' '
		dateIndex = strDate.indexOf ' '
		month = strDate.substring(dateIndex+1, strDate.indexOf(' ', dateIndex+1))
		monthIndex = strDate.indexOf ' ', dateIndex+1
		x = null
		switch month
			when "Jan" then x = 0
			when "Feb" then x = 1
			when "Mar" then x = 2
			when "Apr" then x = 3
			when "May" then x = 4
			when "Jun" then x = 5
			when "Jul" then x = 6
			when "Aug" then x = 7
			when "Sep" then x = 8
			when "Oct" then x = 9
			when "Nov" then x = 10
			when "Dec" then x = 11
		month = x
		year = strDate.substring(monthIndex+1)
		@set 
			'year': year
			'month': month
			'date': date
		@set 'transactionDate': new Date(Date.UTC(year, month, date))

dbs.transactions = Backbone.Collection.extend
	model: dbs.transaction
	url: 'http://localhost:3000/getJson'
	initialize: () ->
		_.bindAll @, 'getData', 'processDates'
	getData: () ->
		_(@models)#.chain().filter((e,i) -> i <= 5)
			.map((e) ->
				[e.get("transactionDate").getTime(), e.amount()])
	assignHours: (lst) ->
		if lst.length <= 1
			return lst
		fst = lst[0]
		res = []
		remainder = []
		_(lst).each (e) ->
			if e.get("year") is fst.get("year") and e.get("month") is fst.get("month") and e.get("date") is fst.get("date")
				res.push e
			else
				remainder.push e
		# console.log "#{res.length} is the length of the filtered array"
		cnt = 24 / (lst.length+1)
		_(lst).each (e, i) ->
			e.get("transactionDate").setHours(i*cnt)
		_(@assignHours(remainder)).each (e) ->
			res.push(e)
		res

	processDates: () ->
		that = @
		_(@models).each (t) ->
			t.processDate()
			t.processCurrency()
		# Spread evenly over the course of a day and set date in UTC
		@assignHours(@models)
	

dbs.controller = Backbone.View.extend
	model: dbs.transaction
	initialize: () ->
		that = @
		_.bindAll @, 'render'
		@data = new dbs.transactions()
		@data.fetch success: () ->
			that.data.processDates()
			that.render()
	render: () ->
		if dbs.highcharts?
			# @c = dbs.highcharts dbs.chartoptions(@data.getData())
			#todo
		else
			console.log(@data.getData())
			dbs.graphInit(dbs.chartoptions(@data.getData()))
			@render()
dbs.chartoptions = (series) ->
	chart:
		renderTo: 'chart_canvas'
		type: 'column'
		zoomType: 'xy'
	title:
		text: 'Bank transactions'
	yAxis:
		title:
			text: 'Amount in SGD'
	xAxis:
		type: 'datetime'
		labels:
			rotation: -35

		dateTimeLabelFormats:
			month: '%e. %b'
			year: '%b'
	plotOptions:
		column:
			pointPadding: 0.2
			borderWidth: 0
		# categories: xLabels
	series: [{name: "Transactions", data: series}]

dbs.graphInit = (opt) ->
	dbs.highcharts = new Highcharts.Chart(opt)

dbs.init = () ->
	dbs.controllerInstance = new dbs.controller()
	window.ci = dbs.controllerInstance

$(() ->
	dbs.init()
)
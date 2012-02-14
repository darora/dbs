dbs ?= {}

dbs.transaction = Backbone.Model.extend
	defaults:
		transactionDate: null
		transactionType: null
		referenceNumber: null
		withdrawalAmount: null
		debitAmount: null
	initialize: () ->
		_.bindAll @, 'amount'
	amount: () ->
		if withdrawalAmount?
			-withdrawalAmount
		else debitAmount
	
dbs.transactions = Backbone.Collection.extend
	model: dbs.transaction
	initialize: () ->
		_.bindAll @, 'getData'
	getData: () ->
		arr = []
		_(@models).each((e) -> 
			arr.push e.amount()
		)
		arr

dbs.controller = Backbone.View.extend
	model: dbs.transaction
	initialize: () ->
		_.bindAll @, 'render'
		@data = new dbs.transactions()
	render: () ->
		if dbs.highcharts?
			@c = dbs.highcharts
			#todo
		else
			dbs.init()
			@render()
dbs.chartoptions = (xLabels, series) ->
	chart:
		renderTo: 'chart_canvas'
		type: 'bar'
	title:
		text: 'Bank transactions'
	yaxis:
		title:
			text: 'Amount in SGD'
	xaxis:
		categories: xLabels
	series: series

dbs.init = () ->
	dbs.highcharts = new Highcharts.chart
		chart:
			renderTo: 'chart_canvas'
			type: 'bar'
		title:
			text: 'Bank transactions'
		yaxis:
			title:
				text: 'Amount in SGD'
		
	dbs.controllerInstance = new dbs.controller()
	window.ci = dbs.controllerInstance

$(() ->
	dbs.init()
)
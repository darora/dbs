(function() {

  if (typeof dbs === "undefined" || dbs === null) dbs = {};

  dbs.transaction = Backbone.Model.extend({
    defaults: {
      transactionDate: null,
      transactionType: null,
      referenceNumber: null,
      withdrawalAmount: null,
      debitAmount: null
    },
    initialize: function() {
      return _.bindAll(this, 'amount');
    },
    amount: function() {
      if (typeof withdrawalAmount !== "undefined" && withdrawalAmount !== null) {
        return -withdrawalAmount;
      } else {
        return debitAmount;
      }
    }
  });

  dbs.transactions = Backbone.Collection.extend({
    model: dbs.transaction,
    initialize: function() {
      return _.bindAll(this, 'getData');
    },
    getData: function() {
      var arr;
      arr = [];
      _(this.models).each(function(e) {
        return arr.push(e.amount());
      });
      return arr;
    }
  });

  dbs.controller = Backbone.View.extend({
    model: dbs.transaction,
    initialize: function() {
      _.bindAll(this, 'render');
      return this.data = new dbs.transactions();
    },
    render: function() {
      if (dbs.highcharts != null) {
        return this.c = dbs.highcharts;
      } else {
        dbs.init();
        return this.render();
      }
    }
  });

  dbs.chartoptions = function(xLabels, series) {
    return {
      chart: {
        renderTo: 'chart_canvas',
        type: 'bar'
      },
      title: {
        text: 'Bank transactions'
      },
      yaxis: {
        title: {
          text: 'Amount in SGD'
        }
      },
      xaxis: {
        categories: xLabels
      },
      series: series
    };
  };

  dbs.init = function() {
    dbs.highcharts = new Highcharts.chart({
      chart: {
        renderTo: 'chart_canvas',
        type: 'bar'
      },
      title: {
        text: 'Bank transactions'
      },
      yaxis: {
        title: {
          text: 'Amount in SGD'
        }
      }
    });
    dbs.controllerInstance = new dbs.controller();
    return window.ci = dbs.controllerInstance;
  };

  $(function() {
    return dbs.init();
  });

}).call(this);

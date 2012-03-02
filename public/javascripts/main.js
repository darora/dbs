(function() {

  if (typeof dbs === "undefined" || dbs === null) dbs = {};

  dbs.transaction = Backbone.Model.extend({
    defaults: {
      transactionDate: null,
      transactionType: null,
      referenceNumber: null,
      withdrawalAmount: null,
      debitAmount: null,
      hours: null,
      processed: false,
      render: true
    },
    initialize: function() {
      return _.bindAll(this, 'amount', 'processDate');
    },
    amount: function() {
      if (this.get('withdrawalAmount') != null) {
        return -this.get('withdrawalAmount');
      } else if (this.get('debitAmount') != null) {
        return this.get('debitAmount');
      } else {
        return 0.00;
      }
    },
    processCurrency: function() {
      var str;
      str = this.get('withdrawalAmount');
      if (str != null) {
        str = str.substring(1);
        return this.set({
          'withdrawalAmount': str
        });
      } else {
        str = this.get('debitAmount');
        if (str != null) {
          str = str.substring(1);
          return this.set({
            'debitAmount': str
          });
        } else {
          return null;
        }
      }
    },
    processDate: function() {
      var date, dateIndex, month, monthIndex, strDate, x, year;
      strDate = this.get('transactionDate');
      date = strDate.substring(0, strDate.indexOf(' '));
      dateIndex = strDate.indexOf(' ');
      month = strDate.substring(dateIndex + 1, strDate.indexOf(' ', dateIndex + 1));
      monthIndex = strDate.indexOf(' ', dateIndex + 1);
      x = null;
      switch (month) {
        case "Jan":
          x = 0;
          break;
        case "Feb":
          x = 1;
          break;
        case "Mar":
          x = 2;
          break;
        case "Apr":
          x = 3;
          break;
        case "May":
          x = 4;
          break;
        case "Jun":
          x = 5;
          break;
        case "Jul":
          x = 6;
          break;
        case "Aug":
          x = 7;
          break;
        case "Sep":
          x = 8;
          break;
        case "Oct":
          x = 9;
          break;
        case "Nov":
          x = 10;
          break;
        case "Dec":
          x = 11;
      }
      month = x;
      year = strDate.substring(monthIndex + 1);
      this.set({
        'year': year,
        'month': month,
        'date': date
      });
      return this.set({
        'transactionDate': new Date(Date.UTC(year, month, date))
      });
    }
  });

  dbs.transactions = Backbone.Collection.extend({
    model: dbs.transaction,
    url: 'http://localhost:3000/getJson',
    initialize: function() {
      return _.bindAll(this, 'getData', 'processDates');
    },
    getData: function() {
      return _(this.models).map(function(e) {
        return [e.get("transactionDate").getTime(), e.amount()];
      });
    },
    assignHours: function(lst) {
      var cnt, fst, remainder, res;
      if (lst.length <= 1) return lst;
      fst = lst[0];
      res = [];
      remainder = [];
      _(lst).each(function(e) {
        if (e.get("year") === fst.get("year") && e.get("month") === fst.get("month") && e.get("date") === fst.get("date")) {
          return res.push(e);
        } else {
          return remainder.push(e);
        }
      });
      cnt = 24 / (lst.length + 1);
      _(lst).each(function(e, i) {
        return e.get("transactionDate").setHours(i * cnt);
      });
      _(this.assignHours(remainder)).each(function(e) {
        return res.push(e);
      });
      return res;
    },
    processDates: function() {
      var that;
      that = this;
      _(this.models).each(function(t) {
        t.processDate();
        return t.processCurrency();
      });
      return this.assignHours(this.models);
    }
  });

  dbs.controller = Backbone.View.extend({
    model: dbs.transaction,
    initialize: function() {
      var that;
      that = this;
      _.bindAll(this, 'render');
      this.data = new dbs.transactions();
      return this.data.fetch({
        success: function() {
          that.data.processDates();
          return that.render();
        }
      });
    },
    render: function() {
      if (dbs.highcharts != null) {} else {
        console.log(this.data.getData());
        dbs.graphInit(dbs.chartoptions(this.data.getData()));
        return this.render();
      }
    }
  });

  dbs.chartoptions = function(series) {
    return {
      chart: {
        renderTo: 'chart_canvas',
        type: 'column',
        zoomType: 'xy'
      },
      title: {
        text: 'Bank transactions'
      },
      yAxis: {
        title: {
          text: 'Amount in SGD'
        }
      },
      xAxis: {
        type: 'datetime',
        dateTimeLabelFormats: {
          month: '%e. %b',
          year: '%b'
        }
      },
      plotOptions: {
        column: {
          pointPadding: 0.2,
          borderWidth: 0
        }
      },
      series: [
        {
          name: "Transactions",
          data: series
        }
      ]
    };
  };

  dbs.graphInit = function(opt) {
    return dbs.highcharts = new Highcharts.Chart(opt);
  };

  dbs.init = function() {
    dbs.controllerInstance = new dbs.controller();
    return window.ci = dbs.controllerInstance;
  };

  $(function() {
    return dbs.init();
  });

}).call(this);

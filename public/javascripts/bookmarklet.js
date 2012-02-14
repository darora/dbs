window.arr = [];
$($('frame[name="main"]', top.frames['user_area'].document)[0].contentDocument.documentElement).find('td.MFParentTableBgColor tr').each(function(i, e) {
	var tds = $(e).find('td.MFTableContentRowEven');
	if (tds.length == 0)
		tds = $(e).find('td.MFTableContentRowOdd');
	if (tds.length == 0)
		return;
	obj = {
		transactionDate: $(tds[0]).text().trim(),
		transactionType: $(tds[1]).text().trim(),
		referenceNumber: $(tds[2]).text().trim(),
		withdrawalAmount: $(tds[3]).text().substr(1).trim(),
		debitAmount: $(tds[4]).text().substr(1).trim()
	};
	window.arr.push(obj);
});
$.post("http://localhost:3000/data", {data: window.arr}, function() { console.log("finished posting data"); });
// Generated by CoffeeScript 1.7.1
d3.text("unemp_states_us_nov_2013.tsv", function(error, data) {
  var caption, dataCells, dataset, header, headerCells, rows, tBody, tHead, table;
  d3.select("body").append("h1").text("Unemployment Rates for States");
  table = d3.select("body").append("table");
  caption = table.append("caption");
  tHead = table.append("thead");
  tBody = table.append("tbody");
  caption.html("Unemployment Rates for States<br>Monthly Rankings<br>Seasonally Adjusted<br>Dec. 2013<sup>p</sup>");
  dataset = [];
  d3.tsv.parseRows(data, function(row, ix) {
    return dataset.push({
      "Rank": row[0],
      "State": row[1],
      "Rate": row[2]
    });
  });
  header = tHead.selectAll("tr").data(dataset.slice(0, 1)).enter().append("tr");
  rows = tBody.selectAll("tr").data(dataset.slice(1)).enter().append("tr");
  headerCells = header.selectAll("th").data(function(row) {
    var key, value, _results;
    _results = [];
    for (key in row) {
      value = row[key];
      _results.push(value);
    }
    return _results;
  }).enter().append("th").text(function(d) {
    return d;
  });
  return dataCells = rows.selectAll("td").data(function(row) {
    var key, value, _results;
    _results = [];
    for (key in row) {
      value = row[key];
      _results.push(value);
    }
    return _results;
  }).enter().append("td").text(function(d) {
    return d;
  });
});

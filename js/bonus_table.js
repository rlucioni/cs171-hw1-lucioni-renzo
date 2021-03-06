// Generated by CoffeeScript 1.7.1
d3.text("unemp_states_us_nov_2013.tsv", function(error, data) {
  var addBars, ascending, barsColumn, colorColumn, coloredColumn, colors, dataCells, dataset, header, headerCells, isNumeric, ix, rows, sourceColumn, tBody, tHead, table, tieBreakerColumn, zebraStripe, _i, _len, _ref;
  d3.select("body").append("h1").text("Unemployment Rates for States");
  table = d3.select("body").append("table");
  table.append("caption").html("Unemployment Rates for States<br>Monthly Rankings<br>Seasonally Adjusted<br>Dec. 2013<sup>p</sup>");
  tHead = table.append("thead");
  tBody = table.append("tbody");
  dataset = d3.tsv.parseRows(data);
  isNumeric = function(num) {
    return !isNaN(num);
  };
  tieBreakerColumn = null;
  _ref = d3.range(dataset[1].length);
  for (_i = 0, _len = _ref.length; _i < _len; _i++) {
    ix = _ref[_i];
    if (!isNumeric(dataset[1][ix])) {
      tieBreakerColumn = ix;
      break;
    }
  }
  colors = {
    gray: "#e9e9e9",
    white: "#ffffff",
    blue: "#084594",
    skyBlue: "#a6cee3",
    lightYellow: "#ffff99"
  };
  header = tHead.selectAll("tr").data(dataset.slice(0, 1)).enter().append("tr");
  rows = tBody.selectAll("tr").data(dataset.slice(1)).enter().append("tr");
  headerCells = header.selectAll("th").data(function(row) {
    return row;
  }).enter().append("th").style("cursor", "n-resize").style("background-color", colors.gray).text(function(d) {
    return d;
  });
  dataCells = rows.selectAll("td").data(function(row) {
    return row;
  }).enter().append("td").attr("class", function(d, column) {
    return "column-" + column;
  }).text(function(d) {
    return d;
  });
  addBars = function(sourceColumn, barsColumn) {
    var columnData, svgHeight, svgWidth, xScale;
    svgWidth = 100;
    svgHeight = 20;
    columnData = d3.selectAll(".column-" + sourceColumn).data().map(function(n) {
      return +n;
    });
    xScale = d3.scale.linear().domain([0, d3.max(columnData)]).range([0, svgWidth]);
    header.insert("th", ":first-child").data(["Bar Chart"]).attr("id", "ascending").style("cursor", "n-resize").style("background-color", colors.gray).text("Bar Chart");
    headerCells = header.selectAll("th");
    rows.insert("td", ":first-child").data(columnData).attr("class", "column-" + barsColumn).append("svg").attr("width", svgWidth).attr("height", svgHeight).append("rect").attr({
      "height": svgHeight,
      "width": function(d) {
        return xScale(d);
      },
      "fill": colors.skyBlue
    });
    return dataCells = rows.selectAll("td");
  };
  sourceColumn = 2;
  barsColumn = 3;
  addBars(sourceColumn, barsColumn);
  ascending = true;
  rows = rows.sort(function(a, b) {
    var aTieBreaker, bTieBreaker, valueA, valueB, verdict;
    valueA = a[0];
    valueB = b[0];
    if (isNumeric(valueA) && isNumeric(valueB)) {
      valueA = +valueA;
      valueB = +valueB;
    }
    verdict = d3.ascending(valueA, valueB);
    if (verdict === 0 && tieBreakerColumn !== null) {
      aTieBreaker = a[tieBreakerColumn].toLowerCase();
      bTieBreaker = b[tieBreakerColumn].toLowerCase();
      if (aTieBreaker < bTieBreaker) {
        return -1;
      } else if (aTieBreaker > bTieBreaker) {
        return 1;
      } else {
        return 0;
      }
    } else {
      return verdict;
    }
  });
  zebraStripe = function() {
    return rows.style("background-color", function(d, row) {
      if (row % 2 === 1) {
        return colors.gray;
      } else {
        return colors.white;
      }
    });
  };
  colorColumn = function(column) {
    var color, columnData;
    columnData = d3.selectAll(".column-" + column).data().map(function(n) {
      if (isNumeric(n)) {
        return +n;
      }
    });
    color = d3.scale.linear().domain([0, d3.max(columnData)]).interpolate(d3.interpolateRgb).range([colors.white, colors.blue]);
    return d3.selectAll(".column-" + column).style("color", colors.white).style("background-color", function(d) {
      return color(d);
    });
  };
  zebraStripe();
  coloredColumn = 2;
  colorColumn(coloredColumn);
  headerCells.on("click", function(d, column) {
    ascending = !ascending;
    if (ascending) {
      headerCells.style("cursor", "n-resize");
      headerCells.attr("id", null);
      d3.select(headerCells[0][column]).attr("id", "ascending");
    } else {
      headerCells.style("cursor", "s-resize");
      headerCells.attr("id", null);
      d3.select(headerCells[0][column]).attr("id", "descending");
    }
    if (column === 0) {
      column = 3;
    } else {
      column -= 1;
    }
    rows = rows.sort(function(a, b) {
      var aTieBreaker, bTieBreaker, valueA, valueB, verdict;
      if (d === "Bar Chart") {
        column = sourceColumn;
      }
      valueA = a[column];
      valueB = b[column];
      if (isNumeric(valueA) && isNumeric(valueB)) {
        valueA = +valueA;
        valueB = +valueB;
      }
      if (ascending) {
        verdict = d3.ascending(valueA, valueB);
        if (verdict === 0 && tieBreakerColumn !== null) {
          aTieBreaker = a[tieBreakerColumn].toLowerCase();
          bTieBreaker = b[tieBreakerColumn].toLowerCase();
          if (aTieBreaker < bTieBreaker) {
            return -1;
          } else if (aTieBreaker > bTieBreaker) {
            return 1;
          } else {
            return 0;
          }
        } else {
          return verdict;
        }
      } else {
        verdict = d3.descending(valueA, valueB);
        if (verdict === 0 && tieBreakerColumn !== null) {
          aTieBreaker = a[tieBreakerColumn].toLowerCase();
          bTieBreaker = b[tieBreakerColumn].toLowerCase();
          if (aTieBreaker > bTieBreaker) {
            return -1;
          } else if (aTieBreaker < bTieBreaker) {
            return 1;
          } else {
            return 0;
          }
        } else {
          return verdict;
        }
      }
    });
    zebraStripe();
    return colorColumn(coloredColumn);
  });
  dataCells.on("mouseover", function(d, column) {
    if (column === 0) {
      column = 3;
    } else {
      column -= 1;
    }
    d3.selectAll(".column-" + column).style("background-color", colors.lightYellow);
    d3.select(this.parentNode).style("background-color", colors.lightYellow);
    return colorColumn(coloredColumn);
  });
  return dataCells.on("mouseout", function(d, column) {
    if (column === 0) {
      column = 3;
    } else {
      column -= 1;
    }
    d3.selectAll(".column-" + column).style("background-color", null);
    zebraStripe();
    return colorColumn(coloredColumn);
  });
});

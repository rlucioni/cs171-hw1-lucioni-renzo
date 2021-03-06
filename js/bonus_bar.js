// Generated by CoffeeScript 1.7.1
var barPadding, canvasHeight, canvasWidth, colors, g, isNumeric, labelPadding, margin, state, svg, textHorizontalScale, textSizeScale, textVerticalScale, title, xScale, yScale;

margin = {
  top: 50,
  bottom: 10,
  left: 250,
  right: 40
};

canvasWidth = 1000 - margin.left - margin.right;

canvasHeight = 1000 - margin.top - margin.bottom;

barPadding = 0.05;

labelPadding = -10;

textHorizontalScale = 1.5;

textVerticalScale = 0.77;

textSizeScale = 21.25;

colors = {
  white: "#ffffff",
  crimson: "#cb181d",
  darkGray: "#696969",
  green: "#41ab5d",
  blue: "#084594"
};

xScale = d3.scale.linear().range([0, canvasWidth]);

yScale = d3.scale.ordinal().rangeRoundBands([0, canvasHeight], barPadding);

state = function(d) {
  return d.State;
};

isNumeric = function(num) {
  return !isNaN(num);
};

svg = d3.select("body").append("svg").attr("id", "chart").attr("width", canvasWidth + margin.left + margin.right).attr("height", canvasHeight + margin.top + margin.bottom);

g = svg.append("g").attr("transform", "translate(" + margin.left + ", " + margin.top + ")");

title = g.append("text").attr("id", "title").attr("x", svg.attr("width") / 4).attr("text-anchor", "middle").text("Unemployment Rates for States");

d3.tsv("unemp_states_us_nov_2013.tsv", function(data) {
  var ascending, barHeight, bars, color, dataset, groups, key, labels, max, min, reorder, textBuffer, textHeight, textSize, values;
  min = 0;
  max = d3.max(data, function(d) {
    return d.Rate;
  });
  xScale.domain([min, max]);
  yScale.domain(data.map(state));
  barHeight = yScale.rangeBand();
  textSize = yScale.rangeBand() / textSizeScale;
  textHeight = yScale.rangeBand() * textVerticalScale;
  textBuffer = yScale.rangeBand() * textHorizontalScale;
  color = d3.scale.linear().domain([min, max]).interpolate(d3.interpolateRgb).range([colors.white, colors.blue]);
  groups = g.append("g").selectAll("g").data(data).enter().append("g").attr("transform", function(d) {
    return "translate(0, " + (yScale(d.State)) + ")";
  });
  bars = groups.append("rect").attr("width", function(d) {
    return xScale(d.Rate);
  }).attr("height", barHeight).attr("fill", function(d) {
    return color(d.Rate);
  });
  labels = groups.append("text").attr("class", "label").attr("x", labelPadding).attr("y", textHeight).attr("font-size", "" + textSize + "em").attr("text-anchor", "end").text(function(d) {
    return d.State;
  });
  values = groups.append("text").attr("class", "value").attr("x", function(d) {
    return xScale(d.Rate) - textBuffer;
  }).attr("y", textHeight).attr("font-size", "" + textSize + "em").attr("fill", "white").attr("text-anchor", "start").text(function(d) {
    return d.Rate;
  });
  dataset = data.slice(0);
  ascending = false;
  reorder = function(key) {
    ascending = !ascending;
    dataset.sort(function(a, b) {
      var aTieBreaker, bTieBreaker, valueA, valueB, verdict;
      valueA = a[key];
      valueB = b[key];
      if (isNumeric(valueA) && isNumeric(valueB)) {
        valueA = +valueA;
        valueB = +valueB;
      }
      if (ascending) {
        verdict = d3.ascending(valueA, valueB);
        if (verdict === 0) {
          aTieBreaker = a.State.toLowerCase();
          bTieBreaker = b.State.toLowerCase();
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
        if (verdict === 0) {
          aTieBreaker = a.State.toLowerCase();
          bTieBreaker = b.State.toLowerCase();
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
    yScale.domain(dataset.map(state));
    return groups.transition().duration(1000).delay(function(d, i) {
      return i * 15;
    }).attr("transform", function(d) {
      return "translate(0, " + (yScale(d.State)) + ")";
    });
  };
  key = "Rate";
  reorder(key);
  d3.selectAll("input").on("click", function() {
    if (this.type === "radio") {
      key = this.value;
      return reorder(key);
    }
  });
  bars.on("mouseover", function() {
    return d3.select(this).attr("fill", colors.darkGray);
  });
  bars.on("mouseout", function() {
    return d3.select(this).transition().duration(250).attr("fill", function(d) {
      return color(d.Rate);
    });
  });
  return d3.selectAll("input").on("change", function() {
    var k, newBars, newGroups, newLabels, newValues;
    if (this.type === "range") {
      k = this.value;
      dataset = data.slice(0, +k + 1 || 9e9);
      groups = svg.select("g").select("g").selectAll("g").data(dataset);
      ascending = !ascending;
      reorder(key);
      groups.exit().each(function() {
        return d3.select(this).select("rect").attr("fill", colors.crimson);
      }).transition().duration(1000).attr("transform", function() {
        return "translate(0, " + (canvasHeight + yScale.rangeBand()) + ")";
      }).remove();
      newGroups = groups.enter().append("g").attr("transform", function() {
        return "translate(0, " + canvasHeight + ")";
      });
      newBars = newGroups.append("rect").attr("width", function(d) {
        return xScale(d.Rate);
      }).attr("height", barHeight).attr("fill", function(d) {
        return colors.green;
      });
      newLabels = newGroups.append("text").attr("x", labelPadding).attr("y", textHeight).attr("font-size", "" + textSize + "em").attr("text-anchor", "end").text(function(d) {
        return d.State;
      });
      newValues = newGroups.append("text").attr("x", function(d) {
        return xScale(d.Rate) - textBuffer;
      }).attr("y", textHeight).attr("font-size", "" + textSize + "em").attr("fill", "white").attr("text-anchor", "start").text(function(d) {
        return d.Rate;
      });
      newGroups.transition().duration(500).attr("transform", function(d) {
        return "translate(0, " + (yScale(d.State)) + ")";
      });
      return newBars.transition().duration(3000).attr("fill", function(d) {
        return color(d.Rate);
      });
    }
  });
});

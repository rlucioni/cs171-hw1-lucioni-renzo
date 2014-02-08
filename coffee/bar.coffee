margin = 
  top:    50, 
  bottom: 10, 
  left:   300, 
  right:  40

canvasWidth = 900 - margin.left - margin.right
canvasHeight = 900 - margin.top - margin.bottom

# bar width
xScale = d3.scale.linear().range([0, canvasWidth])
# vertical bar position
yScale = d3.scale.ordinal().rangeRoundBands([0, canvasHeight], .8, 0)

barHeight = 15

state = (d) -> d.State

svg = d3.select("body")
  .append("svg")
  .attr("width", canvasWidth + margin.left + margin.right)
  .attr("height", canvasHeight + margin.top + margin.bottom)

g = svg.append("g")
  .attr("transform", "translate(#{margin.left}, #{margin.top})")

d3.tsv("unemp_states_us_nov_2013.tsv", (data) ->

  max = d3.max(data, (d) -> d.Rate)
  min = 0

  xScale.domain([min, max])
  yScale.domain(data.map(state))

  groups = g.append("g")
    .selectAll("g")
    .data(data)
    .enter()
    .append("g")
    .attr("transform", (d, i) -> "translate(0, #{yScale(d.State)})")

  bars = groups.append("rect")
    .attr("width", (d) -> xScale(d.Rate))
    .attr("height", barHeight)
)
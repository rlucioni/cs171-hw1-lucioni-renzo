margin = 
    top:    50, 
    bottom: 10, 
    left:   250, 
    right:  40

canvasWidth = 1000 - margin.left - margin.right
canvasHeight = 1000 - margin.top - margin.bottom

# used to define bar padding and to scale text positioning and text size; this solution 
# generalizes better than using fixed bar heights, which causes overlap with larger datasets
barPadding = 0.05
labelPadding = -10
textHorizontalScale = 1.5
textVerticalScale = 0.77
textSizeScale = 21.25

xScale = d3.scale.linear().range([0, canvasWidth])
yScale = d3.scale.ordinal().rangeRoundBands([0, canvasHeight], barPadding)

state = (d) -> d.State

svg = d3.select("body")
    .append("svg")
    .attr("width", canvasWidth + margin.left + margin.right)
    .attr("height", canvasHeight + margin.top + margin.bottom)

g = svg.append("g")
    .attr("transform", "translate(#{margin.left}, #{margin.top})")

title = g.append("text")
    .attr("id", "title")
    .attr("x", svg.attr("width")/2)
    .attr("text-anchor", "middle")
    .text("Unemployment Rates for States")

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
        .attr("transform", (d) -> "translate(0, #{yScale(d.State)})")

    bars = groups.append("rect")
        .attr("width", (d) -> xScale(d.Rate))
        .attr("height", yScale.rangeBand())

    labels = groups.append("text")
        .attr("x", labelPadding)
        .attr("y", yScale.rangeBand()*textVerticalScale)
        .attr("font-size", "#{yScale.rangeBand()/textSizeScale}em")
        .attr("text-anchor", "end")
        .text((d) -> d.State)

    values = groups.append("text")
        .attr("x", (d) -> xScale(d.Rate) - yScale.rangeBand()*textHorizontalScale)
        .attr("y", yScale.rangeBand()*textVerticalScale)
        .attr("font-size", "#{yScale.rangeBand()/textSizeScale}em")
        .attr("fill", "white")
        .attr("text-anchor", "start")
        .text((d) -> d.Rate)

    # TODO: sort ascending on load...
    ascending = true
    reorder = () ->
        ascending = !ascending

        svg.selectAll("rect")
            .sort((a, b) -> 
                if ascending
                    d3.ascending(a[2], b[2])
                else
                    d3.descending(a[2], b[2])
            )

        bars.transition()
            .delay((d, i) -> i * 50)
            .duration(1000)
            # .attr("y", (d, i) -> 
            #     canvasHeight - yScale(d.State))
            .attr("transform", (d, i) ->
                "translate(0, #{yScale(d.State)})")

        svg.selectAll("#label")
            .sort((a, b) -> 
                if ascending
                    d3.ascending(a, b)
                else
                    d3.descending(a, b)
            )
            .transition()
            .delay((d, i) -> i * 50)
            .duration(1000)
            .attr("y", (d, i) -> yScale.rangeBand() - 4)

    bars.on("click", () -> 
        reorder()
    )
)
margin = 
    top:    50, 
    bottom: 10, 
    left:   250, 
    right:  40

canvasWidth = 1000 - margin.left - margin.right
canvasHeight = 1000 - margin.top - margin.bottom

# used to define bar padding and to scale text positioning and text size; this solution 
# generalizes better than using fixed bar heights, which causes overlap with larger datasets
barPadding          = 0.05
labelPadding        = -10
textHorizontalScale = 1.5
textVerticalScale   = 0.77
textSizeScale       = 21.25

colors = 
    white:    "#ffffff"
    blue:     "#084594"
    darkGray: "#696969"

xScale = d3.scale.linear().range([0, canvasWidth])
yScale = d3.scale.ordinal().rangeRoundBands([0, canvasHeight], barPadding)

state = (d) -> d.State

isNumeric = (num) ->
    !isNaN(num)

svg = d3.select("body")
    .append("svg")
    .attr("id", "chart")
    .attr("width", canvasWidth + margin.left + margin.right)
    .attr("height", canvasHeight + margin.top + margin.bottom)

g = svg.append("g")
    .attr("transform", "translate(#{margin.left}, #{margin.top})")

title = g.append("text")
    .attr("id", "title")
    .attr("x", svg.attr("width")/4)
    .attr("text-anchor", "middle")
    .text("Unemployment Rates for States")

d3.tsv("unemp_states_us_nov_2013.tsv", (data) ->
    min = 0
    max = d3.max(data, (d) -> d.Rate) 

    xScale.domain([min, max])
    yScale.domain(data.map(state))

    color = d3.scale.linear()
        .domain([min, max])
        .interpolate(d3.interpolateRgb)
        # nicer color sequence; higher saturation means higher unemployment
        .range([colors.white, colors.blue])

    groups = g.append("g")
        .selectAll("g")
        .data(data)
        .enter()
        .append("g")
        # use a unique key to place bars, avoiding overlaps; this assumes State is unique!
        .attr("transform", (d) -> "translate(0, #{yScale(d.State)})")

    bars = groups.append("rect")
        .attr("width", (d) -> xScale(d.Rate))
        .attr("height", yScale.rangeBand())
        .attr("fill", (d) -> color(d.Rate))

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

    ascending = false
    reorder = (key) ->
        ascending = !ascending

        # sort the data
        data.sort((a, b) ->
            valueA = a[key]
            valueB = b[key]
            
            if isNumeric(valueA) and isNumeric(valueB)
                # convert to int or float, as appropriate
                valueA = +valueA
                valueB = +valueB

            if ascending
                verdict = d3.ascending(valueA, valueB)

                # use lexicographic order of States to break ties
                if verdict == 0
                    aTieBreaker = a.State.toLowerCase()
                    bTieBreaker = b.State.toLowerCase()
                    if aTieBreaker < bTieBreaker
                        return -1
                    else if aTieBreaker > bTieBreaker
                        return 1
                    else
                        return 0
                else
                    return verdict
            else
                verdict = d3.descending(valueA, valueB)
            
                if verdict == 0
                    aTieBreaker = a.State.toLowerCase()
                    bTieBreaker = b.State.toLowerCase()
                    if aTieBreaker > bTieBreaker
                        return -1
                    else if aTieBreaker < bTieBreaker
                        return 1
                    else
                        return 0
                else
                    return verdict
        )

        # critical: update the yScale domain to match the newly sorted data
        yScale.domain(data.map(state))

        groups.transition()
            .duration(1000)
            .delay((d, i) -> i * 25)
            .attr("transform", (d, i) -> "translate(0, #{yScale(d.State)})")

    # initial sort by Rate
    reorder("Rate")

    d3.selectAll("input").on("click", () -> reorder(this.value))

    bars.on("mouseover", () ->
        d3.select(this)
            .attr("fill", colors.darkGray)
    )

    bars.on("mouseout", () ->
        d3.select(this)
            .transition()
            .duration(250)
            .attr("fill", (d) -> color(d.Rate))
    )
)

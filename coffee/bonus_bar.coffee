margin = 
    top:    50, 
    bottom: 10, 
    left:   250, 
    right:  40

canvasWidth = 1000 - margin.left - margin.right
canvasHeight = 1000 - margin.top - margin.bottom

# used to define bar padding and to scale text positioning and text size; immediately fixed 
# bar heights cause overlap with larger datasets
barPadding          = 0.05
labelPadding        = -10
textHorizontalScale = 1.5
textVerticalScale   = 0.77
textSizeScale       = 21.25

colors = 
    white:    "#ffffff"
    crimson:  "#cb181d"
    darkGray: "#696969"
    green:    "#41ab5d"
    blue:     "#084594"

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

    # save these dimensions now, so they can be restored later
    barHeight = yScale.rangeBand()
    textSize = yScale.rangeBand()/textSizeScale
    textHeight = yScale.rangeBand()*textVerticalScale
    textBuffer = yScale.rangeBand()*textHorizontalScale

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
        .attr("height", barHeight)
        .attr("fill", (d) -> color(d.Rate))

    labels = groups.append("text")
        .attr("class", "label")
        .attr("x", labelPadding)
        .attr("y", textHeight)
        .attr("font-size", "#{textSize}em")
        .attr("text-anchor", "end")
        .text((d) -> d.State)

    values = groups.append("text")
        .attr("class", "value")
        .attr("x", (d) -> xScale(d.Rate) - textBuffer)
        .attr("y", textHeight)
        .attr("font-size", "#{textSize}em")
        .attr("fill", "white")
        .attr("text-anchor", "start")
        .text((d) -> d.Rate)

    # use array slice to clone data into dataset
    dataset = data[0..]
    ascending = false
    reorder = (key) ->
        ascending = !ascending
        
        # sort the data
        dataset.sort((a, b) ->
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

        # update yScale to match the newly sorted data
        yScale.domain(dataset.map(state))

        groups.transition()
            .duration(1000)
            .delay((d, i) -> i * 15)
            .attr("transform", (d) -> "translate(0, #{yScale(d.State)})")

    # initial sort by Rate
    key = "Rate"
    reorder(key)

    d3.selectAll("input").on("click", () -> 
        if this.type == "radio"
            key = this.value
            reorder(key)
    )

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

    d3.selectAll("input").on("change", () -> 
        if this.type == "range"
            k = this.value
            # Filter by only considering the first k elements of the original data. 
            # The spec was vague when asking us to filter "to the top-k elements." 
            # This is my interpretation - I think that filtering the size of the original 
            # dataset is more useful than simply trimming bars from the bottom of the chart.
            dataset = data[0..k]

            groups = svg.select("g")
                .select("g")
                .selectAll("g")
                .data(dataset)

            # adjust for entering or exiting groups by reapplying current sort
            ascending = !ascending
            reorder(key)

            # color bars contained in unbound groups red, move these groups to 
            # canvas bottom, and remove from DOM
            groups.exit()
                .each(() -> d3.select(this).select("rect").attr("fill", colors.crimson))
                .transition()
                .duration(1000)
                .attr("transform", () -> "translate(0, #{canvasHeight + yScale.rangeBand()})")
                .remove()

            # bind new groups, spawn at canvas bottom
            newGroups = groups.enter()
                .append("g")
                .attr("transform", () -> "translate(0, #{canvasHeight})")

            # color bars contained in newly bound groups green
            newBars = newGroups.append("rect")
                .attr("width", (d) -> xScale(d.Rate))
                .attr("height", barHeight)
                .attr("fill", (d) -> colors.green)

            newLabels = newGroups.append("text")
                .attr("x", labelPadding)
                .attr("y", textHeight)
                .attr("font-size", "#{textSize}em")
                .attr("text-anchor", "end")
                .text((d) -> d.State)

            newValues = newGroups.append("text")
                .attr("x", (d) -> xScale(d.Rate) - textBuffer)
                .attr("y", textHeight)
                .attr("font-size", "#{textSize}em")
                .attr("fill", "white")
                .attr("text-anchor", "start")
                .text((d) -> d.Rate)

            # move newly bound groups to their appropriate locations, given current sort
            newGroups.transition()
                .duration(500)
                .attr("transform", (d) -> "translate(0, #{yScale(d.State)})")
                
            # fade new bars from green to correct shade of blue
            newBars.transition()
                .duration(3000)
                .attr("fill", (d) -> color(d.Rate))
    )
)

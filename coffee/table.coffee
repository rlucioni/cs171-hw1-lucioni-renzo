d3.text("unemp_states_us_nov_2013.tsv", (error, data) ->

    d3.select("body")
        .append("h1")
        .text("Unemployment Rates for States")

    table = d3.select("body").append("table")

    table.append("caption")
        .html("Unemployment Rates for States<br>Monthly Rankings<br>Seasonally Adjusted<br>Dec. 2013<sup>p</sup>")
    
    tHead = table.append("thead")
    tBody = table.append("tbody")

    # dataset is an array of arrays, one for each row
    dataset = d3.tsv.parseRows(data)

    isNumeric = (num) ->
        !isNaN(num)

    # default to null, in case there is no tie-breaker
    tieBreakerColumn = null
    # test first row of data
    for ix in d3.range(dataset[1].length)
        # use first non-numeric column for tie-breaking
        if !isNumeric(dataset[1][ix])
            tieBreakerColumn = ix
            break

    colors = 
        gray: "#e9e9e9"
        white: "#ffffff"
        crimson: "#cb181d"
        skyBlue: "#a6cee3"
        lightYellow: "#ffff99"

    header = tHead.selectAll("tr")
        # first element contains header text
        .data(dataset[0...1])
        .enter()
        .append("tr")

    rows = tBody.selectAll("tr")
        # other elements contain data
        .data(dataset[1..])
        .enter()
        .append("tr")

    headerCells = header.selectAll("th")
        .data((row) -> row)
        .enter()
        .append("th")
        .style("cursor", "n-resize")
        .style("background-color", colors.gray)
        .text((d) -> d)

    dataCells = rows.selectAll("td")
        .data((row) -> row)
        .enter()
        .append("td")
        .attr("class", (d, column) -> "column-#{column}")
        .text((d) -> d)

    # column at index `sourceColumn` must contain numerical data (can be stored as strings)
    addBars = (sourceColumn, barsColumn) ->
        svgWidth = 100
        svgHeight = 20

        # fetch data from column
        columnData = d3.selectAll(".column-#{sourceColumn}").data().map((n) -> +n)

        xScale = d3.scale.linear()
            .domain([0, d3.max(columnData)])
            .range([0, svgWidth])

        header.insert("th")
        # header.insert("th", ":first-child")
            # will always add a bar chart, so this generalizes
            .data(["Bar Chart"])
            .style("cursor", "n-resize")
            .style("background-color", colors.gray)
            .text("Bar Chart")

        headerCells = header.selectAll("th")

        rows.insert("td")
        # rows.insert("td", ":first-child")
            .data(columnData)
            .attr("class", "column-#{barsColumn}")
            .append("svg")
            .attr("width", svgWidth)
            .attr("height", svgHeight)
            .append("rect")
            .attr(
                "height": svgHeight
                # "width": (d) -> xScale(+d[sourceColumn])
                "width": (d) -> xScale(d)
                "fill": colors.skyBlue
            )

        dataCells = rows.selectAll("td")

    # add bars corresponding to column at index 2 (in this case, "Rate")
    sourceColumn = 2
    barsColumn = 3
    addBars(sourceColumn, barsColumn)

    # remember sort state
    ascending = true
    # initial ascending sort
    rows = rows.sort((a, b) ->
        # Sort by first column - this is the most general solution. It works in
        # the event that there is no third column, and in this case gives the
        # same result as sorting by "Rate."
        valueA = a[0]
        valueB = b[0]
        
        if isNumeric(valueA) and isNumeric(valueB)
            # convert to int or float, as appropriate
            valueA = +valueA
            valueB = +valueB

        verdict = d3.ascending(valueA, valueB)

        if verdict == 0 and tieBreakerColumn != null
            aTieBreaker = a[tieBreakerColumn].toLowerCase()
            bTieBreaker = b[tieBreakerColumn].toLowerCase()
            if aTieBreaker < bTieBreaker
                return -1
            else if aTieBreaker > bTieBreaker
                return 1
            else
                return 0
        else
            return verdict
        )

    zebraStripe = () ->
        rows.style("background-color", (d, row) -> 
                if row % 2 is 1 then colors.gray else colors.white
        )

    colorColumn = (column) ->
        # fetch data from column
        columnData = d3.selectAll(".column-#{column}").data().map((n) ->
            # converts to int or float, as appropriate
            if isNumeric(n) then +n
        )

        color = d3.scale.linear()
            .domain([0, d3.max(columnData)])
            .interpolate(d3.interpolateRgb)
            # nicer color sequence; higher saturation means higher unemployment
            .range([colors.white, colors.crimson])

        d3.selectAll(".column-#{column}")
            .style("background-color", (d) -> color(d))
    
    # apply zebra striping
    zebraStripe()
    # color column at index 2 (in this case, "Rate")
    coloredColumn = 2
    colorColumn(coloredColumn)

    # sorting assumes that "column" order matches dataset order (i.e., an item found in 
    # column 2 in the dataset is expected to be in column 2 of the table)
    headerCells.on("click", (d, column) ->
        ascending = !ascending

        if ascending
            headerCells.style("cursor", "n-resize")
        else
            headerCells.style("cursor", "s-resize")

        rows = rows.sort((a, b) ->
            if d == "Bar Chart"
                column = sourceColumn

            valueA = a[column]
            valueB = b[column]
            
            if isNumeric(valueA) and isNumeric(valueB)
                # convert to int or float, as appropriate
                valueA = +valueA
                valueB = +valueB

            if ascending
                verdict = d3.ascending(valueA, valueB)

                if verdict == 0 and tieBreakerColumn != null
                    aTieBreaker = a[tieBreakerColumn].toLowerCase()
                    bTieBreaker = b[tieBreakerColumn].toLowerCase()
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
            
                if verdict == 0 and tieBreakerColumn != null
                    aTieBreaker = a[tieBreakerColumn].toLowerCase()
                    bTieBreaker = b[tieBreakerColumn].toLowerCase()
                    if aTieBreaker > bTieBreaker
                        return -1
                    else if aTieBreaker < bTieBreaker
                        return 1
                    else
                        return 0
                else
                    return verdict
            )

        # restore zebra striping
        zebraStripe()
        # restore column coloring
        colorColumn(coloredColumn)
    )

    dataCells.on("mouseover", (d, column) ->
        # lightYellow current column
        d3.selectAll(".column-#{column}")
            .style("background-color", colors.lightYellow)
        # lightYellow current row
        d3.select(this.parentNode)
            .style("background-color", colors.lightYellow)
        # restore column coloring
        colorColumn(coloredColumn)
    )

    dataCells.on("mouseout", (d, column) ->
        d3.selectAll(".column-#{column}")
            .style("background-color", null)
        # restore zebra striping
        zebraStripe()
        # restore column coloring
        colorColumn(coloredColumn)
    )
)
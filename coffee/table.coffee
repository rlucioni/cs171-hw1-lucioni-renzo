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
        .style("cursor", "s-resize")
        .style("background-color", "#e9e9e9")
        .text((d) -> d)

    dataCells = rows.selectAll("td")
        .data((row) -> row)
        .enter()
        .append("td")
        .attr("class", (d, column) -> "column-#{column}")
        .text((d) -> d)

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
        # zebra striping
        .style("background-color", (d, row) -> 
            if row % 2 is 1 then "#e9e9e9" else "#ffffff"
        )

    # save sort state
    ascending = true

    colorColumn = (column) ->
        # fetch data from column
        columnData = d3.selectAll(".column-#{column}").data().map((n) ->
            # converts to int or float, as appropriate
            if isNumeric(n) then +n
        )
        color = d3.scale.linear()
            .domain([d3.min(columnData), d3.max(columnData)])
            .interpolate(d3.interpolateRgb)
            .range(["orangered", "silver"])

        d3.selectAll(".column-#{column}")
            .style("background-color", (d) ->
                color(d)
            )

    # color third column (index 2)
    colorColumn(2)

    headerCells.on("click", (d, column) ->
        ascending = !ascending

        if ascending
            headerCells.style("cursor", "n-resize")
        else
            headerCells.style("cursor", "s-resize")

        rows = rows.sort((a, b) ->
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
            .style("background-color", (d, row) -> 
                if row % 2 is 1 then "#e9e9e9" else "#ffffff"
            )

        # restore column coloring
        colorColumn(2)
    )

    dataCells.on("mouseover", (d, column) ->
        # highlight current row
        d3.select(this.parentNode)
            .style("background-color", "#ffff99")
        # highlight current column
        d3.selectAll(".column-#{column}")
            .style("background-color", "#ffff99")
        # restore column coloring
        colorColumn(2)
    )

    dataCells.on("mouseout", (d, column) ->
        # restore zebra striping
        rows.style("background-color", (d, row) -> 
            if row % 2 is 1 then "#e9e9e9" else "#ffffff"
        )
        
        d3.selectAll(".column-#{column}")
            .style("background-color", null)
        # restore column coloring
        colorColumn(2)
    )
)
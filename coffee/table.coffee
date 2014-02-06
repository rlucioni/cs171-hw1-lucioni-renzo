d3.text("unemp_states_us_nov_2013.tsv", (error, data) ->

    d3.select("body")
        .append("h1")
        .text("Unemployment Rates for States")

    table = d3.select("body").append("table")

    table.append("caption")
        .html("Unemployment Rates for States<br>Monthly Rankings<br>Seasonally Adjusted<br>Dec. 2013<sup>p</sup>")
    
    tHead = table.append("thead")
    tBody = table.append("tbody")

    # array of arrays, one for each row
    dataset = d3.tsv.parseRows(data)

    isNumeric = (num) ->
        !isNaN(num)

    tieBreakerColumn = null
    # test first row of data
    for ix in d3.range(dataset[1].length)
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
        .style("background-color", (d, row) -> 
            if row % 2 is 0 then "#e9e9e9" else "#ffffff"
        )

    headerCells = header.selectAll("th")
        .data((row) -> row)
        .enter()
        .append("th")
        .text((d) -> d)

    dataCells = rows.selectAll("td")
        .data((row) -> row)
        .enter()
        .append("td")
        .attr("class", (d, column) -> "column-#{column}")
        .text((d) -> d)

    dataCells.on("mouseover", (d, column) ->
        d3.select(this.parentNode)
            .style("background-color", "#ffff99")
        d3.selectAll(".column-#{column}")
            .style("background-color", "#ffff99")
    )

    dataCells.on("mouseout", (d, column) ->
        rows.style("background-color", (d, row) -> 
            if row % 2 is 0 then "#e9e9e9" else "#ffffff"
        )
        d3.selectAll(".column-#{column}")
            .style("background-color", null)
    )

    headerCells.on("click", (d, column) ->
        rows = tBody.selectAll("tr")
            .sort((a, b) ->
                valueA = a[column]
                valueB = b[column]
                
                if isNumeric(valueA) and isNumeric(valueB)
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
            .style("background-color", (d, row) -> 
                if row % 2 is 0 then "#e9e9e9" else "#ffffff"
            )
    )
)
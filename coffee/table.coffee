d3.text("unemp_states_us_nov_2013.tsv", (error, data) ->

    d3.select("body")
        .append("h1")
        .text("Unemployment Rates for States")

    table = d3.select("body").append("table")

    tHead = table.append("thead")
    tBody = table.append("tbody")

    table.append("caption")
        .attr("class", "upper") 
        .html("Unemployment Rates for States<br>Monthly Rankings<br>Seasonally Adjusted<br>Dec. 2013<sup>p</sup>")

    table.append("caption")
        .attr("class", "lower")
        .html("<sup>p</sup> = preliminary")

    dataset = []
    d3.tsv.parseRows(data, (row) ->
        dataset.push(
            "Rank": row[0], 
            "State": row[1], 
            "Rate": row[2]
        )
    )

    header = tHead.selectAll("tr")
        .data(dataset[0...1])
        .enter()
        .append("tr")

    rows = tBody.selectAll("tr")
        .data(dataset[1..])
        .enter()
        .append("tr")
        .style("background-color", (d, i) -> 
            if i % 2 is 0 then "#f1f1f1" else "#ffffff"
        )

    headerCells = header.selectAll("th")
        .data((row) ->
            row[key] for key of row
        )
        .enter()
        .append("th")
        .text((d) -> d)

    dataCells = rows.selectAll("td")
        .data((row) ->
            row[key] for key of row
        )
        .enter()
        .append("td")
        .attr("class", (d, i) -> "column-#{i}")
        .text((d) -> d)

    dataCells.on("mouseover", (d, i) ->
        d3.select(this.parentNode)
            .style("background-color", "#ffff99")
        d3.selectAll(".column-#{i}")
            .style("background-color", "#ffff99")
    )

    dataCells.on("mouseout", (d, i) ->
        rows.style("background-color", (d, i) -> 
            if i % 2 is 0 then "#f1f1f1" else "#ffffff"
        )
        d3.selectAll(".column-#{i}")
            .style("background-color", null)
    )
)
d3.text("unemp_states_us_nov_2013.tsv", (error, data) ->

    d3.select("body")
        .append("h1")
        # assignment gives permission to hardcode
        .text("Unemployment Rates for States")

    table = d3.select("body").append("table")

    caption = table.append("caption") 
    tHead = table.append("thead")
    tBody = table.append("tbody")

    # assignment gives permission to hardcode
    caption.html("Unemployment Rates for States<br>Monthly Rankings<br>Seasonally Adjusted<br>Dec. 2013<sup>p</sup>")

    dataset = []

    d3.tsv.parseRows(data, (row, ix) ->
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

    headerCells = header.selectAll("th")
        .data((row) ->
            value for key, value of row
        )
        .enter()
        .append("th")
        .text((d) -> d)

    dataCells = rows.selectAll("td")
        .data((row) ->
            value for key, value of row
        )
        .enter()
        .append("td")
        .text((d) -> d)
)
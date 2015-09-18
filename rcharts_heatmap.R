#interactive heatmap
map <- Highcharts$new()
map$addAssets(js = 
                c("https://ajax.googleapis.com/ajax/libs/jquery/1.11.1/jquery.min.js",
                  "https://code.highcharts.com/highcharts.js",
                  "https://code.highcharts.com/highcharts-more.js",
                  "https://code.highcharts.com/modules/exporting.js",
                  "https://code.highcharts.com/modules/heatmap.js"
                )
)
map$chart(type = 'heatmap')
#map$colors(brewer.pal(12, "Paired"))
#map$credits(text = "Patient Name CD")
map$title(text='V&beta; Departure from Normality (high = Clonal Expansion)',
          useHTML=TRUE,
          align = 'left',
          style = list(fontSize = '12px'))
map$series(name = 'vbeta',
           data = list(
             list(y=toJSONArray2(vbeta.heatmap.matrix, json=FALSE),)),
           color = "#cccccc")
map$subtitle(text = 'Patient name CD', align = 'left')
map$addParams(height = 700, width=300, colorAxis = 
                list(
                  min = 0,
                  max = 1,
                  minColor='#ffffcc',
                  maxColor='#800026'
                )
)
map$plotOptions(heatmap =
                  list(borderWidth = 1,
                       borderColor = 'black'),
                column = 
                  listcolumn = list(point = list(events = list(click = drill_function)))
)
map$xAxis(categories = c(0, levels(vbeta.heatmap.data$samp.type)))
map$yAxis(categories = c(0,sort(unique(vbeta.heatmap.data$vbeta))),
          title=list(text = ""), 
          labels = list(enabled = FALSE))
map$legend(align='right',
           layout='vertical',
           margin=0,
           verticalAlign='middle',
           y=25,
           symbolHeight=320)
# custom tooltip
map$tooltip(formatter = "#! function() { return '<b>Day: </b>' + this.series.xAxis.categories[this.point.x] + '<br/>' +
           '<b>TRBV: </b>' + this.series.yAxis.categories[this.point.y] + '</b>'; } !#")

#Histogram of longitudinal data to see the general perturbance of the repertoire
#Includes only clonotypes expanded over 1% of total TCR repertoire
#data frame 'expanded' contains sample collection day under 'collect.day', clonotype percentage under 'pct' and clonotype under 'AA'
h1 <- hPlot(x = "collect.day", y = "pct", group = "AA", data = expanded, type = "column")
#appropriate colour-brewer palet
h1$colors(brewer.pal(12, "Paired"))
h1$legend(enabled=FALSE)
h1$chart(height=700, width=700, zoomType = "xy")
#full screen???
#h1$pane(size="100%")
#h1$title(text = "")
#h1$subtitle(text = input$CD)
h1$yAxis(title = list(text = "Occupied Homeostatic Space, Percentage"), labels = list(formatter = "#! function() {
                                                                                      var pcnt = this.value * 100;
                                                                                      return Highcharts.numberFormat(pcnt,0,',') + '%';} !#"))
h1$xAxis(title = list(text = "Sample Collection Day"))
#show day, clone, seq and percentage in the tooltip
h1$tooltip(formatter = "#! function(){return('<b>Day: </b>' + this.x + '<br/>' +
           '<b>Clone: </b>' + this.series.name + '<br/>' +
           '<b>Percentage: </b>' + Highcharts.numberFormat(100*this.y,2)) + 
           '<b>%</b>';} !#")
#clicking on the bar selects that series only
#stack vs group
h1$plotOptions(
  series = list(##stacking = 'normal',
    point = list(
      events = list(
        click = "#! function() {
        var series = chart.series[0];
        if (series.visible) {
        $(chart.series).each(function(){
        this.setVisible(false, false);
        });
        this.series.setVisible(true, false);
        chart.redraw();
        } else {
        this.series.setVisible(false, false);
        $(chart.series).each(function(){
        this.setVisible(true, false);
        });
        chart.redraw();
        }
        } !#"))
      )
    )
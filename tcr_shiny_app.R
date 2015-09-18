#install RCharts
#install.packages("devtools")
#install.packages("Rcpp")
#library(devtools)
#library(Rcpp)
#install_github('ramnathv/rCharts')
#install.packages("shiny")

require(plyr)
require(dplyr)
require(RColorBrewer)
require(rCharts)
require(shiny)
runApp(list(
  ui = fluidPage(#theme = "bootstrap.css",
    tags$head(tags$script(src = "https://code.highcharts.com/highcharts.js"),
              tags$script(src = "https://code.highcharts.com/highcharts-more.js"),
              tags$script(src = "https://code.highcharts.com/modules/exporting.js"),
              tags$script(src = "https://code.highcharts.com/modules/heatmap.js")
    ),
    inputPanel(align = 'center',
      selectInput(
        inputId = "Patient",
        label = "Patient:",
        choices = cc.out$pt.initials,
      ),
      selectInput(
        inputId = "CD",
        label = "T Cells:",
        choices = cc.out$cd.type,
      )),
    mainPanel(
      tabsetPanel(
        tabPanel("Clonal Space Homeostasis", 
          verticalLayout(
            showOutput("columnchart", "Highcharts"), 
            fixedPanel(radioButtons("stacking", "", list("Grouped" = '', "Stacked" = 'normal'), inline = TRUE),top = "13%", left = "86%"))),
        tabPanel(HTML("V&beta; Departure from Normality"),
            showOutput("heatmap", "Highcharts"))
        #,tabPanel("Clonotypes", plotOutput("ggclonotypes")),
        #tabPanel("Heatmap", plotOutput("ggheatmap", height = "576px", width = "1250px"))
      )
    )
  ),
  server = function(input, output){
    var <- reactive({
      h1.data <- filter(cc.out, pt.initials == input$Patient, cd.type == input$CD) %>% transform(samp.type = factor(samp.type))
    })
      
    output$columnchart <- renderChart2({
      h1 <- hPlot(x = "samp.type", y = "pct", group = "AA.JUNCTION", data = var(), type = "column")
      #appropriate colour-brewer palet
      h1$colors(brewer.pal(12, "Paired"))
      h1$legend(enabled=FALSE)
      #dimensions fit full screen on a 13.3" screen
      h1$chart(height=576, width=1250, zoomType = "xy")
      #full screen???
      #h1$pane(size="100%")
      #h1$title(text = "")
      #h1$subtitle(text = input$CD)
      h1$yAxis(title = list(text = "Occupied Homeostatic Space, Percentage"), labels = list(formatter = "#! function() {
                                                                                            var pcnt = this.value * 100;
                                                                                            return Highcharts.numberFormat(pcnt,0,',') + '%';} !#"))
      h1$xAxis(categories = levels(var()$samp.type),
               title = list(text = "Sample Collection Day"))
      #show day, clone, seq and percentage in the tooltip
      h1$tooltip(formatter = "#! function(){return('<b>Day: </b>' + this.x + '<br/>' +
                 '<b>Clone: </b>' + this.series.name + '<br/>' +
                 '<b>Percentage: </b>' + Highcharts.numberFormat(100*this.y,2)) + 
                 '<b>%</b>';} !#")
      #clicking on the bar selects that series only
      #stack vs group
      h1$plotOptions(
        series = list(stacking = input$stacking,
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
      h1
      })
    #data prep
    var2 <- reactive({
      vbeta.heatmap.data <- filter(vbetas, pt.initials == input$Patient, cd.type == input$CD) %>% 
        select(samp.type, vbeta, clonality.logist) %>%
        transform(samp.type = factor(samp.type), vbeta = as.factor(vbeta)) %>%
        transform(samp.type = as.integer(samp.type), vbeta = as.integer(vbeta)) %>%
        rename(x = samp.type, y = vbeta, value = clonality.logist) %>%
        data.matrix()
    })
    
    
    var3 <- reactive({matrix<- toJSONArray2(var2(), json=FALSE)})
    
    
    var4 <- reactive({
      vbeta.heatmap.data <- filter(vbetas, pt.initials == input$Patient, cd.type == input$CD) %>% 
        select(samp.type, vbeta, clonality.logist) %>%
        transform(samp.type = factor(samp.type))
      })
    
    
    output$heatmap <- renderChart2({
      map <- Highcharts$new()
      map$chart(type = 'heatmap')
      #map$colors(brewer.pal(12, "Paired"))
      #map$credits(text = "Patient Name CD")
      #map$title(text='V&beta; Departure from Normality (high = Clonal Expansion)',
                #useHTML=TRUE,
                #align = 'left',
                #style = list(fontSize = '12px'))
      #data
      map$series(name = 'vbeta',
                 data = var3(),
                 color = "#cccccc")
      #map$subtitle(text = 'Patient name CD', align = 'left')
      #scale and block colours
      map$addParams(height = 576, width=1250, 
                    colorAxis = 
                      list(
                        min = 0,
                        max = 1,
                        minColor='#ffffcc',
                        maxColor='#800026'
                      )
      )
      #full screen????
      #map$pane(size="100%")
      #heatmap options
      map$plotOptions(heatmap =
                        list(borderWidth = 1,
                             borderColor = 'black')
      )
      #adjust the axes
      map$xAxis(categories = c(0, levels(var4()$samp.type)))
      map$yAxis(categories = c(0,sort(unique(var4()$vbeta))),
                title=list(text = ""), 
                labels = list(enabled = FALSE))
      #adjust the legend
      map$legend(align='right',
                 layout='vertical',
                 margin=0,
                 verticalAlign='middle',
                 y=25,
                 symbolHeight=320)
      # custom tooltip
      map$tooltip(formatter = "#! function() { return '<b>Day: </b>' + this.series.xAxis.categories[this.point.x] + '<br/>' +
           '<b>TRBV: </b>' + this.series.yAxis.categories[this.point.y] + '</b>'; } !#")
      # save heatmap as HTML page heatmap.html
      #map$save(destfile = 'heatmap.html')
      map
    })
    
    #output$ggheatmap <- renderPlot ({
      #g.vbeta(input$Patient, input$CD)
    #})
    }
      ))
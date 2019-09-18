library(shiny)
library(dplyr)
library(lubridate)
library(ggplot2)

ui <- fluidPage(
    titlePanel('Shiny Server Monitor'),
    plotOutput('user_chart_today')
)

server <- function(input, output, session) {
    
    filter_user_data_today <- reactive({
        load('/srv/shiny-server/server_status/sysLoad.RData')
        
        Dat %>% 
            mutate(hour = as.POSIXct(trunc(Time, 'mins'))) %>% 
            filter(hour >= as.Date(Sys.time())) %>% 
            group_by(hour, app) %>% 
            filter(Time == max(Time)) %>% 
            slice(1) %>% 
            ungroup %>% 
            arrange(hour) %>% 
	    filter(app != 'shiny-server/server_status')
            #mutate(hour = datetime_to_timestamp(hour))    
    })
    
    output$user_chart_today <- renderPlot({
        filter_user_data_today() %>% 
	    ggplot2::ggplot(data=., aes(x=hour, y=usr, color=app)) + 
            geom_point() + 
            geom_smooth(method='loess', se=FALSE) +
            theme_bw()
    })
    
}

shinyApp(ui = ui, server = server)

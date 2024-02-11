library(shiny)
shard_ad <- 5.4
ad_df <- read.csv("gp_ad.csv")

ui <- fluidPage(
  titlePanel("Ganplank damage calculation"),
  
  sidebarLayout(
    sidebarPanel(
      h2("Level"),
      sliderInput("lvl", "Champion level:",
                  min = 1, max = 18, value = 18
      ),
      # plotOutput("distPlot"),
      h2("Items"),
      radioButtons("sheen",
                   label = NULL,
                   choices = list("Trinity Force" = 1, 
                                  "Essence Reaver" = 2)),
      checkboxGroupInput("items",
                         label = NULL,
                         choices = list("Collector" = 1,
                                        "Bloodthirster" = 2,
                                        "Spear of Shojin" = 3,
                                        "Eclipse" = 4)),
      radioButtons("crit_amp",
                   label = NULL,
                   choices = list("Infinity Edge" = 1, 
                                  "Navori Quickblades" = 2))

    ),
    mainPanel(
      h1("EQ Damage graph"),
      img(src = "Gangplank_Render.webp", height = 360, width = 720)
    )
  )
)
# Define server logic ----
server <- function(input, output) {
  
}

# Run the app ----
shinyApp(ui = ui, server = server)
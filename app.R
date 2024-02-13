library(shiny)

shard_ad <- 5.4
ad_df <- read.csv2("gp_ad.csv", header=TRUE)
Q_dmg <- read.csv2("Q_basedmg.csv", header=TRUE)
E_dmg <- read.csv2("E_basedmg.csv", header=TRUE)

ui <- fluidPage(
  titlePanel("Gangplank damage calculation"),
  sidebarLayout(
    sidebarPanel(
      h2("Level"),
      sliderInput("lvl", "Champion level:",
                  min = 1, max = nrow(ad_df), step = 1, value = nrow(ad_df)),
      
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
      verbatimTextOutput("baseAD"),
      img(src = "Gangplank_Render.webp", height = 360, width = 720)
    )
  )
)

server <- function(input, output) {
  selected_level <- reactive({
    input$lvl
  })
  
  output$baseAD <- renderPrint({
    total_AD <- shard_ad + ad_df[selected_level(), 2]
    
    # Dernière ligne avec champlvl <= à la valeur choisie dans le slider.
    # Permet de sélectionner le niveau maximal du sort disponible au niveau 
    # actuel du champion en maxant les sorts dans l'ordre Q>E>W
    q_damage_row <- tail(subset(Q_dmg, Champion_level <= selected_level()), 1)
    e_damage_row <- tail(subset(E_dmg, Champion_level <= selected_level()), 1)
    
    q_damage <- q_damage_row$Damage
    e_damage <- e_damage_row$Damage
    
    total_damage <- total_AD + q_damage + e_damage
    paste("Total Damage:", total_damage)
  })
}

# Lancer l'application Shiny
shinyApp(ui = ui, server = server)

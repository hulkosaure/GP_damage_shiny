library(shiny)
library(ggplot2)
library(plotly)

shard_ad <- 5.4
ad_df <- read.csv2("gp_ad.csv", header=TRUE)
Q_dmg <- read.csv2("Q_basedmg.csv", header=TRUE)
E_dmg <- read.csv2("E_basedmg.csv", header=TRUE)

ui <- fluidPage(
  titlePanel("Gangplank damage calculation"),
  sidebarLayout(
    sidebarPanel(
      h2("Level and Runes"),
      sliderInput("lvl", "Champion level:",
                  min = 1, max = nrow(ad_df), step = 1, value = nrow(ad_df)),
      checkboxGroupInput("runes",
                         label = NULL,
                         choices = list("First Strike" = 1,
                                        "Second adaptive force shard" = 2)),
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
      h1("EQ damage as a function of target armor"),
      plotlyOutput("dmggraph"),
      img(src = "Gangplank_Render.webp", height = 360, width = 720)
    )
  )
)

server <- function(input, output) {
  selected_level <- reactive({
    input$lvl
  })
  
  output$dmggraph <- renderPlotly({
    Armor <- seq(0, 300, by = 1)
    total_AD <- shard_ad + ad_df[selected_level(), 2]
    if (2 %in% input$runes) {
      total_AD <- total_AD + shard_ad
    }
    
    # Dernière ligne avec champlvl <= à la valeur choisie dans le slider.
    # Permet de sélectionner le niveau maximal du sort disponible au niveau 
    # actuel du champion en maxant les sorts dans l'ordre Q>E>W
    q_damage_row <- tail(subset(Q_dmg, Champion_level <= selected_level()), 1)   
    e_damage_row <- tail(subset(E_dmg, Champion_level <= selected_level()), 1)
    
    # q_damage_row is empty at lvl 1causing the total damage sum to return 
    # nothing. Initialising Q base dmg at 0 solves this problem.
    q_damage <- ifelse(nrow(q_damage_row) > 0, q_damage_row$Damage, 0)
    e_damage <- e_damage_row$Damage
    
    prem_damage <- total_AD + q_damage + e_damage
    
    # E ignores 40% armor
    Target_armor <- Armor*0.6
    
    # Damage is postmitigation damage. It was renamed for tooltip clarity, as 
    # I couldn't find a way to display a custom tooltip and the line 
    # at the same time
    Damage <- prem_damage * (100 / (100 + Target_armor))
    
    # First Strike increases post-mitigation damage by 7%
    if (1 %in% input$runes) {
      Damage <- Damage * 1.07
    }

    df <- data.frame(Armor = Armor, Damage = Damage)
    p <- ggplot(df, 
                aes(x = Armor, 
                    y = Damage)) +
      geom_line(alpha = 1) +
      labs(x = "Armor",
           y = "Post-mitigation damage")
    p <- ggplotly(p, dynamicTicks = TRUE)
    p
  })
}

shinyApp(ui = ui, server = server)

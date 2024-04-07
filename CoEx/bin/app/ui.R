library(shiny)
library(shinythemes)
library(DT)
library(dplyr)
library(ggplot2)
library(tibble)
library(tidyr)
library(RColorBrewer)
library(Seurat)
library(SeuratObject)
library(glue)


# Read the clustered data from the specified file path
data <- readRDS(file.path("../..", "input/clustereddata.rds"))

# Read the cemeta object from the specified file path
cemeta <- readRDS(file.path("../..", "source/cemeta.rds"))

# Initialize the genes variable with a default value
genes <- "No genes selected"

# Define UI for application that draws a histogram
fluidPage(
  theme = shinytheme("cosmo"),
  # shinythemes::themeSelector(),
  navbarPage(
    "CoExpression",
    # first tab for info and meta data visualistaion
    tabPanel(
      "MetaData",
      sidebarLayout(
        sidebarPanel(
          h4("information type"),
          # asks for variable name
          selectInput(
            "meta_data", "metadata",
            colnames(cemeta)[2:(ncol(cemeta) - 2)]
          )
        ),
        mainPanel(
          tabsetPanel(
            type = "tabs",
            # displays metadata plot
            tabPanel(
              " Information plot",
              plotOutput("meta_plot"),
              downloadButton("download_meta_plot", "Download"),
            ),
            # display asummary of the variable
            tabPanel("Summary", verbatimTextOutput("meta_summary")),
          )
        )
      )
    ),
    # second tab for marker selection
    tabPanel(
      "Markers",
      DT::dataTableOutput("mtable"),
      actionButton("save_button", "Save Selected genes"),
      actionButton("clear_button", "Clear Selection"),
      verbatimTextOutput("selectedRows")
    ),

    # third tab panel for data expression
    tabPanel(
      "Figures",
      # first sub tab for gene expression summary
      sidebarLayout(
        sidebarPanel(
          h4("genes"),
          selectInput(
            "gene1", "gene1",
            genes
          ),
          selectInput(
            "gene2", "gene2",
            genes
          ),
          actionButton("generate_gene_sum", "generate gene summary"),
        ),
        mainPanel(
          tabsetPanel(
            type = "tabs",
            # display gene summary
            tabPanel(
              "Gene expression summary",
              dataTableOutput("gene_summary"),
            )
          )
        )
      ),
      # second sub tab for coexpression plot
      sidebarLayout(
        sidebarPanel(
          h4("expression threshold"),
          numericInput("Threshold1", label = "Threshold for 1st gene", value = 1, min = 0, max = ceiling(max(data@assays[["RNA"]]@data)) + 0.1),
          numericInput("Threshold2", label = "Thresholdfor 2nd gene", value = 1, min = 0, max = ceiling(max(data@assays[["RNA"]]@data)) + 0.1),
          p(glue('range of expression level in this dataset is between 0 and {ceiling(max(data@assays[["RNA"]]@data))}')),
          actionButton("generate_plot", "generate plot"),
          hr(),
          hr(),
          wellPanel(
            "Download Subset",
            checkboxGroupInput("check_cluster",
              label = h3("Check cluster"),
              choices = sort(unique(cemeta$seurat_clusters))
            ),
            checkboxGroupInput("check_coex",
              label = h3("Check coexpression type"),
              choices = list("PP" = "PP", "NP" = "NP", "PN" = "PN", "NN" = "NN")
            ),
            downloadButton("download", "Download subset"),
          )
        ),
        mainPanel(
          tabsetPanel(
            type = "tabs",
            # displays umap plot
            tabPanel(
              "UMAP plot",
              plotOutput("coex_plot"),
              downloadButton("download_coex_plot", "Download")
            ),
            # displays bar plot
            tabPanel(
              "Bar plot",
              plotOutput("coex_bar_plot"),
              downloadButton("download_coex_bar_plot", "Download")
            ),
            # displays stacked bar plot
            tabPanel(
              "Stacked Bar plot",
              plotOutput("coex_stacked_bar_plot"),
              downloadButton("download_coex_stacked_bar_plot", "Download")
            ),
            # display table
            tabPanel(
              "Table",
              dataTableOutput("coex_table"),
              downloadButton("download_coex_table", "Download")
            ),
          )
        )
      )
    ),
    # fourth sub tab for help
    tabPanel(
      "Help!",
      verbatimTextOutput("help1"),
      verbatimTextOutput("help2"),
      verbatimTextOutput("help3"),
    )
  )
)

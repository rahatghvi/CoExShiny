#' create CoExShiny app
#'
#' @description
#' This function takes a suerat object as input and creates a shiny web app. The files contain metadata and a data set containing differentially expressed markers.
#'
#'
#'
#' @param data a seurat object that has been clustered.
#' @param logfc numeric value for logfc threshold for markers
#' @param pval numeric value for p value threshold for markers
#' @param dirname character string for name of the app's directory name
#'
#' @return directory that contains the CoExShiny app and its dependencies
#' @export
#'
#' @import shiny
#' @import dplyr
#' @import tidyr
#' @import SeuratObject
#' @import Seurat
#' @import glue
#'
#' @examples
#' create_coex_files(neural, logfc=1 ,  pval = 0.1, dirname = "CoEx")
#'
create_coex_files <- function(data , logfc = 1, pval = 0.1, dirname = "CoEx") {
  workingdiro <- getwd()
  dir.create(dirname)
  workingdir <- paste0(workingdiro, "/", dirname)
  setwd(workingdir)

  # create directory
  dir.create("source")
  dir.create("bin")
  dir.create("bin/app")
  dir.create("input")

  # create markers file
  marker <- FindAllMarkers(data, only.pos = TRUE, logfc.threshold = logfc)
  markers <- subset(marker, p_val_adj < pval) |>
    dplyr::arrange(nchar(gene), gene)

  # create metadata file
  cemeta <- as_tibble(cbind(tibble::rownames_to_column(data@meta.data, var = "sampleID")))
  umapcoords <- tibble::rownames_to_column(as_tibble(data@reductions[["umap"]]@cell.embeddings, rownames = NA), var = "sampleID")
  cemeta <- cemeta |>
    full_join(umapcoords,
              by = join_by(sampleID)
    )


  # create files
  saveRDS(markers, file.path("source/markers.rds"))
  saveRDS(cemeta, file.path("source/cemeta.rds"))


  # save data
  saveRDS(data, file.path("input/clustereddata.rds"))

  # create app files
  file.create(file.path("bin/app", "ui.R"))
  file.create(file.path("bin/app", "server.R"))

  ui_path <- system.file("ui_script.txt", package = "CoExShiny")
  server_path <- system.file("server_script.txt", package = "CoExShiny")

  ui_content <- readLines(ui_path)
  server_content <- readLines(server_path)

  ui <- glue('{paste(ui_content, collapse = "\n")}')
  server <- glue('{paste(server_content, collapse = "\n")}')

  writeLines(ui, "bin/app/ui.R")
  writeLines(server, "bin/app/server.R")

  # set working dir to original
  setwd(workingdiro)
}

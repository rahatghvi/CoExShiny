#' run CoExShiny app
#'
#' @param absolutefilePath absolute file path to the directory created by creat_coex_files() command
#'
#' @return opens the shiny web app in a browser
#' @export
#'
#'
CoExApp <- function(absolutefilePath ){
  setwd(absolutefilePath)
  appDir <- file.path( absolutefilePath, "bin/app")
  shinyAppDir(appDir)
}


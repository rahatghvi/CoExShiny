#' run CoExShiny app
#'
#' @param absolutefilePath absolute file path to the directory created by creat_coex_files() command
#'
#' @return opens the shiny web app in a browser
#' @export
#'
#'
#' @examples
#' CoExApp("CoEx")
#'
CoExApp <- function(filePath = "CoEx"){
  appDir <- file.path( filePath, "bin/app")
  shinyAppDir(appDir)
}


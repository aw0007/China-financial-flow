# Project paths for every R script, found from the .project-root marker.

find_root <- function(start = getwd()) {
  d <- normalizePath(start, winslash = "/", mustWork = FALSE)
  repeat {
    if (file.exists(file.path(d, ".project-root"))) return(d)
    parent <- dirname(d)
    if (parent == d) stop("No .project-root marker above ", start)
    d <- parent
  }
}

ROOT    <- find_root()
RAW     <- file.path(ROOT, "data", "raw")
DERIVED <- file.path(ROOT, "data", "derived")
OUT     <- file.path(ROOT, "output")
AIDDATA <- file.path(RAW, "AidDatas_Global_Chinese_Development_Finance_Dataset_Version_3_0",
                     "AidDatas_Global_Chinese_Development_Finance_Dataset_Version_3_0")

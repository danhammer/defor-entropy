library(reshape)

prep.data <- function(out.name, force = FALSE) {
  ## Retrieve data from S3 and concatenate the results into a single
  ## text file, if separated into more than one part
  out.path <- paste("../../data/processed/", out.name, sep="")
  if (!file.exists(out.path) | force == TRUE) {
    system("s3cmd get s3://forma-analysis/entropy/* ../../data/raw/long-form/", wait=TRUE)
    cat.cmd <- paste("cat ../../data/raw/long-form/* > ", out.path, sep="")
    system(cat.cmd, wait=TRUE)
  }
  else {
    print("File exists. Set FORCE to True to replace file.")
  }
}

out.code <- prep.data()






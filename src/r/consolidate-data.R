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

entropy <- function(p.coll) {
  ## Return the entropy measure in bits of the probability collection
  ## in p.coll
  -1 * sum(p.coll * log2(p.coll))
}

shannon.entropy <- function(coll, probs = FALSE, normalize = TRUE) {
  ## A measure of dipsersion or entropy is an increasing function of
  ## the shannon entropy measure.
  if (!probs) {
    T <- sum(coll)
    coll <- coll / T
  }
  H <- entropy(coll)
  if (normalize) {
    N <- length(coll)
    I <- entropy(rep(1/N), N))
    return(H/I)
  }
  else {
    return(H)
  }
}


out.code <- prep.data()



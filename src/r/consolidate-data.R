library(ggplot2)
library(plm)

prep.data <- function(out.name, force = FALSE) {
  ## Retrieve data from S3 and concatenate the results into a single
  ## text file, if separated into more than one part
  out.path <- paste("../../data/processed/", out.name, sep="")
  if (file.exists(out.path) == FALSE | force == TRUE) {
    system("s3cmd get s3://forma-analysis/entropy/long-form/* ../../data/raw/long-form/", wait=TRUE)
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
  p.coll <- p.coll[p.coll > 0]
  -1 * sum(p.coll * log2(p.coll))
}

shannon.entropy <- function(coll, probs = FALSE, normalize = TRUE) {
  ## A measure of dipsersion or entropy is an increasing function of
  ## the shannon entropy measure.
  if (probs == FALSE) {
    T <- sum(coll)
    coll <- coll / T
  }
  H <- entropy(coll)
  if (normalize == TRUE) {
    ## Normalize by dividing by the maximum amount of entropy, given
    ## the number of observations
    N <- length(coll)
    I <- entropy(rep(1/N, N))
    return(H/I)
  }
  else {
    return(H)
  }
}

graph.entropy <- function(df, graph.name) {
  ## Create a data frame to graph
  ets <- aggregate(df$rate, by=list(df$date), FUN=shannon.entropy)
  names(ets) <- c("date", "entropy")
  g.data <- data.frame(date = as.Date(ets$date), entropy = ets$entropy)

  ## Generate and save graph to images directory
  fname <- paste("../../write-up/images/", graph.name, sep="")
  g <- ggplot(g.data, aes(x = date, y = entropy)) + geom_line()
  ggsave(filename = fname, plot = g)
}

## Grab data from S3 if not already downloaded
out.code <- prep.data("gadm-ts.txt")

## Read in data, normalize total pixel hits
data <- read.table("../../data/processed/gadm-ts.txt")
names(data) <- c("iso", "gadm", "date", "forma.idx")
data$forma.idx <- data$forma.idx / 100

## Convert data frame to panel data frame, with GADM as the unit
## variable
data$date <- as.Date(data$date)
data <- pdata.frame(data, c("gadm", "date"))

## Generate a variable indicating the rate of pixel hits; remove
## observations for 2005-12-31, which has no observable rate (first
## period)
data$lag.total <- lag(data$forma.idx)
data$rate <- data$forma.idx - data$lag.total
gadm.data <- data <- data[!is.na(data$rate),]

## Aggregate the rate data by ISO3 code and date, effectively sum over
## all GADM IDs within an ISO code for each period
iso.data <- aggregate(data$rate, by=list(data$iso, data$date), FUN=sum)
names(iso.data) <- c("iso", "date", "rate")

## Graph the entropy at the GADM, sub-province level
graph.entropy(gadm.data, "gadm-entropy.png")

## Graph the entropy at the ISO, country level
graph.entropy(iso.data, "iso-entropy.png")

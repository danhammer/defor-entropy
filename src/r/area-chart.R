library(ggplot2)
library(plyr)
library(reshape)

setwd("~/code/github/danhammer/defor-entropy/src/r/")

source("consolidate-data.R")

load("../../data/processed/iso-data.Rdata")
data <- ddply(iso.data, c("date"), transform, sum=sum(rate))

data["prop"] <- data$rate/data$sum

sub.data <- data[data$iso %in% c("IDN", "BRA", "MYS"), ]
sub.data$date <- as.Date(sub.data$date)
sub.data <- sub.data[sub.data$date >= as.Date("2008-01-01"), ]


p <- ggplot(sub.data, aes(date, prop))
p + geom_bar(aes(colour = iso, fill= iso), stat="identity")

# better colors!
p + scale_fill_hue(l=40) + scale_colour_hue(l=40)

ggsave("../../write-up/images/stacked-shares-BRA-IDN-MYS.png")

# graph # of countries accounting for >= 1% of alerts, by period

percent <- function(df, minprob=0.01) {
  # e.g. percent(data, .01)
  data <- data[data$prop >= minprob, ]
  agg.data <- aggregate(data, by=list(data$date), FUN=length)
  agg.data$date <- as.Date(agg.data$Group.1)
  print(tail(agg.data))

  minprob.name <- round(minprob * 100)
  ylabel <- sprintf("Number of countries with %d percent of defor", minprob.name)

  ggplot(agg.data, aes(x=date, y=rate)) + geom_line() + ylab(ylabel) + xlab("")

  ggsave(sprintf("../../write-up/images/%dpercent.png", minprob.name))
}

share.topN <- function(df, n) {
  # Of the top N countries, graph their share of all alerts

  # sort by date, then order by prop from highest to lowest
  df.ordered <- df[order(df$date, -df$prop), ]

  # for each date, get the top N observations
#  aggregate(df.ordered$prop, list(df.ordered$date), function(df1) head(df1, n))

  # split into dataframes by date
  df.grouped <- split(df.ordered, df.ordered$date)

  # get the largest N elements for prop
  df.topN <- sapply(df.grouped, function(df1) head(df1$prop, n))

  # sum up the values for each group
  df.sums <- sapply(df.topN, sum)

  
  # effectively do a reshape from wide to long form #
  ###################################################
  
  # collect names of fields (which are the dates)
  dates <- as.data.frame(names(df.sums))

  # prep a dates dataframe, including id for merge
  names(dates) <- c("date")
  dates$id <- 1:length(dates$date)

  # add an id field, for merge
  df.sums <- as.data.frame(df.sums)
  names(df.sums) <- "prop"
  df.sums$id <- 1:length(df.sums$prop)

  # merge in date field
  df.sums <- merge(df.sums, dates)
  df.sums$date <- as.Date(df.sums$date)
  
  return(df.sums)
}
  
topN.for.linegraph <- function(df, N) {
  # lazy-man's graphing - coerce this dataframe to work with
  # exising linegraph function.

  # get the top-N data
  df <- share.topN(df, N)

  # need an "iso" code, which'll be a number
  pseudo.iso <- sprintf("%d", N)

  # assign it to the iso column, which is used as a filter
  df$iso <- pseudo.iso

  # create a rate field expected by the function
  df$rate <- df$prop

  # graph the data, using the fake iso code as part of the filename
  graph.linegraph(df, "2008-01-01", "rate", pseudo.iso)
}

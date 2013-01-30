library(ggplot2)
library(plyr)

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







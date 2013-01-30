library(ggplot2)
library(plyr)

load("../../data/processed/iso-data.Rdata")
data <- ddply(iso.data, c("date"), transform, sum=sum(rate))

data["prop"] <- data$rate/data$sum

sub.data <- data[data$iso %in% c("IDN", "BRA", "MYS"), ]
sub.data <- sub.data[as.Date(sub.data$date) >= as.Date("2008-01-01"), ]


p <- ggplot(sub.data, aes(date, prop))
p + geom_area(aes(colour = iso, fill= iso), position = 'stack')  


# graph # of countries accounting for >= 1% of alerts, by period

data.1 <- data[data$prop >= .01, ]
agg.1 <- aggregate(data.1, by=list(onepercent$date), FUN=length)
agg.1$date <- as.Date(agg.1$Group.1)

ggplot(agg.1, aes(x=a$date, y=a$rate)) + geom_line() + ylab("countries with 1% of total") + xlab("")
ggsave("../../write-up/images/1percent.png")

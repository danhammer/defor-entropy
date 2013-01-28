library(ggplot2)
library(plyr)

load("../../data/processed/iso-data.Rdata")
data <- ddply(iso.data, c("date"), transform, sum=sum(rate))

data["prop"] <- data$rate/data$sum

sub.data <- data[data$iso %in% c("IDN", "BRA", "MYS"), ]
sub.data <- sub.data[as.Date(sub.data$date) >= as.Date("2008-01-01"), ]

p <- ggplot(sub.data, aes(date, prop))
p + geom_area(aes(colour = iso, fill= iso), position = 'stack')  

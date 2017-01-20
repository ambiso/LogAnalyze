library(zoo)
library(chron)
library(xts)

usage.raw <- read.csv("out.csv", stringsAsFactors = FALSE)
usage.raw$Timestamp <- as.POSIXct(usage.raw$Timestamp, format = "%Y-%m-%d %H:%M:%S")
usage.zoo <- zoo(usage.raw$Users, usage.raw$Timestamp)
complete.zoo <- merge(usage.zoo, zoo(, seq(start(usage.zoo), end(usage.zoo), by = "15 min")), all = TRUE)
complete.zoo <- na.locf(complete.zoo, na.rm = TRUE)

save_plot <- function(time_range, complete) {
    hourly.zoo <- last(to.hourly(complete.zoo), time_range)
    png(paste0(time_range, ".png"), width = 1000, height = 800)
    par(mar=c(3,5,2,2))
    plot(hourly.zoo$complete.zoo.Open, main = 'Users over time', ylab = 'Users', xlab = '', col = grey(.65), lwd = 2)
    x <- index(hourly.zoo$complete.zoo.Open)
    y <- coredata(hourly.zoo$complete.zoo.Open)
    # Smoothed with lag:
    # average of current sample and 29 previous samples (red)
    # f20 <- rep(1/30, 30)
    # y_lag <- filter(y, f20, sides=1)
    # lines(x, y_lag, col="red")

    # Smoothed symmetrically:
    # average of current sample, 10 future samples, and 10 past samples (blue)
    f21 <- rep(1/21,21)
    y_sym <- filter(y, f21, sides=2)
    lines(x, y_sym, col="blue")
    dev.off()
}

save_plot("24 hours", complete)
save_plot("72 hours", complete)
save_plot("4 weeks", complete)
save_plot("12 months", complete)

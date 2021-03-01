# ggsurvival

This package lets you easily plot survival information in [ggplot2](https://ggplot2.tidyverse.org/).

## Installation
Install the ggbrace package from the git repository:
``` r
devtools::install_github("solatar/ggsurvival")
```

## Default braces
Load the package, create your survival plot:
``` r
library(ggsurvival)
library(ggplot2)

#to showcase ggsurvival, let's create a test data.frame
survtest <- data.frame(
  time = sample(seq(30),50,replace = T),
  status = sample(1:2, 50, replace = T),
  condition1 = sample(c("wt","ko"), 50, replace = T),
  condition2 = sample(c("female", "male"), 50, replace = T)
)

ggplot() +
  geom_surv(aes(time, status, color=condition1, linetype=condition2), data=survtest)
```

<img src="readme_files/surv1.png"/>

That's already it! Your data.frame needs to have at least 2 columns: one for the survival time and one for the survival status. For the status column take care that the following is true:
- 2: death
- 1: censored (drop out of study)
- NA: will be ignored
- everything else: alive

The survival curve follows a couple of rules:
1) The total sample number is normalized to 100 for each condition.
2) In the beginning a death event will lead to a drop of 1 unit (a unit is number of samples / 100).
3) With each censored event, following death events lead to a larger drop.
4) If a censored event is the last event, the curve will not drop to 0 but remain at where it is right now.
5) An alive status will not lead to a drop but may mark the end of the line if it is the last event.

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

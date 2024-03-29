require(tidyverse)
require(MASS)
require(broom)
require(ggplot2)

d <- read.delim('./../../derivatives/GLM/XX.csv', header = FALSE, sep = ' ') |>
  as_tibble()|>
  setNames(c('subID', 'age', 'sex', 'NIHSS', 'treatment', 'mRS', 'WMH')) %>% 
  mutate(mRS = if_else(mRS == 1.83673, median(mRS), mRS)
    , mRS = factor(mRS, ordered = TRUE)
    , logWMH = log10(WMH))
  
d

d$mRS
d$WMH

mdl <- polr(formula = mRS ~ NIHSS + treatment + log10(WMH), data = d)

mdl|>
  tidy(conf.int = TRUE, conf.level = .95, exponentiate = TRUE, p.values = TRUE)

newdata <- tibble(WMH = seq(from = min(d$WMH), to = max(d$WMH), length.out = 100)
                  , NIHSS = mean(d$NIHSS))

newdata <- bind_cols(newdata, treatment = 0) |> 
  bind_rows(bind_cols(newdata, treatment = 1))

dd <- predict(mdl, type = 'probs', newdata = newdata) |> 
  bind_cols(WMH = newdata) |> 
  pivot_longer(cols = 1:7, names_to = 'mRS', values_to = 'prob') |> 
  mutate(mRS = factor(mRS, ordered = TRUE))


dd |> 
  arrange(mRS, 'desc') |> 
  ggplot(aes(x = WMH/1000, y = prob, fill = fct_rev(mRS))) +
  geom_area() +
  scale_x_continuous(name = 'WMH [ml]', transform = 'log10', breaks = c(.1, 1, 10,100), expand = expansion(0,0)) +
  scale_y_continuous(name = 'Probability', labels = scales::percent_format(), expand = expansion(0,0)) +
  facet_grid(~treatment, labeller = as_labeller(c(`0` = 'Placebo', `1` = 'rtPA'))) +
  theme_minimal() +
  scale_fill_ordinal(name = 'mRS') +
  guides(fill = guide_legend(reverse = TRUE, nrow = 1)) +
  theme(legend.direction = 'horizontal', legend.position = c(.5,.04)
        , legend.background = element_rect())


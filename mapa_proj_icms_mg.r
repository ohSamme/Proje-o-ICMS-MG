library(geobr)
library(ggspatial)
library(tseries)
library(dplyr)
library(tidyverse)
library(readxl)
library(lubridate)
library(forecast)
library(xlsx)
library(openxlsx)

base_def <- read_excel("base.xlsx") %>%
  select(1,2,4) %>% 
  purrr::set_names("id", "date", "value") %>% 
  mutate(date = as.Date(date))

projecoes <- list()

#projeção
for (id in unique(base_def$id)) {
  tryCatch({
    icms <- ts(base_def$value[base_def$id == id], start = c(2010, 1), end = c(2022, 12), frequency = 12)
    modelo <- HoltWinters(icms)
    projecao <- forecast(modelo, h = 12)
    projecoes[[as.character(id)]] <- projecao$mean
  }, error = function(err) {
    cat("Error occurred for ID:", id, "\n")
  })
}

projecoes_df <- bind_cols(projecoes) %>% 
  mutate(date = seq.Date(from = ymd("2023-01-01"),
                         to = ymd("2023-12-01"), 
                         by = "month")) %>% 
  gather(key = id, value = value, -date) %>% 
  select(date, id, value) %>% 
  mutate(id = as.double(id))

db <- bind_rows(base_def, projecoes_df) %>% 
  spread(key = id, value = value)
write.xlsx(db, "projecoes.xlsx")

last_date_adj <- base_def %>% 
  filter(date >= "2022-01-01") %>% 
  select(date, id, value) %>% 
  mutate(id = as.double(id))

merged_df <- bind_rows(projecoes_df, last_date_adj) %>% 
  arrange(date, id)

db_acum <- merged_df %>% 
  group_by(id, year(date)) %>%
  mutate(soma = sum(value)) %>% 
  filter(month(date) == 12) %>%
  ungroup() %>% 
  group_by(id) %>% 
  mutate(variacao = soma/lag(soma)-1) %>%
  ungroup() %>% 
  select(date, id, variacao) %>% 
  drop_na()

code_municipios <- read.csv(file = "municipios.csv") %>% 
  rename(id = IBGE) %>% 
  select(-pop, -pop_mun) %>% 
  as_tibble()

db_plot_crude <- inner_join(db_acum, code_municipios, by = "id") %>% 
  rename(code_muni = IBGESETE)

all_mun_mg <- read_municipality(code_muni=31, year=2010)

db_plot <- db_plot_crude %>% 
  left_join(all_mun_mg) %>% 
  select(-date) %>% 
  mutate(variacao = variacao*100)

#tratando outliers
db_plot_ <- db_plot %>% 
  arrange(variacao) %>% 
  filter(variacao > -100 & variacao < 100)

#mapa projetado por municipio
ggplot(data = db_plot_) +
  geom_sf(aes(geometry = geom, fill = variacao, color = "NA")) +
  scale_fill_gradientn(colours = c("black", "blue", "red", "yellow")) + 
  coord_sf(xlim = c(-51, NA),
           ylim = c(NA, -14)) +
  theme(legend.title = element_blank())

#media icms por regiao macro
media_proj_macro <- db_plot_crude %>% 
  group_by(macro) %>% 
  mutate(var_media = mean(variacao)) %>% 
  select(nmacro, var_media) %>% 
  unique()

#media icms por regiao mico
media_proj_micro <- db_plot_crude %>% 
  group_by(micro) %>% 
  mutate(var_media = mean(variacao)) %>% 
  select(nmicro, var_media) %>% 
  unique() %>%
  as.data.frame()

write.xlsx(media_proj_macro, "proj_icms_macro.xlsx")
write.xlsx(media_proj_micro, "proj_icms_micro.xlsx")
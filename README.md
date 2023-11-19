# Projecao de ICMS para o Estado de Minas Gerais (2023) - Modelo Econometrico Holt-Winters

Este codigo em R realiza a projecao do Imposto sobre Circulacao de Mercadorias e Servicos (ICMS) para o estado de Minas Gerais no ano de 2023. O modelo econômico utilizado eh o Holt-Winters, uma tecnica de previsao que leva em consideracao tendencias e sazonalidades nos dados temporais.

Requisitos:
geobr
ggspatial
tseries
dplyr
tidyverse
readxl
lubridate
forecast
xlsx
openxlsx

Fluxo do Codigo:
Carregamento e Preparacao dos Dados:

Leitura dos dados da planilha Excel ("base.xlsx").
Selecao das colunas relevantes.
Transformacao da coluna de data para o formato Date.
Projecao do ICMS:

Utilizacao do modelo Holt-Winters para cada ID (representando diferentes regioes/municipios).
Armazenamento das projecoes em uma lista.
Consolidacao das Projecoes:

Transformacao das projecoes em um dataframe.
Ajuste das datas para o ano de 2023.
Unificacao dos dados originais e das projecoes.
Calculo de Acumulados e Variacoes:

Criacao de um dataframe com a soma acumulada por ano e calculo da variacao.
Filtragem para considerar apenas os valores de dezembro.
Visualizacao Geografica:

Leitura do arquivo CSV "municipios.csv" para obter codigos IBGE dos municipios.
Uniao dos dados com informacoes geoespaciais dos municipios de Minas Gerais.
Criacao de um mapa de variacao do ICMS por municipio com escala de cores.
Analise por Regiao:

Calculo da media da variacao do ICMS por regiao macro e micro.
Exportacao de Resultados:

Exportacao das medias por regiao macro e micro para arquivos Excel ("proj_icms_macro.xlsx" e "proj_icms_micro.xlsx").
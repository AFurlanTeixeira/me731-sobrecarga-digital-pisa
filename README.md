# ME731 — Projeto 2: Sobrecarga digital e desempenho (PISA 2022)

Análise multivariada (componentes principais, agrupamento, regressão multivariada, MANCOVA e meta-análise intrapaís) da relação entre hábitos digitais dos estudantes e desempenho em 74 países e economias do PISA 2022.

Relatório, dividido por seções: [`relatorio/`](relatorio/README.md)

## Estrutura

```
python/
  01_agrega_pisa.py             agrega os microdados do aluno por país (pesos, valores plausíveis, BRR)
R/
  00_executar_tudo.R            ponto de entrada: carrega as funções e roda as etapas em ordem
  01_dados_descritiva.R         amostra analítica, descritiva e correlações
  02_diagnosticos.R             esfericidade de Bartlett, Mardia, atípicos (gráfico qui-quadrado)
  03_acp.R                      componentes principais, escolha de K e bootstrap
  04_agrupamento.R              Ward + k-médias, silhueta e estabilidade
  05_desempenho.R               regressão multivariada, MANOVA e MANCOVA
  06_entre_dentro.R             meta-análise intrapaís e contraste entre × dentro dos países
  07_sensibilidade.R            análises de sensibilidade
  funcoes/
    diagnosticos.R              Bartlett, KMO, Mardia, Mahalanobis
    acp.R                       análise paralela, vara quebrada, congruência, bootstrap da ACP
    agrupamento.R               silhueta, Rand ajustado, Ward + k-médias
    modelos.R                   Λ de Wilks (F de Rao e χ² de Bartlett), meta-análise, correlação parcial
    saida.R                     gravação de tabelas e figuras
data/
  pisa2022_paises.csv           80 países × indicadores (saída da etapa Python)
  pisa2022_gap_intrapais.csv    diferenças intrapaís com EP BRR (saída da etapa Python)
  rotulos_paises.json           nomes dos países (rótulos oficiais do arquivo PISA)
results/
  tables/  figures/  log_execucao.txt
relatorio/
  README.md                     capa e índice
  00_resumo.md … 12_apendice_reprodutibilidade.md
```

Os arquivos `R/01_…` a `R/07_…` não rodam isoladamente: cada etapa usa os objetos criados pelas anteriores e todas compartilham a mesma sequência de números aleatórios. Execute sempre `R/00_executar_tudo.R`.

## Reprodução

```bash
# Etapa 1 (opcional: os CSVs já estão em data/). Requer pandas + pyarrow (ou pyreadstat para .SAV)
python3 python/01_agrega_pisa.py CAMINHO/CY08MSP_STU_QQQ.SAV

# Etapa 2: somente R base (>= 4.0), executado na raiz do repositório
Rscript R/00_executar_tudo.R
```

Microdados: OECD, *PISA 2022 Database*, questionário do estudante (`CY08MSP_STU_QQQ`), disponível em https://www.oecd.org/en/data/datasets/pisa-2022-database.html.

Semente 731; duas execuções na mesma plataforma produzem tabelas idênticas byte a byte.

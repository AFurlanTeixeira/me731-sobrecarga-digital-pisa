## Apêndice A — Reprodutibilidade

O processamento tem duas etapas.

```bash
# 1. Agregação dos microdados (Python 3 + pandas; pyarrow para .parquet ou pyreadstat para .SAV)
python3 python/01_agrega_pisa.py CAMINHO/CY08MSP_STU_QQQ.SAV
# 2. Análise (somente R base)
Rscript R/00_executar_tudo.R
```

A etapa 1 lê os 613.744 registros e grava `data/pisa2022_paises.csv` e `data/pisa2022_gap_intrapais.csv`, em cerca de 10 s. Esses dois arquivos acompanham o repositório, de modo que a etapa 2 roda sem os microdados. A etapa 2 confere os checksums MD5 das entradas e grava 29 tabelas em `results/tables/`, 10 figuras em `results/figures/` e o registro completo em `results/log_execucao.txt`, incluindo `sessionInfo()`. Com semente 731, duas execuções na mesma plataforma produzem tabelas idênticas byte a byte. O tempo de execução é de poucos segundos. A tabela `t04b` (medida KMO) continua sendo gerada, mas não é usada no relatório.

**Correspondência entre resultados e seções.**

| Arquivo | Conteúdo | Seção |
|---|---|---|
| t01 | Exclusões | 2.3 |
| t02, t03, f01 | Descritiva e correlações | 2.4 |
| t04a, t04c, t04d, f02 | Bartlett, Mardia e atípicos | 4 |
| t05, t07a, f03 | Autovalores e gráfico de cotovelo | 5.1 |
| t06, t07b, f04 | Cargas e bootstrap | 5.2 |
| t08, t09 | Escolha de G e estabilidade | 6.1 |
| t10, t11, f05–f07 | Composição e perfil dos grupos | 6.2 |
| t12, t12b, t13a–d, f08, f09 | Correlações, regressão multivariada e resíduos | 7.1 |
| t14a, t14b | MANOVA e MANCOVA | 7.2 |
| t15a–c, f10 | Meta-análise intrapaís | 8 |
| t16a–c | Sensibilidade | 7.1, 9.2 |

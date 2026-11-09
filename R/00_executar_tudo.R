# =============================================================================
# ME731 - Analise Multivariada - Projeto 2 (P2)
# Sobrecarga digital e desempenho: uma analise multivariada dos paises do PISA 2022
#
# Etapas: (1) dados e descritiva; (2) diagnosticos antes da ACP; (3) ACP com
# selecao do numero de componentes e bootstrap; (4) agrupamento dos paises;
# (5) relacao com o desempenho (regressao multivariada e MANCOVA);
# (6) contraste entre paises e dentro dos paises (meta-analise); (7) sensibilidade.
#
# Execucao (na raiz do repositorio):  Rscript R/00_executar_tudo.R
# Entrada: data/pisa2022_paises.csv e data/pisa2022_gap_intrapais.csv,
#          gerados por python/01_agrega_pisa.py a partir dos microdados da OCDE.
# Somente pacotes da distribuicao base do R.
# =============================================================================

if (!file.exists("R/00_executar_tudo.R")) stop("Execute a partir da raiz do repositorio.")
for (f in list.files("R/funcoes", pattern = "\\.R$", full.names = TRUE)) source(f, encoding = "UTF-8")
dir.create("results/tables", recursive = TRUE, showWarnings = FALSE)
dir.create("results/figures", recursive = TRUE, showWarnings = FALSE)
sink("results/log_execucao.txt", split = TRUE)
inicio <- Sys.time()
set.seed(731)
invisible(Sys.setlocale("LC_CTYPE", "C.UTF-8"))
options(width = 120)

# as etapas rodam em sequencia no mesmo ambiente (e na mesma sequencia de numeros
# aleatorios); cada uma usa os objetos criados pelas anteriores
etapas <- c("01_dados_descritiva.R", "02_diagnosticos.R", "03_acp.R", "04_agrupamento.R",
            "05_desempenho.R", "06_entre_dentro.R", "07_sensibilidade.R")
for (f in etapas) source(file.path("R", f), encoding = "UTF-8")

cat("\nTempo de execução:", round(as.numeric(difftime(Sys.time(), inicio, units = "secs")), 1), "s\n")
print(sessionInfo())
sink()

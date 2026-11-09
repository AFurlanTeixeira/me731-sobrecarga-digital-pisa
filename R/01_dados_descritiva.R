###############################################################################
# ME731 - Projeto 2 - Etapa 1: dados e descritiva
# Nao executar isoladamente: depende dos objetos das etapas anteriores.
# Execucao completa (na raiz do repositorio):  Rscript R/00_executar_tudo.R
###############################################################################

# -----------------------------------------------------------------------------
# 1. Dados
# -----------------------------------------------------------------------------
cat("Checksums MD5 dos arquivos de entrada:\n")
print(tools::md5sum(c("data/pisa2022_paises.csv", "data/pisa2022_gap_intrapais.csv")))

paises <- read.csv("data/pisa2022_paises.csv", stringsAsFactors = FALSE)
gaps   <- read.csv("data/pisa2022_gap_intrapais.csv", stringsAsFactors = FALSE)

X_VARS <- c("DIST_PROPRIA", "DIST_COLEGAS", "H_LAZER_ESCOLA", "H_LAZER_SEMANA",
            "H_LAZER_FDS", "NOTIF_ATIVAS", "SEMPRE_DISPONIVEL", "PRESSAO_ONLINE",
            "ANSIEDADE_SEM_DISP")
ROTULOS <- c(DIST_PROPRIA = "Distrai-se com o próprio dispositivo (%)",
             DIST_COLEGAS = "Distrai-se com dispositivos de colegas (%)",
             H_LAZER_ESCOLA = "Lazer digital na escola (h/dia)",
             H_LAZER_SEMANA = "Lazer digital em dia de aula (h/dia)",
             H_LAZER_FDS = "Lazer digital no fim de semana (h/dia)",
             NOTIF_ATIVAS = "Raramente desliga notificações na aula (%)",
             SEMPRE_DISPONIVEL = "Mantém o aparelho perto p/ responder (%)",
             PRESSAO_ONLINE = "Sente pressão para estar online na aula (%)",
             ANSIEDADE_SEM_DISP = "Fica ansioso sem o aparelho (%)")
CURTO <- c(DIST_PROPRIA = "Dist. própria", DIST_COLEGAS = "Dist. colegas",
           H_LAZER_ESCOLA = "Lazer escola", H_LAZER_SEMANA = "Lazer semana",
           H_LAZER_FDS = "Lazer fds", NOTIF_ATIVAS = "Notif. ativas",
           SEMPRE_DISPONIVEL = "Sempre disp.", PRESSAO_ONLINE = "Pressão online",
           ANSIEDADE_SEM_DISP = "Ansiedade s/ disp.")
Y_VARS <- c("MAT", "LEI", "CIE")

# amostra analitica: casos completos nas 9 variaveis de uso digital, ESCS e desempenho
completo <- complete.cases(paises[, c(X_VARS, "ESCS", Y_VARS)])
exclusoes <- data.frame(
  CNT = paises$CNT[!completo], PAIS = paises$PAIS[!completo],
  motivo = ifelse(is.na(paises$NOTIF_ATIVAS[!completo]),
                  "não aplicou os itens ST322/ST326", "ESCS ausente"))
grava(exclusoes, "t01_exclusoes")
d <- paises[completo, ]
rownames(d) <- d$CNT
n <- nrow(d); p <- length(X_VARS)
cat("\nAmostra analítica: n =", n, "países/economias (", sum(d$OCDE), "da OCDE ); p =", p, "\n")
stopifnot(n >= 30, p >= 4, n > p)

# 1.1 Descritiva
desc <- t(sapply(c(X_VARS, "ESCS", Y_VARS, "ANXMAT"), function(v) {
  x <- d[[v]]; c(n = sum(!is.na(x)), media = mean(x, na.rm = TRUE), dp = sd(x, na.rm = TRUE),
                 min = min(x, na.rm = TRUE), mediana = median(x, na.rm = TRUE),
                 max = max(x, na.rm = TRUE))
}))
grava(desc, "t02_descritiva")
cat("Brasil:\n"); print(round(unlist(d["BRA", c(X_VARS, "ESCS", Y_VARS)]), 2))

R_all <- cor(d[, c(X_VARS, "ESCS", Y_VARS)])
grava(round(R_all, 3), "t03_correlacoes")

abre_png("f01_correlacoes", 2200, 2000)
par(mar = c(9, 9, 2, 6))
vv <- c(X_VARS, "ESCS", Y_VARS); lab <- c(CURTO, ESCS = "ESCS", MAT = "Matemática",
                                          LEI = "Leitura", CIE = "Ciências")[vv]
pal <- colorRampPalette(c("#2166AC", "#F7F7F7", "#B2182B"))(41)
image(1:length(vv), 1:length(vv), R_all[, rev(seq_along(vv))], col = pal, zlim = c(-1, 1),
      axes = FALSE, xlab = "", ylab = "")
axis(1, 1:length(vv), lab, las = 2, cex.axis = 0.8)
axis(2, 1:length(vv), rev(lab), las = 1, cex.axis = 0.8)
for (i in seq_along(vv)) for (j in seq_along(vv))
  text(i, length(vv) - j + 1, sprintf("%.2f", R_all[i, j]), cex = 0.6)
abline(v = p + 0.5, h = length(vv) - p + 0.5, lwd = 2)
dev.off()

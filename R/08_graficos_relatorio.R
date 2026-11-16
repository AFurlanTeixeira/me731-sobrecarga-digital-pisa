###############################################################################
# ME731 - Projeto 2 - Etapa 8: graficos de sintese para o relatorio
# Nao executar isoladamente: depende dos objetos das etapas anteriores
# (d, X_VARS, CURTO, adj, G, cores, meta, entre).
# Execucao completa (na raiz do repositorio):  Rscript R/00_executar_tudo.R
###############################################################################

COR_NEUTRA <- "#9E9E9E"; COR_DESTAQUE <- "#B2182B"; COR_TEXTO <- "#333333"

# -----------------------------------------------------------------------------
# f11. Entre paises x dentro dos paises (falacia ecologica), escala 0% -> 100%
# -----------------------------------------------------------------------------
ed <- data.frame(
  comp = c("Raramente desliga\nnotificações", "Distrai-se com\no aparelho"),
  entre = entre[c("notificacoes", "distracao"), 1],
  ep_entre = entre[c("notificacoes", "distracao"), 2],
  dentro = meta[c("notificacoes", "distracao"), "efeito_aleatorio"],
  ep_dentro = meta[c("notificacoes", "distracao"), "ep_aleatorio"])
ed$razao <- ed$entre / ed$dentro
grava(ed[, -1], "t17_entre_dentro_grafico")

abre_png("f11_entre_vs_dentro", 2200, 1100)
par(mar = c(4.5, 10, 3.2, 1.5))
yy <- c(2, 1)
xl <- range(c(ed$entre - 1.96 * ed$ep_entre, 0))
plot(NA, xlim = c(xl[1], 20), ylim = c(0.5, 2.6), yaxt = "n", ylab = "", bty = "n",
     xlab = "Diferença em Matemática (pontos) entre 0% e 100% de alunos com o comportamento, dado o ESCS",
     main = "Comparar países infla o efeito em oito a nove vezes", cex.main = 1.05, font.main = 1)
abline(v = 0, lty = 2, col = COR_NEUTRA)
segments(ed$entre, yy, ed$dentro, yy, col = "#D9D9D9", lwd = 6)
segments(ed$entre - 1.96 * ed$ep_entre, yy, ed$entre + 1.96 * ed$ep_entre, yy, col = COR_NEUTRA, lwd = 2)
segments(ed$dentro - 1.96 * ed$ep_dentro, yy, ed$dentro + 1.96 * ed$ep_dentro, yy, col = COR_DESTAQUE, lwd = 2)
points(ed$entre, yy, pch = 19, cex = 1.8, col = COR_NEUTRA)
points(ed$dentro, yy, pch = 19, cex = 1.8, col = COR_DESTAQUE)
fmt <- function(x) gsub("-", "−", formatC(x, format = "f", digits = 1, decimal.mark = ","))
text(ed$entre, yy + 0.22, fmt(ed$entre), col = COR_TEXTO, cex = 0.85)
text(ed$dentro, yy + 0.22, fmt(ed$dentro), col = COR_DESTAQUE, cex = 0.85)
text(mean(c(ed$entre[1], ed$dentro[1])), yy - 0.22,
     paste0(formatC(ed$razao, format = "f", digits = 1, decimal.mark = ","), " vezes"),
     col = COR_TEXTO, cex = 0.8, font = 3)
axis(2, yy, ed$comp, las = 1, tick = FALSE, cex.axis = 0.9)
legend("bottomleft", c("Entre países (regressão das médias nacionais)",
                       "Dentro dos países (meta-análise intrapaís)"),
       pch = 19, col = c(COR_NEUTRA, COR_DESTAQUE), bty = "n", cex = 0.8)
dev.off()

# -----------------------------------------------------------------------------
# f12. Medias ajustadas de Matematica por grupo (ESCS = media da amostra)
# -----------------------------------------------------------------------------
NOME_GRUPO <- c("G1 Baixa distração, alta pressão", "G2 Uso moderado, baixa pressão",
                "G3 Alta distração em aula", "G4 Alto volume de lazer",
                "G5 Pressão e ansiedade")
grupo_bra <- grupo[rownames(d) == "BRA"]
o <- order(adj[, "MAT"])
abre_png("f12_medias_ajustadas", 2200, 1100)
par(mar = c(4.5, 15, 3.2, 2))
cols <- ifelse(seq_len(G)[o] == grupo_bra, COR_DESTAQUE, COR_NEUTRA)
bp <- barplot(adj[o, "MAT"], horiz = TRUE, names.arg = NOME_GRUPO[o], las = 1, col = cols,
              border = NA, xlim = c(0, 560), cex.names = 0.85,
              xlab = "Média ajustada de Matemática (ESCS no valor médio da amostra)",
              main = "Mesmo com ESCS igual, os perfis diferem em até 99 pontos",
              cex.main = 1.05, font.main = 1)
abline(v = mean(d$MAT), lty = 2, col = COR_TEXTO)
text(mean(d$MAT), max(bp) + 0.75, paste0("média dos 74 países: ",
     formatC(mean(d$MAT), format = "f", digits = 0)), pos = 2, cex = 0.75, col = COR_TEXTO, xpd = TRUE)
text(adj[o, "MAT"], bp, formatC(adj[o, "MAT"], format = "f", digits = 0), pos = 4,
     cex = 0.85, col = COR_TEXTO, xpd = TRUE)
dev.off()

# -----------------------------------------------------------------------------
# f13. Posicao do Brasil na amplitude de cada indicador (minimo, media, maximo)
# -----------------------------------------------------------------------------
v_pct <- c("DIST_PROPRIA", "DIST_COLEGAS", "NOTIF_ATIVAS", "SEMPRE_DISPONIVEL",
           "PRESSAO_ONLINE", "ANSIEDADE_SEM_DISP")
v_h <- c("H_LAZER_ESCOLA", "H_LAZER_SEMANA", "H_LAZER_FDS")
painel <- function(vars, xlab) {
  k <- length(vars); yy <- rev(seq_len(k))
  mn <- sapply(vars, function(v) min(d[[v]])); mx <- sapply(vars, function(v) max(d[[v]]))
  me <- sapply(vars, function(v) mean(d[[v]])); br <- unlist(d["BRA", vars])
  cmn <- sapply(vars, function(v) d$CNT[which.min(d[[v]])])
  cmx <- sapply(vars, function(v) d$CNT[which.max(d[[v]])])
  rg <- range(c(mn, mx)); pad <- diff(rg) * 0.12
  plot(NA, xlim = c(rg[1] - pad, rg[2] + pad), ylim = c(0.5, k + 0.5), yaxt = "n",
       ylab = "", xlab = xlab, bty = "n")
  segments(mn, yy, mx, yy, col = "#D9D9D9", lwd = 5)
  points(mn, yy, pch = 19, col = COR_NEUTRA); points(mx, yy, pch = 19, col = COR_NEUTRA)
  points(me, yy, pch = 124, cex = 1.6, col = COR_TEXTO)
  points(br, yy, pch = 19, cex = 1.7, col = COR_DESTAQUE)
  text(mn, yy, cmn, pos = 2, cex = 0.65, col = COR_TEXTO, xpd = TRUE)
  text(mx, yy, cmx, pos = 4, cex = 0.65, col = COR_TEXTO, xpd = TRUE)
  axis(2, yy, CURTO[vars], las = 1, tick = FALSE, cex.axis = 0.85)
}
abre_png("f13_brasil_indicadores", 2200, 1500)
layout(matrix(1:2, ncol = 1), heights = c(6, 3.6))
par(mar = c(4.2, 9, 4.6, 2))
painel(v_pct, "% de estudantes")
title("O Brasil está entre os países de maior distração em aula", cex.main = 1.05, font.main = 1,
      line = 2.6)
legend("top", c("Brasil", "média dos 74 países", "mínimo e máximo"),
       pch = c(19, 124, 19), col = c(COR_DESTAQUE, COR_TEXTO, COR_NEUTRA), bty = "n",
       cex = 0.75, horiz = TRUE, inset = c(0, -0.12), xpd = TRUE)
par(mar = c(4.2, 9, 1, 2))
painel(v_h, "horas por dia de lazer digital")
dev.off()

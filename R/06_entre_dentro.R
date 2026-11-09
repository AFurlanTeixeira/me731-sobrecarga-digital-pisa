###############################################################################
# ME731 - Projeto 2 - Etapa 6: entre paises x dentro dos paises (meta-analise)
# Nao executar isoladamente: depende dos objetos das etapas anteriores.
# Execucao completa (na raiz do repositorio):  Rscript R/00_executar_tudo.R
###############################################################################

# -----------------------------------------------------------------------------
# 6. Entre paises x dentro dos paises
# -----------------------------------------------------------------------------
gg <- merge(d[, c("CNT", "PAIS", "grupo", "ESCS", "MAT", "DIST_PROPRIA", "NOTIF_ATIVAS")],
            gaps, by = "CNT")
meta <- rbind(distracao = meta_dl(gg$GAP_DIST, gg$EP_GAP_DIST),
              notificacoes = meta_dl(gg$GAP_NOTIF, gg$EP_GAP_NOTIF),
              lazer_mais_4h = meta_dl(gg$GAP_LAZER4H, gg$EP_GAP_LAZER4H))
grava(meta, "t15a_meta_intrapais")

# inclinacao entre paises na mesma escala (de 0% a 100% de alunos), dado o ESCS
entre <- rbind(
  distracao = summary(lm(MAT ~ I(DIST_PROPRIA / 100) + ESCS, d))$coefficients[2, 1:2],
  notificacoes = summary(lm(MAT ~ I(NOTIF_ATIVAS / 100) + ESCS, d))$coefficients[2, 1:2])
grava(cbind(entre_paises = entre[, 1], ep_entre = entre[, 2],
            dentro_paises = meta[1:2, "efeito_aleatorio"], ep_dentro = meta[1:2, "ep_aleatorio"]),
      "t15b_entre_vs_dentro")
# heterogeneidade do efeito intrapais segundo o grupo de paises
grava(t(sapply(1:G, function(g) c(grupo = g,
     meta_dl(gg$GAP_NOTIF[gg$grupo == g], gg$EP_GAP_NOTIF[gg$grupo == g])[c("k", "efeito_aleatorio", "ep_aleatorio")]))),
     "t15c_gap_notif_por_grupo")

abre_png("f10_gap_intrapais", 2000, 2400)
par(mfrow = c(1, 2), mar = c(4.5, 3.6, 2, 0.5))
for (v in c("NOTIF", "DIST")) {
  y <- gg[[paste0("GAP_", v)]]; s <- gg[[paste0("EP_GAP_", v)]]
  o <- order(y); yy <- seq_along(o)
  plot(y[o], yy, pch = 19, cex = 0.6, col = cores[gg$grupo[o]], yaxt = "n", ylab = "",
       xlim = range(c(y - 2 * s, y + 2 * s), na.rm = TRUE),
       xlab = "Diferença em Matemática (pontos), dado o ESCS",
       main = if (v == "NOTIF") "Raramente desliga notificações" else "Distrai-se com o dispositivo")
  segments(y[o] - 1.96 * s[o], yy, y[o] + 1.96 * s[o], yy, col = cores[gg$grupo[o]])
  axis(2, yy, gg$CNT[o], las = 1, cex.axis = 0.45, tick = FALSE)
  abline(v = 0, lty = 2)
  abline(v = meta[if (v == "NOTIF") "notificacoes" else "distracao", "efeito_aleatorio"], col = "red")
}
dev.off()

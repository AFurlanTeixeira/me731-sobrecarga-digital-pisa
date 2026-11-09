###############################################################################
# ME731 - Projeto 2 - Etapa 4: agrupamento dos paises
# Nao executar isoladamente: depende dos objetos das etapas anteriores.
# Execucao completa (na raiz do repositorio):  Rscript R/00_executar_tudo.R
###############################################################################

# -----------------------------------------------------------------------------
# 4. Agrupamento dos paises nos escores das K componentes retidas
# -----------------------------------------------------------------------------
E <- S_cp[, 1:K]
D <- dist(E)
sil_k <- sapply(2:6, function(k) {
  a <- agrupa(E, k); c(k = k, silhueta_ward = mean(silhueta(D, a$ward)),
                       silhueta_kmedias = mean(silhueta(D, a$kmedias)),
                       rand_aj_ward_km = rand_ajustado(a$ward, a$kmedias))
})
grava(t(sil_k), "t08_escolha_k")
G <- sil_k["k", which.max(sil_k["silhueta_kmedias", ])]
cat("Número de grupos escolhido (maior silhueta média, k-médias):", G, "\n")
ag <- agrupa(E, G)
grupo <- ag$kmedias
# rotula os grupos em ordem crescente do escore medio na CP2
ordem <- order(tapply(E[, 2], grupo, mean)); grupo <- match(grupo, ordem)
names(grupo) <- rownames(d)
d$grupo <- grupo

# estabilidade bootstrap: re-agrupa a amostra reamostrada e classifica todos os
# paises pelo centroide mais proximo; compara com a particao original (Rand ajustado)
estab <- replicate(500, {
  idx <- sample(n, replace = TRUE); Eb <- E[idx, ]
  if (nrow(unique(Eb)) <= G) return(NA)
  ab <- agrupa(Eb, G)
  cl <- apply(E, 1, function(z) which.min(colSums((t(ab$centros) - z)^2)))
  rand_ajustado(grupo, cl)
})
grava(c(rand_aj_medio = mean(estab, na.rm = TRUE),
        rand_aj_q05 = unname(quantile(estab, 0.05, na.rm = TRUE)),
        rand_aj_q50 = unname(quantile(estab, 0.5, na.rm = TRUE))), "t09_estabilidade")

sil_g <- silhueta(D, grupo)
comp <- data.frame(CNT = rownames(d), PAIS = d$PAIS, OCDE = d$OCDE, grupo = grupo,
                   silhueta = round(sil_g, 3), round(E, 3))
comp <- comp[order(comp$grupo, -comp$CP2), ]
grava(comp, "t10_composicao_grupos")

perfil <- t(sapply(sort(unique(grupo)), function(g)
  c(n = sum(grupo == g), colMeans(d[grupo == g, c(X_VARS, "ESCS", Y_VARS)]),
    ANXMAT = mean(d$ANXMAT[grupo == g], na.rm = TRUE), colMeans(E[grupo == g, , drop = FALSE]))))
rownames(perfil) <- paste0("G", sort(unique(grupo)))
grava(perfil, "t11_perfil_grupos")

cores <- c("#1B9E77", "#D95F02", "#7570B3", "#E7298A", "#66A61E", "#E6AB02")[1:G]
abre_png("f05_dendrograma", 2600, 1400)
par(mar = c(1, 4.5, 2, 1))
plot(ag$hc, labels = rownames(d), cex = 0.55, main = "", xlab = "", sub = "",
     ylab = "Altura (Ward)")
rect.hclust(ag$hc, k = G, border = "grey40")
dev.off()

abre_png("f06_mapa_cp1_cp2", 2200, 1800)
par(mar = c(4.5, 4.5, 1, 1))
plot(E[, 1], E[, 2], pch = ifelse(d$OCDE == 1, 19, 17), col = cores[grupo],
     xlab = sprintf("CP1 (%.0f%%)", 100 * lam[1] / p), ylab = sprintf("CP2 (%.0f%%)", 100 * lam[2] / p),
     xlim = range(E[, 1]) * 1.15, ylim = range(E[, 2]) * 1.15)
abline(h = 0, v = 0, col = "grey80")
text(E[, 1], E[, 2], rownames(d), pos = 3, cex = 0.55, col = cores[grupo])
esc <- 2.6
arrows(0, 0, esc * V[, 1] * sqrt(lam[1]), esc * V[, 2] * sqrt(lam[2]), length = 0.06, col = "grey35")
text(esc * 1.12 * V[, 1] * sqrt(lam[1]), esc * 1.12 * V[, 2] * sqrt(lam[2]), CURTO[X_VARS],
     cex = 0.7, col = "grey20")
legend("bottomleft", c(paste0("Grupo ", 1:G), "OCDE", "não OCDE"),
       col = c(cores, "black", "black"), pch = c(rep(15, G), 19, 17), bty = "n", cex = 0.8)
dev.off()

abre_png("f07_perfis_grupos", 2200, 1300)
par(mar = c(8, 4.5, 1, 1))
zg <- t(sapply(1:G, function(g) colMeans(Z[grupo == g, , drop = FALSE])))
matplot(t(zg), type = "b", pch = 19, lty = 1, col = cores, xaxt = "n",
        ylab = "Média padronizada (z)", xlab = "")
axis(1, 1:p, CURTO[X_VARS], las = 2, cex.axis = 0.85); abline(h = 0, lty = 2)
legend("topleft", paste0("G", 1:G, " (n = ", table(grupo), ")"), col = cores,
       lty = 1, pch = 19, bty = "n", cex = 0.85)
dev.off()

###############################################################################
# ME731 - Projeto 2 - Etapa 2: diagnosticos antes da ACP
# Nao executar isoladamente: depende dos objetos das etapas anteriores.
# Execucao completa (na raiz do repositorio):  Rscript R/00_executar_tudo.R
###############################################################################

# -----------------------------------------------------------------------------
# 2. Diagnosticos antes da ACP
# -----------------------------------------------------------------------------
X <- as.matrix(d[, X_VARS])
be <- bartlett_esfericidade(X); grava(be, "t04a_bartlett_esfericidade")
k_ <- kmo(X)
grava(c(KMO_global = k_$global, k_$individual), "t04b_kmo")
mard <- mardia(X); grava(mard, "t04c_mardia")
d2 <- mahal(X)
lim <- qchisq(0.999, p)
atip <- data.frame(CNT = names(d2), d2 = d2)[d2 > lim, ]
grava(atip, "t04d_atipicos")

abre_png("f02_quiquadrado")
par(mar = c(4.5, 4.5, 2, 1))
o <- order(d2); qq <- qchisq((seq_len(n) - 0.5) / n, p)
plot(qq, d2[o], pch = 19, col = "grey30", xlab = expression(paste("Quantis ", chi[9]^2)),
     ylab = "Distância de Mahalanobis ao quadrado")
abline(0, 1, lty = 2); abline(h = lim, col = "red", lty = 3)
gr <- d2[o] > qchisq(0.99, p); text(qq[gr], d2[o][gr], names(d2)[o][gr], pos = 2, cex = 0.8)
dev.off()
cat("Correlação no gráfico qui-quadrado:", round(cor(qq, d2[o]), 3), "\n")

###############################################################################
# ME731 - Projeto 2 - Etapa 3: componentes principais e bootstrap
# Nao executar isoladamente: depende dos objetos das etapas anteriores.
# Execucao completa (na raiz do repositorio):  Rscript R/00_executar_tudo.R
###############################################################################

# -----------------------------------------------------------------------------
# 3. Analise de Componentes Principais (matriz de correlacoes)
# -----------------------------------------------------------------------------
Z <- scale(X)
e <- eigen(cor(X), symmetric = TRUE)
lam <- e$values; V <- e$vectors
dimnames(V) <- list(X_VARS, paste0("CP", 1:p))
pa <- analise_paralela(X, B = 2000)
tab_aut <- data.frame(pa, prop = lam / p, acumulada = cumsum(lam) / p,
                      vara_quebrada = vara_quebrada(p))
grava(tab_aut, "t05_autovalores")
k_kaiser <- sum(lam > 1)
k_paralela <- sum(cumprod(lam > pa$q95_aleatoria))
k_vq <- sum(cumprod(lam > tab_aut$vara_quebrada))
cat("\nComponentes retidas: Kaiser =", k_kaiser, "| análise paralela =", k_paralela,
    "| vara quebrada =", k_vq, "\n")
# K pela regra de Kaiser, conferida no grafico de cotovelo (JW, Secao 8.3);
# analise paralela e vara quebrada ficam apenas registradas em t05
K <- k_kaiser

# orientacao dos sinais: CP com soma de cargas positiva (convencao)
for (j in 1:p) if (sum(V[, j]) < 0) V[, j] <- -V[, j]
pr <- prcomp(X, scale. = TRUE)
stopifnot(isTRUE(all.equal(abs(unname(pr$rotation)), abs(unname(V)), tolerance = 1e-8)))
S_cp <- Z %*% V                                         # escores
colnames(S_cp) <- paste0("CP", 1:p)
stopifnot(isTRUE(all.equal(unname(apply(S_cp, 2, var)), lam, tolerance = 1e-8)))

# correlacoes variavel-componente (r = v_ij sqrt(lambda_j)) e comunalidades
corr_vc <- V[, 1:K] %*% diag(sqrt(lam[1:K]))
colnames(corr_vc) <- paste0("CP", 1:K)
cargas <- data.frame(variavel = ROTULOS[X_VARS], round(V[, 1:K], 3),
                     round(corr_vc, 3), comunalidade = round(rowSums(corr_vc^2), 3))
names(cargas)[2:(1 + 2 * K)] <- c(paste0("coef_CP", 1:K), paste0("cor_CP", 1:K))
grava(cargas, "t06_cargas")

# bootstrap (paises reamostrados)
bt <- bootstrap_acp(X, V[, 1:K, drop = FALSE], B = 2000)
ic_aut <- t(apply(bt$autovalores[, 1:(K + 1)], 2, quantile, c(0.025, 0.975)))
grava(data.frame(componente = 1:(K + 1), autovalor = lam[1:(K + 1)], ic_aut), "t07a_bootstrap_autovalores")
ic_carg <- do.call(rbind, lapply(1:K, function(j)
  data.frame(componente = paste0("CP", j), variavel = X_VARS, coef = V[, j],
             ic_inf = apply(bt$cargas[, , j], 2, quantile, 0.025),
             ic_sup = apply(bt$cargas[, , j], 2, quantile, 0.975))))
ic_carg$sinal_estavel <- with(ic_carg, ic_inf > 0 | ic_sup < 0)
grava(ic_carg, "t07b_bootstrap_cargas")

abre_png("f03_scree")
par(mar = c(4.5, 4.5, 2, 1))
plot(1:p, lam, type = "b", pch = 19, ylim = c(0, max(lam, ic_aut) * 1.05),
     xlab = "Componente", ylab = "Autovalor")
arrows(1:(K + 1), ic_aut[, 1], 1:(K + 1), ic_aut[, 2], angle = 90, code = 3, length = 0.04)
abline(h = 1, col = "grey60", lty = 2)
legend("topright", c("Autovalor (IC 95% bootstrap)", "Kaiser (λ = 1)"),
       col = c("black", "grey60"), lty = c(1, 2), pch = c(19, NA), bty = "n", cex = 0.85)
dev.off()

abre_png("f04_cargas", 2400, 1300)
par(mfrow = c(1, K), mar = c(4.5, 10.5, 2.5, 1))
for (j in 1:K) {
  sub <- ic_carg[ic_carg$componente == paste0("CP", j), ]
  y <- p:1
  plot(sub$coef, y, xlim = c(-0.8, 0.8), pch = 19, yaxt = "n", ylab = "",
       xlab = "Coeficiente (IC 95% bootstrap)",
       main = sprintf("CP%d (%.0f%%)", j, 100 * lam[j] / p),
       col = ifelse(sub$sinal_estavel, "black", "grey60"))
  segments(sub$ic_inf, y, sub$ic_sup, y, col = ifelse(sub$sinal_estavel, "black", "grey60"))
  abline(v = 0, lty = 2)
  if (j == 1) axis(2, y, CURTO[sub$variavel], las = 1, cex.axis = 0.9) else
    axis(2, y, labels = FALSE)
}
dev.off()

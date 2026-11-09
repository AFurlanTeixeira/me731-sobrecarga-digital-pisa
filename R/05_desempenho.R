###############################################################################
# ME731 - Projeto 2 - Etapa 5: relacao com o desempenho (regressao multivariada, MANOVA/MANCOVA)
# Nao executar isoladamente: depende dos objetos das etapas anteriores.
# Execucao completa (na raiz do repositorio):  Rscript R/00_executar_tudo.R
###############################################################################

# -----------------------------------------------------------------------------
# 5. Relacao com o desempenho
# -----------------------------------------------------------------------------
# 5.1 correlacoes simples e parciais (dado ESCS) dos escores com o desempenho
cp_desemp <- do.call(rbind, lapply(1:K, function(j) do.call(rbind, lapply(Y_VARS, function(y)
  data.frame(componente = paste0("CP", j), resposta = y,
             r = cor(E[, j], d[[y]]), r_parcial_ESCS = cor_parcial(E[, j], d[[y]], d$ESCS))))))
grava(cp_desemp, "t12_correlacoes_desempenho")
grava(round(cor(E, d$ESCS), 4), "t12b_correlacao_cp_escs")

# 5.2 regressao linear multivariada: (MAT, LEI, CIE) ~ CP1 + ... + CPK + ESCS
dm <- data.frame(E, ESCS = d$ESCS, d[, Y_VARS], grupo = factor(d$grupo))
f_cp <- as.formula(paste("cbind(MAT, LEI, CIE) ~", paste(colnames(E), collapse = " + "), "+ ESCS"))
mfull <- lm(f_cp, data = dm)
termos <- c(colnames(E), "ESCS")
tw <- t(sapply(termos, function(tt) {
  red <- update(mfull, as.formula(paste(". ~ . -", tt)))
  w <- wilks_modelos(mfull, red)
  a <- anova(mfull, red, test = "Wilks")
  stopifnot(abs(a$Wilks[2] - w["Lambda"]) < 1e-10)
  w
}))
grava(tw, "t13a_regressao_multivariada_wilks")
coefs <- do.call(rbind, lapply(Y_VARS, function(y) {
  s <- summary(lm(as.formula(paste(y, "~", paste(termos, collapse = " + "))), data = dm))
  data.frame(resposta = y, termo = rownames(s$coefficients), s$coefficients[, 1:2],
             p_valor = s$coefficients[, 4], R2 = s$r.squared, check.names = FALSE)
}))
grava(coefs, "t13b_regressao_coeficientes")
# R2 adicional das componentes alem do ESCS
r2_escs <- sapply(Y_VARS, function(y) summary(lm(dm[[y]] ~ dm$ESCS))$r.squared)
r2_full <- sapply(Y_VARS, function(y) summary(lm(as.formula(paste(y, "~", paste(termos, collapse = "+"))), dm))$r.squared)
grava(rbind(R2_so_ESCS = r2_escs, R2_completo = r2_full, ganho = r2_full - r2_escs), "t13c_ganho_R2")

# diagnostico dos residuos do modelo multivariado
res <- residuals(mfull)
grava(mardia(res), "t13d_mardia_residuos")
d2r <- mahalanobis(res, colMeans(res), cov(res))
cat("Maiores distâncias dos resíduos:\n"); print(round(sort(d2r, decreasing = TRUE)[1:5], 2))
abre_png("f08_residuos", 2200, 1100)
par(mfrow = c(1, 2), mar = c(4.5, 4.5, 2, 1))
o <- order(d2r); qq3 <- qchisq((seq_len(n) - 0.5) / n, 3)
plot(qq3, d2r[o], pch = 19, col = "grey30", xlab = expression(paste("Quantis ", chi[3]^2)),
     ylab = "d² dos resíduos", main = "Gráfico qui-quadrado")
abline(0, 1, lty = 2)
gr <- d2r[o] > qchisq(0.99, 3); text(qq3[gr], d2r[o][gr], names(d2r)[o][gr], pos = 2, cex = 0.75)
plot(fitted(mfull)[, "MAT"], res[, "MAT"], pch = 19, col = cores[grupo],
     xlab = "Matemática ajustada", ylab = "Resíduo (Matemática)", main = "Resíduos vs ajustados")
abline(h = 0, lty = 2)
dev.off()

# 5.3 grupos: MANOVA e MANCOVA (ESCS como covariavel)
m_g <- lm(cbind(MAT, LEI, CIE) ~ grupo, data = dm); m_0 <- lm(cbind(MAT, LEI, CIE) ~ 1, data = dm)
m_ge <- lm(cbind(MAT, LEI, CIE) ~ ESCS + grupo, data = dm); m_e <- lm(cbind(MAT, LEI, CIE) ~ ESCS, data = dm)
mg <- rbind(MANOVA_grupo = wilks_modelos(m_g, m_0),
            MANCOVA_grupo_dado_ESCS = wilks_modelos(m_ge, m_e))
grava(mg, "t14a_manova_grupos")
# medias ajustadas para ESCS = media geral
adj <- t(sapply(1:G, function(g) predict(m_ge, newdata = data.frame(ESCS = mean(dm$ESCS),
                                                                     grupo = factor(g, levels = 1:G)))))
dimnames(adj) <- list(paste0("G", 1:G), Y_VARS)
grava(adj, "t14b_medias_ajustadas")

abre_png("f09_desempenho_cp2", 2200, 1100)
par(mfrow = c(1, 2), mar = c(4.5, 4.5, 2, 1))
plot(E[, 2], d$MAT, pch = 19, col = cores[grupo], xlab = "Escore na CP2",
     ylab = "Matemática (média do país)", main = "Sem ajuste")
abline(lm(d$MAT ~ E[, 2]), lty = 2)
text(E[, 2], d$MAT, rownames(d), pos = 3, cex = 0.5, col = cores[grupo])
rx <- resid(lm(E[, 2] ~ d$ESCS)); ry <- resid(lm(d$MAT ~ d$ESCS))
plot(rx, ry, pch = 19, col = cores[grupo], xlab = "CP2 | ESCS (resíduo)",
     ylab = "Matemática | ESCS (resíduo)", main = "Ajustado pelo ESCS")
abline(lm(ry ~ rx), lty = 2)
text(rx, ry, rownames(d), pos = 3, cex = 0.5, col = cores[grupo])
dev.off()

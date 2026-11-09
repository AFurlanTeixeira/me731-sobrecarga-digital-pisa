###############################################################################
# ME731 - Projeto 2 - Etapa 7: analises de sensibilidade
# Nao executar isoladamente: depende dos objetos das etapas anteriores.
# Execucao completa (na raiz do repositorio):  Rscript R/00_executar_tudo.R
###############################################################################

# -----------------------------------------------------------------------------
# 7. Sensibilidade
# -----------------------------------------------------------------------------
sens <- list()
# (a) somente paises da OCDE
Xo <- X[d$OCDE == 1, ]; Vo <- eigen(cor(Xo), symmetric = TRUE)$vectors
# (b) sem os atipicos multivariados
Xs <- X[d2 <= qchisq(0.99, p), ]; Vs <- eigen(cor(Xs), symmetric = TRUE)$vectors
# (c) correlacoes de Spearman (postos)
Vr <- eigen(cor(X, method = "spearman"), symmetric = TRUE)$vectors
for (nm in c("OCDE", "sem_atipicos", "spearman")) {
  W_ <- switch(nm, OCDE = Vo, sem_atipicos = Vs, spearman = Vr)
  sens[[nm]] <- sapply(1:K, function(j) max(abs(apply(W_[, 1:(K + 1)], 2, congruencia, b = V[, j]))))
}
tab_sens <- do.call(rbind, sens); colnames(tab_sens) <- paste0("congruencia_CP", 1:K)
tab_sens <- cbind(n = c(nrow(Xo), nrow(Xs), n), tab_sens)
# (d) particao com as 9 variaveis padronizadas, em vez dos K escores
ag9 <- agrupa(Z, G)
grava(tab_sens, "t16a_sensibilidade_acp")
grava(c(rand_aj_9variaveis = rand_ajustado(grupo, ag9$kmedias),
        rand_aj_ward_vs_kmedias = rand_ajustado(ag$ward, ag$kmedias)), "t16b_sensibilidade_grupos")
# (e) regressao com indicadora de pais da OCDE e sem atipicos dos residuos
ok <- d2r <= qchisq(0.99, 3)
m_sa <- lm(f_cp, data = dm[ok, ])
grava(rbind(completo = coef(mfull)["CP2", ], sem_atipicos_residuos = coef(m_sa)["CP2", ],
            com_OCDE = coef(lm(update(f_cp, . ~ . + OCDE), data = cbind(dm, OCDE = d$OCDE)))["CP2", ]),
      "t16c_sensibilidade_coef_CP2")

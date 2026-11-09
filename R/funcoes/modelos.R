###############################################################################
# ME731 - Projeto 2 - Funcoes auxiliares: modelos (Wilks, meta-analise, correlacao parcial)
# (somente R base: stats, graphics, utils)
###############################################################################

# ---- Teste de Wilks para comparacao de modelos lineares multivariados ---------
# Lambda = |E_completo| / |E_reduzido|; aproximacao F de Rao (exata se q = 1 ou p <= 2)
# e estatistica qui-quadrado com a correcao de Bartlett (Johnson e Wichern, Result 7.11):
#   -[n - r - 1 - (m - r + q0 + 1)/2] ln Lambda = -(ve - (p - q + 1)/2) ln Lambda,
#   com ve = n - r - 1, p = no. de respostas e q = r - q0 = g.l. da hipotese; g.l. = p q
wilks_modelos <- function(completo, reduzido) {
  E1 <- crossprod(residuals(completo)); E0 <- crossprod(residuals(reduzido))
  L <- det(E1) / det(E0)
  p <- ncol(E1); q <- reduzido$df.residual - completo$df.residual
  ve <- completo$df.residual
  t <- if (p^2 + q^2 - 5 > 0) sqrt((p^2 * q^2 - 4) / (p^2 + q^2 - 5)) else 1
  gl1 <- p * q; gl2 <- (ve - (p - q + 1) / 2) * t - (p * q - 2) / 2
  F <- (1 - L^(1 / t)) / L^(1 / t) * gl2 / gl1
  qui2 <- -(ve - (p - q + 1) / 2) * log(L)
  c(Lambda = L, F = F, gl1 = gl1, gl2 = gl2,
    p_valor = pf(F, gl1, gl2, lower.tail = FALSE), eta2 = 1 - L^(1 / min(p, q)),
    qui2_bartlett = qui2, gl_qui2 = p * q,
    p_qui2 = pchisq(qui2, p * q, lower.tail = FALSE))
}

# ---- Meta-analise de efeitos aleatorios (DerSimonian e Laird, 1986) ----------
meta_dl <- function(y, ep) {
  ok <- is.finite(y) & is.finite(ep); y <- y[ok]; v <- ep[ok]^2; k <- length(y)
  w <- 1 / v; fe <- sum(w * y) / sum(w)
  Q <- sum(w * (y - fe)^2)
  tau2 <- max(0, (Q - (k - 1)) / (sum(w) - sum(w^2) / sum(w)))
  wr <- 1 / (v + tau2); re <- sum(wr * y) / sum(wr); ep_re <- sqrt(1 / sum(wr))
  c(k = k, efeito_fixo = fe, ep_fixo = sqrt(1 / sum(w)),
    efeito_aleatorio = re, ep_aleatorio = ep_re,
    ic_inf = re - 1.96 * ep_re, ic_sup = re + 1.96 * ep_re,
    Q = Q, p_Q = pchisq(Q, k - 1, lower.tail = FALSE), tau = sqrt(tau2),
    I2 = max(0, (Q - (k - 1)) / Q),
    n_neg_signif = sum(y / sqrt(v) < -1.96), n_pos_signif = sum(y / sqrt(v) > 1.96))
}

# ---- Correlacao parcial de x e y dado z --------------------------------------
cor_parcial <- function(x, y, z) cor(resid(lm(x ~ z)), resid(lm(y ~ z)))

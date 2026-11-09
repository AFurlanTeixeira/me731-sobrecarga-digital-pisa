###############################################################################
# ME731 - Projeto 2 - Funcoes auxiliares: diagnosticos (esfericidade, KMO, Mardia, Mahalanobis)
# (somente R base: stats, graphics, utils)
###############################################################################

# ---- Teste de esfericidade de Bartlett: H0: R = I ---------------------------
# estatistica: -(n - 1 - (2p + 5)/6) ln|R|  ~  qui-quadrado com p(p-1)/2 g.l.
bartlett_esfericidade <- function(X) {
  n <- nrow(X); p <- ncol(X); R <- cor(X)
  est <- -(n - 1 - (2 * p + 5) / 6) * log(det(R))
  gl <- p * (p - 1) / 2
  c(estatistica = est, gl = gl, p_valor = pchisq(est, gl, lower.tail = FALSE))
}

# ---- Medida de adequacao amostral de Kaiser-Meyer-Olkin ----------------------
# KMO = soma r_ij^2 / (soma r_ij^2 + soma a_ij^2), a_ij = correlacoes parciais
kmo <- function(X) {
  R <- cor(X); Ri <- solve(R)
  A <- -Ri / sqrt(outer(diag(Ri), diag(Ri)))           # correlacoes parciais
  diag(R) <- 0; diag(A) <- 0
  global <- sum(R^2) / (sum(R^2) + sum(A^2))
  individual <- colSums(R^2) / (colSums(R^2) + colSums(A^2))
  list(global = global, individual = individual)
}

# ---- Assimetria e curtose multivariadas de Mardia (1970) ---------------------
mardia <- function(X) {
  X <- as.matrix(X); n <- nrow(X); p <- ncol(X)
  Xc <- scale(X, scale = FALSE)
  S <- crossprod(Xc) / n                                   # estimador de MV
  G <- Xc %*% solve(S) %*% t(Xc)
  b1 <- sum(G^3) / n^2; b2 <- sum(diag(G)^2) / n
  gl <- p * (p + 1) * (p + 2) / 6
  e_b2 <- p * (p + 2) * (n - 1) / (n + 1)
  z <- (b2 - e_b2) / sqrt(8 * p * (p + 2) / n)
  c(b1p = b1, p_assim = pchisq(n * b1 / 6, gl, lower.tail = FALSE),
    b2p = b2, E_b2p = e_b2, z_curt = z, p_curt = 2 * pnorm(-abs(z)))
}

# ---- Distancias de Mahalanobis -----------------------------------------------
mahal <- function(X) {
  X <- as.matrix(X); mahalanobis(X, colMeans(X), cov(X))
}

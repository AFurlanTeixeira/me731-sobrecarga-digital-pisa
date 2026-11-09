###############################################################################
# ME731 - Projeto 2 - Funcoes auxiliares: componentes principais (analise paralela, vara quebrada, congruencia, bootstrap)
# (somente R base: stats, graphics, utils)
###############################################################################

# ---- Analise paralela de Horn (1965) -----------------------------------------
# compara os autovalores observados de R com o quantil 95% dos autovalores de
# matrizes de correlacao de dados normais independentes com mesmos n e p
analise_paralela <- function(X, B = 2000, q = 0.95) {
  n <- nrow(X); p <- ncol(X)
  sim <- replicate(B, eigen(cor(matrix(rnorm(n * p), n, p)),
                            symmetric = TRUE, only.values = TRUE)$values)
  data.frame(componente = 1:p,
             autovalor = eigen(cor(X), symmetric = TRUE)$values,
             media_aleatoria = rowMeans(sim),
             q95_aleatoria = apply(sim, 1, quantile, probs = q))
}

# ---- Modelo de vara quebrada (broken stick) ----------------------------------
vara_quebrada <- function(p) sapply(1:p, function(k) sum(1 / (k:p)))

# ---- Coeficiente de congruencia de Tucker ------------------------------------
congruencia <- function(a, b) sum(a * b) / sqrt(sum(a^2) * sum(b^2))

# ---- Bootstrap da ACP (autovalores e cargas) ---------------------------------
# cada componente bootstrap e pareado ao original de maior |congruencia|
# (evita trocas de ordem) e seu sinal e alinhado ao do original.
bootstrap_acp <- function(X, V0, B = 2000) {
  k <- ncol(V0)
  p <- ncol(X)
  aut <- matrix(NA, B, p); carg <- array(NA, c(B, p, k))
  for (b in 1:B) {
    Xb <- X[sample(nrow(X), replace = TRUE), ]
    e <- eigen(cor(Xb), symmetric = TRUE)
    aut[b, ] <- e$values
    C <- abs(t(V0) %*% e$vectors)                         # k x p
    usados <- integer(0)
    for (j in 1:k) {
      cand <- setdiff(1:p, usados)
      m <- cand[which.max(C[j, cand])]; usados <- c(usados, m)
      v <- e$vectors[, m]
      if (sum(v * V0[, j]) < 0) v <- -v
      carg[b, , j] <- v
    }
  }
  list(autovalores = aut, cargas = carg)
}

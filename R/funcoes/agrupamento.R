###############################################################################
# ME731 - Projeto 2 - Funcoes auxiliares: agrupamento (silhueta, Rand ajustado, Ward + k-medias)
# (somente R base: stats, graphics, utils)
###############################################################################

# ---- Largura media de silhueta (Rousseeuw, 1987) -----------------------------
silhueta <- function(D, grupos) {
  D <- as.matrix(D); n <- nrow(D); s <- numeric(n)
  for (i in 1:n) {
    gi <- grupos[i]
    if (sum(grupos == gi) == 1) { s[i] <- 0; next }
    a <- mean(D[i, grupos == gi & seq_len(n) != i])
    b <- min(sapply(setdiff(unique(grupos), gi), function(g) mean(D[i, grupos == g])))
    s[i] <- (b - a) / max(a, b)
  }
  s
}

# ---- Indice de Rand ajustado (Hubert e Arabie, 1985) -------------------------
rand_ajustado <- function(a, b) {
  tab <- table(a, b); n <- sum(tab)
  c2 <- function(x) x * (x - 1) / 2
  s_ij <- sum(c2(tab)); s_a <- sum(c2(rowSums(tab))); s_b <- sum(c2(colSums(tab)))
  esp <- s_a * s_b / c2(n); mx <- (s_a + s_b) / 2
  (s_ij - esp) / (mx - esp)
}

# ---- Agrupamento: Ward (distancia euclidiana) refinado por k-medias -----------
agrupa <- function(Z, k) {
  hc <- hclust(dist(Z), method = "ward.D2")
  g0 <- cutree(hc, k)
  centros <- apply(Z, 2, function(z) tapply(z, g0, mean))
  km <- kmeans(Z, centers = centros, iter.max = 100)
  list(ward = g0, kmedias = km$cluster, centros = km$centers, hc = hc)
}

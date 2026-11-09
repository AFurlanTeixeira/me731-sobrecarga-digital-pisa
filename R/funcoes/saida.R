###############################################################################
# ME731 - Projeto 2 - Funcoes auxiliares: saida (tabelas e figuras)
# (somente R base: stats, graphics, utils)
###############################################################################

# ---- Gravacao de tabelas ------------------------------------------------------
grava <- function(obj, nome, dig = 4) {
  if (is.matrix(obj) || is.data.frame(obj)) {
    obj <- as.data.frame(obj)
    num <- vapply(obj, is.numeric, TRUE); obj[num] <- lapply(obj[num], signif, dig)
  } else obj <- data.frame(item = names(obj), valor = signif(unname(obj), dig))
  write.csv(obj, file.path("results", "tables", paste0(nome, ".csv")),
            row.names = !is.null(rownames(obj)) && !all(rownames(obj) == seq_len(nrow(obj))))
  cat("\n===== ", nome, " =====\n"); print(obj)
  invisible(obj)
}

abre_png <- function(nome, w = 2000, h = 1500) {
  png(file.path("results", "figures", paste0(nome, ".png")), width = w, height = h, res = 220)
}

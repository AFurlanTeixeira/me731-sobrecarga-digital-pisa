#!/usr/bin/env sh
# Junta as secoes do relatorio num unico PDF (requer pandoc >= 3 e XeLaTeX).
# Execucao (na raiz do repositorio):  sh relatorio/gerar_pdf.sh
set -e
cd "$(dirname "$0")"
pandoc pdf_metadados.yaml \
  00_resumo.md 01_introducao.md 02_dados.md 03_metodos.md 04_diagnosticos.md \
  05_componentes_principais.md 06_perfis_de_paises.md 07_desempenho.md \
  08_entre_e_dentro_dos_paises.md 09_discussao.md 10_conclusao.md \
  11_referencias.md 12_apendice_reprodutibilidade.md \
  --from markdown-implicit_figures --shift-heading-level-by=-1 \
  --lua-filter=pdf_filtro.lua --pdf-engine=xelatex --resource-path=. \
  -o relatorio_completo.pdf
echo "PDF gerado: relatorio/relatorio_completo.pdf"

# 📱 Sobrecarga Digital e Desempenho no PISA 2022

### 📌 Sobre o Projeto

Projeto 2 de **Análise Multivariada** (ME731, Estatística, Unicamp, 2º semestre de 2026). O texto-base é a reportagem *Emails "pose threat to IQ"* (*The Guardian*, 22 abr. 2005), segundo a qual a "infomania", isto é, estar sempre conectado e ser interrompido por mensagens, reduziria o QI em 10 pontos. O projeto testa essa tese com dados abertos e pergunta se o prejuízo vem do **volume** de uso (tempo de tela) ou do **padrão fragmentado** de uso (notificações, disponibilidade constante, ansiedade sem o aparelho).

A análise usa 9 indicadores de uso digital construídos a partir dos microdados do PISA 2022 para **74 países e economias** e combina:

1. **Análise de componentes principais**, com bootstrap das cargas e dos autovalores;
2. **Análise de agrupamento** dos países (Ward refinado por k-médias);
3. **Regressão linear multivariada**, **MANOVA** e **MANCOVA** do desempenho em Matemática, Leitura e Ciências, controlando o nível socioeconômico (ESCS);
4. **Meta-análise de efeitos intrapaís** (erros-padrão por replicação BRR e valores plausíveis), para contrastar a associação entre países com a associação dentro dos países.

O relatório completo está em [`relatorio/`](relatorio/README.md), dividido por seções.

- **Referência estatística:** Johnson & Wichern, *Applied Multivariate Statistical Analysis*, 4ª ed. (1998); OECD, *PISA Data Analysis Manual* (2009) para pesos, replicações e valores plausíveis.
- **Autor:** Arthur Agostinho (RA 164363). **Docente:** Prof. Aluísio de Souza Pinheiro.

---

### 📄 Dados

| Fonte | Papel | Onde |
|---|---|---|
| [OECD, *PISA 2022 Database*](https://www.oecd.org/en/data/datasets/pisa-2022-database.html), questionário do estudante (`CY08MSP_STU_QQQ`) | Microdados de 613.744 estudantes em 80 países e economias | fora do git (`dados_brutos/`) |
| Agregação por país (saída de `python/01_agrega_pisa.py`) | 80 países × indicadores digitais, ESCS e proficiências (média dos 10 valores plausíveis, peso `W_FSTUWT`) | [`data/pisa2022_paises.csv`](data/pisa2022_paises.csv) |
| Diferenças intrapaís | Diferenças de Matemática, dado o ESCS, com EP por BRR (Fay, 80 réplicas) e combinação de Rubin | [`data/pisa2022_gap_intrapais.csv`](data/pisa2022_gap_intrapais.csv) |

Os dois CSVs agregados estão versionados, então a análise em R roda sem os microdados. A amostra analítica tem **n = 74** sistemas (35 da OCDE). Os Estados Unidos, o Vietnã, a Guatemala, o Camboja e o Paraguai não aplicaram os itens ST322 e ST326, e a Costa Rica não tem ESCS no arquivo.

**Indicadores (p = 9):** distração com o próprio dispositivo e com o dos colegas; horas de lazer digital na escola, em dia de aula e no fim de semana; notificações ativas na aula; manter o aparelho por perto para responder; pressão para estar online; ansiedade sem o aparelho.

---

### 🎯 Perguntas a Responder

1. **(Q1)** Os hábitos digitais se organizam em dimensões distintas de *volume* e de *fragmentação*? (ACP)
2. **(Q2)** Existem perfis de países com padrões digitais semelhantes? (agrupamento)
3. **(Q3)** Essas dimensões se associam ao desempenho, descontado o nível socioeconômico? (regressão multivariada e MANCOVA)
4. **(Q4)** A associação entre países se repete *dentro* dos países, no nível do aluno? (meta-análise intrapaís)

---

## 📊 Principais Resultados

| Pergunta | Resultado |
|---|---|
| Q1 | Três componentes (Kaiser + gráfico de cotovelo) explicam **81%** da variação: **CP1, volume** de uso (36%); **CP2, uso fragmentado e compulsivo** (27%), com notificações ativas, ansiedade sem o aparelho e distração causada por colegas; **CP3, pressão sem distração** (19%), típica do Leste Asiático |
| Q2 | **5 grupos** de países (7, 19, 8, 16 e 24 sistemas), com estabilidade moderada no bootstrap (Rand ajustado médio de 0,66) |
| Q3 | Dado o ESCS, o volume quase não se associa à Matemática (r parcial = −0,01), enquanto a CP2 tem r parcial de −0,60 a −0,67 nas três áreas. Na regressão multivariada, a CP2 tem Λ de Wilks = 0,39 (F(3, 67) = 34,5, p < 0,001), e as componentes somam 24 a 30 p.p. de R² ao ESCS |
| Q4 | Dentro dos países, quem raramente desliga as notificações tem **−26,5 pontos** em Matemática (IC 95%: −28,4 a −24,6), negativo e significativo nos 74 sistemas. Mais de 4 h/dia de lazer digital associa-se a **+6,3** pontos |

A comparação entre países superestima o efeito das notificações em cerca de nove vezes (−242 contra −26,5 pontos na mesma escala), um exemplo de **falácia ecológica**. Os resultados são compatíveis com a direção da tese da reportagem, mas não estabelecem causalidade. Além disso, o estudo original citado pela reportagem teve oito participantes e nunca foi publicado.

---

## 🧮 Arquitetura

```
dados_brutos/CY08MSP_STU_QQQ.(SAV|parquet)
        │
        ▼
python/01_agrega_pisa.py  ── pesos finais, 10 valores plausíveis, BRR (Fay, 80 réplicas)
        │
        ├──► data/pisa2022_paises.csv
        └──► data/pisa2022_gap_intrapais.csv
                    │
                    ▼
R/00_executar_tudo.R  ── carrega R/funcoes/*.R, semente 731, roda as etapas em ordem
        │
        ├─ 01_dados_descritiva.R   amostra analítica, descritiva, correlações
        ├─ 02_diagnosticos.R       esfericidade de Bartlett, Mardia, gráfico qui-quadrado
        ├─ 03_acp.R                autovalores, escolha de K, cargas, bootstrap
        ├─ 04_agrupamento.R        Ward + k-médias, silhueta, estabilidade
        ├─ 05_desempenho.R         regressão multivariada (Wilks), MANOVA, MANCOVA
        ├─ 06_entre_dentro.R       meta-análise DerSimonian–Laird, entre × dentro
        └─ 07_sensibilidade.R      OCDE, sem atípicos, Spearman, partição alternativa
                    │
                    ▼
results/tables/ (29 CSVs) · results/figures/ (10 PNGs) · results/log_execucao.txt
```

---

## 🛠️ Configuração do Projeto

### Pré-requisitos

| Ferramenta | Versão mínima | Uso |
|-----------|--------------|-----|
| R | 4.0 | Análise (somente pacotes da distribuição base: `stats`, `graphics`, `utils`) |
| Python | 3 | Só para agregar os microdados (opcional) |
| Pacotes Python | `pandas` + `pyarrow` (`.parquet`) ou `pyreadstat` (`.SAV`) | Leitura dos microdados |

### Instalação

```bash
pip install pandas pyarrow pyreadstat   # só para a etapa 1
```

A análise em R não precisa de nenhum pacote adicional.

---

## 🏡 Rodando localmente

Na raiz do repositório:

```bash
# 1. Agregação dos microdados (opcional: os CSVs já estão em data/)
python3 python/01_agrega_pisa.py CAMINHO/CY08MSP_STU_QQQ.SAV

# 2. Análise completa (alguns segundos)
Rscript R/00_executar_tudo.R
```

Os arquivos `R/01_…` a `R/07_…` não rodam isoladamente: cada etapa usa os objetos das anteriores e todas compartilham a mesma sequência de números aleatórios. Execute sempre o `00_executar_tudo.R`.

### Reprodutibilidade

- Semente 731; duas execuções na mesma plataforma produzem tabelas idênticas byte a byte.
- O script confere os checksums MD5 das entradas e grava o `sessionInfo()` em `results/log_execucao.txt`.
- Resultados críticos são conferidos com `stopifnot` contra `prcomp` e `anova.mlm`.

---

## 💾 Estrutura de Pastas

```
python/
  01_agrega_pisa.py               # Microdados → indicadores por país e diferenças intrapaís (BRR + PVs)
R/
  00_executar_tudo.R              # Ponto de entrada
  01_dados_descritiva.R           # Etapa 1: dados e descritiva
  02_diagnosticos.R               # Etapa 2: diagnósticos antes da ACP
  03_acp.R                        # Etapa 3: componentes principais e bootstrap
  04_agrupamento.R                # Etapa 4: agrupamento dos países
  05_desempenho.R                 # Etapa 5: regressão multivariada, MANOVA e MANCOVA
  06_entre_dentro.R               # Etapa 6: meta-análise intrapaís, entre × dentro
  07_sensibilidade.R              # Etapa 7: análises de sensibilidade
  funcoes/
    diagnosticos.R                # Bartlett, KMO, Mardia, Mahalanobis
    acp.R                         # Análise paralela, vara quebrada, congruência, bootstrap da ACP
    agrupamento.R                 # Silhueta, Rand ajustado, Ward + k-médias
    modelos.R                     # Λ de Wilks (F de Rao e χ² de Bartlett), meta-análise, correlação parcial
    saida.R                       # Gravação de tabelas e figuras
data/
  pisa2022_paises.csv             # 80 países × indicadores (versionado)
  pisa2022_gap_intrapais.csv      # Diferenças intrapaís com EP BRR (versionado)
  rotulos_paises.json             # Nomes oficiais dos países
results/
  tables/                         # t01–t16 (CSV)
  figures/                        # f01–f10 (PNG)
  log_execucao.txt                # Log completo da última execução
relatorio/
  README.md                       # Capa e índice
  00_resumo.md                    # Resumo
  01_introducao.md                # Texto-base, literatura e perguntas
  02_dados.md                     # Fonte, indicadores e descritiva
  03_metodos.md                   # Fundamentação estatística
  04_diagnosticos.md … 08_entre_e_dentro_dos_paises.md   # Resultados
  09_discussao.md                 # Discussão crítica e limitações
  10_conclusao.md
  11_referencias.md
  12_apendice_reprodutibilidade.md
```

---

### ✅ Checklist de Entregas

[x] Texto-base e revisão da literatura sobre sobrecarga digital

[x] Agregação dos microdados do PISA 2022 com pesos, valores plausíveis e BRR

[x] Diagnósticos (esfericidade, normalidade multivariada, atípicos)

[x] ACP com escolha de K e bootstrap das cargas

[x] Agrupamento dos países e estabilidade

[x] Regressão multivariada, MANOVA e MANCOVA

[x] Meta-análise intrapaís e contraste entre × dentro dos países

[x] Análises de sensibilidade

[x] Relatório técnico

---

## 📜 Licença

Distribuído sob a licença MIT. Veja [`LICENSE`](LICENSE). Os microdados do PISA 2022 são da OCDE e seguem os termos de uso da organização.

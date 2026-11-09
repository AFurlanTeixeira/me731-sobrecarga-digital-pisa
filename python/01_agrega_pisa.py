"""
ME731 - Projeto 2 - Etapa 1: agregacao dos microdados do PISA 2022 por pais.

Entrada : questionario do estudante do PISA 2022 (arquivo CY08MSP_STU_QQQ),
          em .SAV (formato distribuido pela OCDE) ou em .parquet (mesmo conteudo).
Saidas  : data/pisa2022_paises.csv        -> uma linha por pais/economia
          data/pisa2022_gap_intrapais.csv -> diferencas intrapais com erro-padrao BRR

Uso:
    python3 python/01_agrega_pisa.py CAMINHO_PARA_STU_QQQ   (arquivo .SAV ou pasta com .parquet)

Metodologia (OECD, PISA Data Analysis Manual, 2009, caps. 7-8):
  * todas as estatisticas usam o peso final do estudante W_FSTUWT;
  * escores de proficiencia: media das estatisticas calculadas com cada um dos
    10 valores plausiveis (PV1..PV10);
  * erro-padrao: 80 pesos replicados BRR com ajuste de Fay (k = 0,5),
    variancia total = U + (1 + 1/M) B  (regras de Rubin, M = 10).
"""
import sys, os, glob, json
import numpy as np
import pandas as pd

RAIZ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ENTRADA = sys.argv[1] if len(sys.argv) > 1 else os.path.join(RAIZ, "dados_brutos", "CY08MSP_STU_QQQ")

PV = lambda dom: [f"PV{i}{dom}" for i in range(1, 11)]
REPW = [f"W_FSTURWT{i}" for i in range(1, 81)]
ITENS = ["ST273Q06JA", "ST273Q07JA", "ST326Q04JA", "ST326Q05JA", "ST326Q06JA",
         "ST322Q01JA", "ST322Q03JA", "ST322Q06JA", "ST322Q07JA"]
COLS = ["CNT", "OECD", "W_FSTUWT", "ESCS", "ANXMAT"] + ITENS + PV("MATH") + PV("READ") + PV("SCIE") + REPW

# ---------------------------------------------------------------- leitura
if os.path.isdir(ENTRADA):
    import pyarrow.parquet as pq
    arqs = sorted(glob.glob(os.path.join(ENTRADA, "*.parquet")))
    df = pd.concat([pq.read_table(a, columns=COLS).to_pandas() for a in arqs], ignore_index=True)
else:
    df = pd.read_spss(ENTRADA, usecols=COLS, convert_categoricals=False)
for c in COLS:
    if c != "CNT":
        df[c] = pd.to_numeric(df[c], errors="coerce")
# codigos de ausencia do PISA (95 a 99) -> NA nas variaveis de questionario
for c in ITENS:
    df.loc[df[c] >= 95, c] = np.nan
for c in ["ESCS", "ANXMAT"]:
    df.loc[df[c] >= 95, c] = np.nan
print("Estudantes lidos:", len(df), "| paises/economias:", df.CNT.nunique())

# ---------------------------------------------------------------- variaveis derivadas
# horas por dia (ponto medio das classes do item ST326): nenhuma=0; ate 1h=0,5; ...; mais de 7h=7,5
HORAS = {1: 0.0, 2: 0.5, 3: 1.5, 4: 2.5, 5: 3.5, 6: 4.5, 7: 5.5, 8: 6.5, 9: 7.5}
def ind(cond, base):
    """indicadora 0/1 com NA quando o item e ausente"""
    out = cond.astype(float)
    out[base.isna()] = np.nan
    return out

d = pd.DataFrame({"CNT": df.CNT, "w": df.W_FSTUWT})
# ST273: 1 = toda aula, 2 = maioria das aulas, 3 = algumas aulas, 4 = nunca/quase nunca
d["DIST_PROPRIA"] = ind(df.ST273Q06JA <= 2, df.ST273Q06JA)      # se distrai com dispositivo
d["DIST_COLEGAS"] = ind(df.ST273Q07JA <= 2, df.ST273Q07JA)      # se distrai com dispositivo de colegas
d["H_LAZER_ESCOLA"] = df.ST326Q04JA.map(HORAS)                  # horas/dia de lazer digital na escola
d["H_LAZER_SEMANA"] = df.ST326Q05JA.map(HORAS)                  # antes/depois da escola
d["H_LAZER_FDS"] = df.ST326Q06JA.map(HORAS)                     # fim de semana
# ST322: 1 nunca, 2 menos da metade, 3 metade, 4 mais da metade, 5 sempre/quase sempre
d["NOTIF_ATIVAS"] = ind(df.ST322Q01JA <= 2, df.ST322Q01JA)       # raramente desliga notificacoes na aula
d["SEMPRE_DISPONIVEL"] = ind(df.ST322Q03JA >= 4, df.ST322Q03JA)  # mantem o aparelho perto p/ responder msgs
d["PRESSAO_ONLINE"] = ind(df.ST322Q06JA >= 4, df.ST322Q06JA)     # pressao p/ estar online na aula
d["ANSIEDADE_SEM_DISP"] = ind(df.ST322Q07JA >= 4, df.ST322Q07JA) # nervoso sem o aparelho
d["ESCS"] = df.ESCS
d["ANXMAT"] = df.ANXMAT
XVARS = ["DIST_PROPRIA", "DIST_COLEGAS", "H_LAZER_ESCOLA", "H_LAZER_SEMANA", "H_LAZER_FDS",
         "NOTIF_ATIVAS", "SEMPRE_DISPONIVEL", "PRESSAO_ONLINE", "ANSIEDADE_SEM_DISP"]

def wmean(x, w):
    m = x.notna()
    return np.nan if m.sum() == 0 else float(np.sum(x[m] * w[m]) / np.sum(w[m]))

# nomes dos paises (rotulos oficiais do arquivo)
nomes = {}
dic = os.path.join(RAIZ, "data", "rotulos_paises.json")
if os.path.exists(dic):
    nomes = json.load(open(dic, encoding="utf-8"))

# ---------------------------------------------------------------- medias por pais
linhas = []
for cnt, g in df.groupby("CNT"):
    gd = d.loc[g.index]
    w = gd.w
    lin = {"CNT": cnt, "PAIS": nomes.get(cnt, cnt), "OCDE": int(g.OECD.iloc[0] == 1),
           "N_ALUNOS": len(g)}
    for v in XVARS:
        lin[v] = wmean(gd[v], w)
        lin["COBERTURA_" + v] = float(gd[v].notna().mean())
    lin["ESCS"] = wmean(gd.ESCS, w)
    lin["ANXMAT"] = wmean(gd.ANXMAT, w)
    for dom, nome in [("MATH", "MAT"), ("READ", "LEI"), ("SCIE", "CIE")]:
        lin[nome] = float(np.mean([wmean(g[p], w) for p in PV(dom)]))
    linhas.append(lin)
paises = pd.DataFrame(linhas)
for v in XVARS[:2] + XVARS[5:]:
    paises[v] = 100 * paises[v]               # proporcoes em %

# ---------------------------------------------------------------- diferencas intrapais (BRR + PV)
def gap_brr(g, gd, var_bin):
    """MAT ~ a + b*indicadora + c*ESCS; retorna b, EP(b) e n."""
    ok = gd[var_bin].notna() & gd.ESCS.notna()
    if ok.sum() < 200:
        return np.nan, np.nan, int(ok.sum())
    X = np.column_stack([np.ones(ok.sum()), gd.loc[ok, var_bin].values, gd.loc[ok, "ESCS"].values])
    Y = g.loc[ok, PV("MATH")].values                                   # n x 10
    W = np.column_stack([g.loc[ok, "W_FSTUWT"].values, g.loc[ok, REPW].values])  # n x 81
    est = np.empty((81, 10))
    for r in range(81):
        XtW = X.T * W[:, r]
        est[r] = np.linalg.solve(XtW @ X, XtW @ Y)[1]
    theta = est[0]                                                     # 10 estimativas (uma por PV)
    U = np.mean(np.sum((est[1:] - theta) ** 2, axis=0) / (80 * 0.25))  # Fay, k = 0,5
    B = np.var(theta, ddof=1)
    return float(theta.mean()), float(np.sqrt(U + 1.1 * B)), int(ok.sum())

d["LAZER_4H"] = ind(df.ST326Q05JA >= 6, df.ST326Q05JA)    # mais de 4 h/dia de lazer digital em dias de aula
gaps = []
for cnt, g in df.groupby("CNT"):
    gd = d.loc[g.index]
    b1, s1, n1 = gap_brr(g, gd, "DIST_PROPRIA")
    b2, s2, n2 = gap_brr(g, gd, "NOTIF_ATIVAS")
    b3, s3, n3 = gap_brr(g, gd, "LAZER_4H")
    gaps.append({"CNT": cnt, "GAP_DIST": b1, "EP_GAP_DIST": s1, "N_DIST": n1,
                 "GAP_NOTIF": b2, "EP_GAP_NOTIF": s2, "N_NOTIF": n2,
                 "GAP_LAZER4H": b3, "EP_GAP_LAZER4H": s3, "N_LAZER4H": n3})
gaps = pd.DataFrame(gaps)

os.makedirs(os.path.join(RAIZ, "data"), exist_ok=True)
paises.round(6).to_csv(os.path.join(RAIZ, "data", "pisa2022_paises.csv"), index=False)
gaps.round(6).to_csv(os.path.join(RAIZ, "data", "pisa2022_gap_intrapais.csv"), index=False)
print("Gravado: data/pisa2022_paises.csv (", len(paises), "linhas )")
print("Gravado: data/pisa2022_gap_intrapais.csv")

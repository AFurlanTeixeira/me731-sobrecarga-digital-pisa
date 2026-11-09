## 3. Métodos

Esta seção define cada estimador e cada teste, as suposições de que dependem e o que fica fora da inferência. As referências estatísticas são **Johnson e Wichern (1998)**, abreviado **JW**, para os métodos multivariados, e o *PISA Data Analysis Manual* (OCDE, 2009), para o uso correto dos pesos amostrais, dos pesos replicados e dos valores plausíveis do PISA. Seções, resultados (*Result*), equações e tabelas de JW citados a seguir são os da 4ª edição. Algumas etapas usam procedimentos que nenhuma das duas obras trata, como bootstrap, testes de Mardia, silhueta, Rand ajustado e meta-análise. Elas são indicadas como **procedimentos complementares** e descritas por suas fórmulas, para que possam ser verificadas sem outra fonte. A notação segue JW: $n = 74$ países, $p = 9$ indicadores digitais (bloco $\mathbf{X}$), $m = 3$ respostas (bloco $\mathbf{Y}$) e $K$ componentes retidas.

### 3.1 Estrutura inferencial e hipóteses

**Dois níveis de análise.** As Seções 3.3 a 3.5 tratam o **país** como unidade: cada linha de $\mathbf{X}$ e de $\mathbf{Y}$ é um vetor de médias nacionais. A Seção 3.6 trata o **aluno** como unidade, dentro de cada país, e combina os resultados entre países. Os dois níveis respondem a perguntas diferentes, e a comparação entre eles (Seção 3.6.4) é parte do resultado.

**Interpretação das inferências entre países.** Os testes de JW supõem que as linhas de $\mathbf{X}$ são uma amostra aleatória de uma população (JW, Seção 3.3). Os 74 sistemas não são uma amostra aleatória de países: são praticamente todos os participantes do PISA 2022 que aplicaram os itens de interesse. Os testes entre países devem, portanto, ser lidos sob um modelo de **superpopulação**, em que as médias nacionais são tratadas como realizações independentes de um processo gerador comum. É uma suposição de modelagem, e não uma propriedade do desenho amostral.

**Hipóteses.** A tese da reportagem, refinada pela literatura da Seção 1.3, gera previsões falseáveis em cada etapa:

| Pergunta | Hipótese nula | Previsão sob a tese da fragmentação |
|---|---|---|
| Q1 | $\boldsymbol{\rho} = \mathbf{I}$; nenhuma estrutura de baixa dimensão | Componentes distintas de volume e de fragmentação, com sinais estáveis |
| Q3 | $\boldsymbol{\beta}_{(\text{CP}j)} = \mathbf{0}_{1\times 3}$, dado o ESCS | $\boldsymbol{\beta}_{(\text{CP2})} < \mathbf{0}$ nas três áreas; $\boldsymbol{\beta}_{(\text{CP1})}$ próximo de zero |
| Q3 | Vetores de médias de $\mathbf{Y}$ iguais entre grupos, dado o ESCS | Grupos com mais fragmentação têm médias ajustadas menores |
| Q4 | $\mu_D = 0$ (efeito médio intrapaís) | $\mu_{\text{notif}} < 0$; $\mu_{\text{lazer}}$ não negativo |

O nível de significância nominal é $\alpha = 0{,}05$. Não foi aplicada correção para testes múltiplos. Os quatro testes de Wilks da regressão multivariada (Tabela 8) têm, porém, $p < 0{,}001$ e continuariam significativos pela desigualdade de Bonferroni (JW, Seção 5.4, Eq. 5-28), com $\alpha/4 = 0{,}0125$.

### 3.2 Construção dos indicadores

**Estimadores por país.** Seja $w_i$ o peso amostral final do aluno $i$ (`W_FSTUWT`), que é o inverso da probabilidade de inclusão, ajustado por não resposta. Para um indicador $x$ e um país $c$, a média nacional é a média ponderada

$$
\bar{x}_c = \frac{\sum_{i \in c} w_i\, x_i}{\sum_{i \in c} w_i},
$$

calculada sobre os alunos com resposta válida ao item (códigos 95 a 99 do PISA tratados como ausentes). Para os indicadores percentuais, $x_i$ é uma indicadora 0/1, e $\bar{x}_c$ é a proporção ponderada, multiplicada por 100. Para as horas de lazer digital, cada classe do item ST326 foi convertida no seu ponto médio: nenhuma = 0; até 1 h = 0,5; de 1 a 2 h = 1,5; e assim por diante, até mais de 7 h = 7,5. A taxa de resposta a cada item foi registrada em `data/pisa2022_paises.csv`.

**Valores plausíveis.** A proficiência do aluno não é observada diretamente: o PISA fornece $M = 10$ valores plausíveis por área. A média nacional é $\bar{y}_c = M^{-1}\sum_{m'=1}^{M} \bar{y}_c^{(m')}$, em que $\bar{y}_c^{(m')}$ é a média ponderada com o $m'$-ésimo valor plausível. É o procedimento prescrito pela OCDE (2009, cap. 6) para estes dados.

**O que fica fora.** As médias $\bar{x}_c$ e $\bar{y}_c$ são estimativas, com erro amostral. Nas Seções 3.3 a 3.5, elas são tratadas como valores fixos. Como cada país tem de 3.127 a 30.800 alunos na amostra, esse erro é pequeno em relação à variação entre países, mas não é nulo (Seção 9.2).

### 3.3 Componentes principais

#### 3.3.1 Definição e propriedades

Seja $\mathbf{S}$ a matriz de covariâncias amostral de $\mathbf{X}_{(n\times p)}$ e $\mathbf{D}^{1/2} = \operatorname{diag}(\sqrt{s_{11}}, \dots, \sqrt{s_{pp}})$. A ACP foi feita na matriz de **correlações** amostral $\mathbf{R} = \mathbf{D}^{-1/2}\mathbf{S}\,\mathbf{D}^{-1/2}$, que é a matriz de covariâncias das variáveis padronizadas $\mathbf{z}_i = \mathbf{D}^{-1/2}(\mathbf{x}_i - \bar{\mathbf{x}})$ (JW, Seção 8.3, Eqs. 8-25 a 8-28). O motivo é que os indicadores estão em escalas diferentes (porcentagens e horas). Na matriz de covariâncias, as variáveis percentuais dominariam as primeiras componentes só por terem variância maior, como JW discutem a propósito das componentes de variáveis padronizadas (Seção 8.2).

Seja $\mathbf{R} = \sum_{j=1}^{p} \hat{\lambda}_j \hat{\mathbf{e}}_j\hat{\mathbf{e}}_j'$ a decomposição espectral, com $\hat{\lambda}_1 \geq \cdots \geq \hat{\lambda}_p \geq 0$ e $\hat{\mathbf{e}}_j'\hat{\mathbf{e}}_k = \delta_{jk}$. O escore do país $i$ na $j$-ésima componente é $\hat{y}_{ij} = \hat{\mathbf{e}}_j'\mathbf{z}_i$. Pelo lema de maximização de formas quadráticas na esfera unitária (JW, Seção 2.7, Eqs. 2-51 e 2-52), que fundamenta o Result 8.1,

$$
\max_{\mathbf{a} \neq \mathbf{0}} \frac{\mathbf{a}'\mathbf{R}\mathbf{a}}{\mathbf{a}'\mathbf{a}} = \hat{\lambda}_1 \ \ (\text{atingido em } \mathbf{a} = \hat{\mathbf{e}}_1),
\qquad
\max_{\mathbf{a}\perp \hat{\mathbf{e}}_1, \dots, \hat{\mathbf{e}}_{j-1}} \frac{\mathbf{a}'\mathbf{R}\mathbf{a}}{\mathbf{a}'\mathbf{a}} = \hat{\lambda}_j \ \ (\text{atingido em } \mathbf{a} = \hat{\mathbf{e}}_j).
$$

Assim, a $j$-ésima componente é a combinação linear normalizada de variância amostral máxima, entre as não correlacionadas com as anteriores. Daí decorrem as propriedades usadas no texto (JW, Results 8.1 a 8.4 e Eqs. 8-20 e 8-28 a 8-30):

- os escores têm variância amostral $\hat{\lambda}_j$ e covariância amostral zero entre componentes distintas;
- a variância total padronizada é $\operatorname{tr}(\mathbf{R}) = \sum_j \hat{\lambda}_j = p$, de modo que a componente $j$ explica a fração $\hat{\lambda}_j/p$ (Eq. 8-30);
- a correlação entre a variável $k$ e a componente $j$ é $r_{\hat{y}_j, z_k} = \hat{e}_{kj}\sqrt{\hat{\lambda}_j}$ (Result 8.3, na versão para variáveis padronizadas do Result 8.4);
- a **comunalidade** de $k$ nas $K$ componentes retidas é $h_k^2 = \sum_{j=1}^{K} r_{\hat{y}_j, z_k}^2$, a fração da variância de $z_k$ reproduzida pelo subespaço principal. O termo vem de JW, Seção 9.2, e aqui é usado no sentido descritivo.

As duas primeiras propriedades foram conferidas numericamente no script, que também confirma que os vetores coincidem, a menos do sinal, com os da função `prcomp`. Como o sinal de $\hat{\mathbf{e}}_j$ é arbitrário, adotou-se a convenção $\sum_k \hat{e}_{kj} > 0$.

#### 3.3.2 Adequação dos dados

A ACP é um procedimento descritivo e não exige normalidade, mas só é útil se as variáveis forem correlacionadas. Se $\boldsymbol{\rho} = \mathbf{I}$, todas as componentes têm a mesma variância e nada se ganha com elas (JW, Seção 8.2, discussão da Eq. 8-13). Isso foi verificado pelo **teste de esfericidade de Bartlett**. JW (Seção 9.3, Eq. 9-39) apresentam o teste de razão de verossimilhanças, com a correção de Bartlett, para a hipótese de que $m^*$ fatores comuns bastam. No caso $m^* = 0$, o modelo se reduz a $\boldsymbol{\Sigma}$ diagonal, isto é, $\boldsymbol{\rho} = \mathbf{I}$. A razão de variâncias generalizadas da Eq. 9-39 passa a ser $|\operatorname{diag}(\mathbf{S}_n)|/|\mathbf{S}_n| = 1/|\mathbf{R}|$, e a estatística se torna
$$
-\Big(n-1-\frac{2p+5}{6}\Big)\ln|\mathbf{R}| \;\dot\sim\; \chi^2_{p(p-1)/2} \quad \text{sob } H_0: \boldsymbol{\rho} = \mathbf{I},
$$
com $[(p - 0)^2 - p - 0]/2 = p(p-1)/2$ graus de liberdade. Com $n = 74$, o teste tem poder alto mesmo contra correlações modestas, por isso é uma condição necessária e não suficiente.

#### 3.3.3 Número de componentes

JW (Seção 8.3) observam que não há resposta definitiva para quantas componentes reter. Recomendam considerar conjuntamente quatro elementos:

1. a **fração da variância total explicada** pelas componentes retidas;
2. os **tamanhos relativos dos autovalores**, por meio do **gráfico de cotovelo** (*scree plot*): retêm-se as componentes até o ponto a partir do qual os autovalores restantes são relativamente pequenos e de tamanho parecido;
3. a **regra de Kaiser**: reter as componentes com $\hat{\lambda}_j > 1$, isto é, as que explicam individualmente ao menos $1/p$ da variância total;
4. a **interpretabilidade** das componentes.

JW advertem que a regra de Kaiser "não tem muito respaldo teórico e não deve ser aplicada às cegas". Por isso, ela foi usada junto com os outros três elementos e confrontada com a incerteza amostral dos autovalores (Seção 3.3.4). Uma componente cujo intervalo de confiança fica inteiramente acima de 1 é retida com segurança pela regra. Uma cujo intervalo fica inteiramente abaixo de 1 é descartada com segurança.

#### 3.3.4 Incerteza dos autovalores e dos coeficientes

JW (Seção 8.5) apresentam os resultados assintóticos de Anderson e Girshick. Para uma amostra aleatória de uma população **normal** com autovalores **distintos** de $\boldsymbol{\Sigma}$, $\sqrt{n}(\hat{\lambda}_j - \lambda_j)$ é aproximadamente $N(0, 2\lambda_j^2)$, o que dá o intervalo de confiança aproximado de $100(1-\alpha)\%$ (Eq. 8-33)

$$
\frac{\hat{\lambda}_j}{1 + z(\alpha/2)\sqrt{2/n}} \;\leq\; \lambda_j \;\leq\; \frac{\hat{\lambda}_j}{1 - z(\alpha/2)\sqrt{2/n}}.
$$

O resultado é para a matriz de covariâncias. Os mesmos autores notam que, mesmo violada a normalidade, os intervalos ainda dão "alguma indicação" da incerteza. Aqui, as duas condições falham: a ACP é sobre $\mathbf{R}$, e a normalidade multivariada é rejeitada (Seção 4). O intervalo 8-33 é reportado como referência na Seção 5.1, mas a inferência se apoia num **bootstrap não paramétrico** (procedimento complementar):

1. sortear com reposição $n$ países, obtendo $\mathbf{X}^{*b}$, para $b = 1, \dots, B = 2.000$;
2. recalcular $\mathbf{R}^{*b}$ e sua decomposição espectral;
3. **alinhar** as componentes. A componente original $j$ é pareada, entre as ainda não usadas, à componente bootstrap $\mathbf{e}^{*}$ de maior $|\hat{\mathbf{e}}_j'\mathbf{e}^{*}|$, que é o cosseno do ângulo entre os dois vetores unitários (JW, Seção 2.2). O sinal é invertido se $\hat{\mathbf{e}}_j'\mathbf{e}^{*} < 0$;
4. tomar os quantis de 2,5% e 97,5% das réplicas como intervalo percentil de 95%.

Para os autovalores, o passo 3 não é necessário: o $j$-ésimo autovalor bootstrap é simplesmente o $j$-ésimo maior. O alinhamento se aplica aos coeficientes. O passo 3 é essencial. Quando $\hat{\lambda}_j$ e $\hat{\lambda}_{j+1}$ são próximos, as componentes podem trocar de ordem entre réplicas. JW (Seção 8.5) fazem advertência análoga para a teoria assintótica: a correlação entre os elementos de $\hat{\mathbf{e}}_j$ depende fortemente da separação entre os autovalores. Sem o alinhamento, essas trocas e as inversões de sinal produziriam intervalos artificialmente largos. Um coeficiente é considerado de **sinal estável** se seu intervalo não contém zero.

### 3.4 Agrupamento

#### 3.4.1 Espaço e métrica

Os países foram agrupados pelos escores nas $K$ componentes retidas, $\hat{\mathbf{y}}_i = (\hat{y}_{i1}, \dots, \hat{y}_{iK})'$, com distância euclidiana (JW, Seção 12.2). Como $\hat{\mathbf{y}}_i = \hat{\mathbf{E}}_K'\mathbf{z}_i$, com $\hat{\mathbf{E}}_K = [\hat{\mathbf{e}}_1, \dots, \hat{\mathbf{e}}_K]$ de colunas ortonormais,

$$
\lVert\hat{\mathbf{y}}_i - \hat{\mathbf{y}}_l\rVert = \lVert\hat{\mathbf{E}}_K\hat{\mathbf{E}}_K'(\mathbf{z}_i - \mathbf{z}_l)\rVert,
$$

em que $\hat{\mathbf{E}}_K\hat{\mathbf{E}}_K'$ é a projeção ortogonal no subespaço gerado pelas $K$ primeiras componentes. É a aproximação de posto $K$ dos dados descrita no Suplemento 8A de JW. A distância usada é, portanto, a distância entre os perfis padronizados **depois de descartada a variação residual** das $p - K$ últimas componentes. Os escores não foram padronizados: cada componente pesa na distância em proporção a $\sqrt{\hat{\lambda}_j}$, o que preserva a geometria dos dados padronizados. A alternativa, agrupar com as 9 variáveis padronizadas, foi feita como análise de sensibilidade (Seção 3.7).

#### 3.4.2 Algoritmo

O procedimento tem duas etapas (JW, Seções 12.3 e 12.4).

1. **Método hierárquico de Ward** (JW, Seção 12.3). Com $\text{ESS}_g = \sum_{i\in g}(\hat{\mathbf{y}}_i - \bar{\mathbf{y}}_g)'(\hat{\mathbf{y}}_i - \bar{\mathbf{y}}_g)$ e $\text{ESS} = \sum_g \text{ESS}_g$, funde-se a cada passo o par de grupos cuja união produz o menor aumento de ESS, a "menor perda de informação". Para dois grupos $A$ e $B$, esse aumento é
$$
\Delta(A, B) = \text{ESS}_{A\cup B} - \text{ESS}_A - \text{ESS}_B = \frac{n_A n_B}{n_A + n_B}\,\lVert\bar{\mathbf{y}}_A - \bar{\mathbf{y}}_B\rVert^2,
$$
o que se verifica decompondo a soma de quadrados em torno de $\bar{\mathbf{y}}_{A\cup B}$. JW observam que o método supõe grupos aproximadamente elípticos e que ele é o precursor hierárquico dos métodos que otimizam um critério para um número fixo de grupos. Usou-se a implementação `ward.D2` do R.
2. **k-médias** (JW, Seção 12.4, Eq. 12-16). Cada país é atribuído ao grupo de centróide mais próximo, os centróides são recalculados, e o processo se repete até não haver realocações. JW notam que o resultado depende da partição inicial. Por isso, em vez de sementes aleatórias, usaram-se como sementes os centróides da partição de Ward. Os dois métodos minimizam o mesmo ESS: o Ward fornece um ponto de partida determinístico, e o k-médias corrige alocações que o método hierárquico não pode desfazer. JW (Seção 12.3) notam que nos métodos hierárquicos "não há como realocar objetos" agrupados incorretamente num estágio inicial. Usou-se a implementação padrão da função `kmeans` do R.

#### 3.4.3 Escolha de $G$ e estabilidade (procedimentos complementares)

JW (Seção 12.3) recomendam duas verificações. A primeira é aplicar mais de um método e ver se os resultados são aproximadamente consistentes. A segunda é checar a estabilidade da solução reagrupando os dados após pequenas perturbações: "se os grupos forem bem distintos, os agrupamentos antes e depois da perturbação devem concordar". O livro, porém, não propõe um índice para escolher $G$ nem para medir a concordância. Para isso, foram usados dois procedimentos complementares. A reamostragem bootstrap faz o papel da perturbação.

**Silhueta.** Para cada país, seja $a_i$ a distância média aos demais membros do seu grupo e $b_i$ a menor distância média a outro grupo. A silhueta é $s_i = (b_i - a_i)/\max(a_i, b_i) \in [-1, 1]$, com $s_i = 0$ para grupos unitários. $s_i$ próximo de 1 indica um país bem dentro do seu grupo, e próximo de 0, um país na fronteira entre dois grupos. Escolheu-se o $G \in \{2, \dots, 6\}$ de maior silhueta média da partição do k-médias.

**Estabilidade.** A partição $\mathcal{P}$ foi reavaliada em 500 réplicas bootstrap. Em cada uma: (i) sorteiam-se $n$ países com reposição; (ii) agrupa-se a amostra bootstrap com o mesmo $G$ e o mesmo algoritmo; (iii) **todos** os 74 países são classificados no centróide bootstrap mais próximo, obtendo $\mathcal{P}^{*b}$; (iv) mede-se a concordância entre $\mathcal{P}$ e $\mathcal{P}^{*b}$ pelo **índice de Rand ajustado**. Com $n_{gh}$ o número de países no grupo $g$ de $\mathcal{P}$ e $h$ de $\mathcal{P}^{*b}$, e $n_{g\cdot}$, $n_{\cdot h}$ os totais marginais,

$$
\text{ARI} = \frac{\sum_{gh}\binom{n_{gh}}{2} - \Big[\sum_g\binom{n_{g\cdot}}{2}\sum_h\binom{n_{\cdot h}}{2}\Big]\Big/\binom{n}{2}}{\tfrac12\Big[\sum_g\binom{n_{g\cdot}}{2} + \sum_h\binom{n_{\cdot h}}{2}\Big] - \Big[\sum_g\binom{n_{g\cdot}}{2}\sum_h\binom{n_{\cdot h}}{2}\Big]\Big/\binom{n}{2}}.
$$

O numerador compara o número de pares de países agrupados juntos nas duas partições com o que se esperaria se elas fossem independentes, dadas as margens. O índice vale 1 para partições idênticas e tem valor esperado 0 sob concordância casual. Ele não depende dos rótulos dos grupos, de modo que a troca de rótulos entre réplicas não é um problema. Réplicas com no máximo $G$ países distintos foram descartadas.

### 3.5 Desempenho: regressão multivariada e MANCOVA

#### 3.5.1 Modelo

As três respostas são fortemente correlacionadas ($r$ de 0,94 a 0,98). Três regressões separadas, cada uma com nível $\alpha$, não controlariam o erro global nem usariam a estrutura de covariância entre elas. Ajusta-se o **modelo de regressão linear multivariada** (JW, Seção 7.7, Eq. 7-26):

$$
\underset{(n\times m)}{\mathbf{Y}} = \underset{(n\times (r+1))}{\mathbf{Z}}\;\underset{((r+1)\times m)}{\boldsymbol{\beta}} + \underset{(n\times m)}{\boldsymbol{\varepsilon}},
\qquad \mathbf{Z} = [\mathbf{1}, \hat{\mathbf{y}}_{(1)}, \dots, \hat{\mathbf{y}}_{(K)}, \text{ESCS}],
$$

com $m = 3$, $r = K + 1 = 4$ preditores, $E(\boldsymbol{\varepsilon}_{(i)}) = \mathbf{0}$ e $\operatorname{Cov}(\boldsymbol{\varepsilon}_{(i)}, \boldsymbol{\varepsilon}_{(k)}) = \sigma_{ik}\mathbf{I}$. Assim, as $m$ respostas de um mesmo país são correlacionadas, e países distintos são independentes. O estimador de mínimos quadrados é

$$
\hat{\boldsymbol{\beta}} = (\mathbf{Z}'\mathbf{Z})^{-1}\mathbf{Z}'\mathbf{Y},
$$

cujas colunas coincidem com as das $m$ regressões univariadas (JW, Seção 7.7). Ele é não viesado, com $\operatorname{Cov}(\hat{\boldsymbol{\beta}}_{(i)}, \hat{\boldsymbol{\beta}}_{(k)}) = \sigma_{ik}(\mathbf{Z}'\mathbf{Z})^{-1}$ (Result 7.9). Sob normalidade dos erros, é também o estimador de máxima verossimilhança, e $n\hat{\boldsymbol{\Sigma}} = \hat{\boldsymbol{\varepsilon}}'\hat{\boldsymbol{\varepsilon}}$ tem distribuição de Wishart com $n - r - 1 = 69$ graus de liberdade, independente de $\hat{\boldsymbol{\beta}}$ (Result 7.10). O que a abordagem multivariada acrescenta é a **inferência conjunta**.

Os escores entram na regressão em vez das 9 variáveis originais por duas razões. Primeiro, as componentes são não correlacionadas entre si, o que elimina a multicolinearidade entre os preditores digitais. As duas variáveis de distração, por exemplo, têm $r = 0{,}94$. JW (Seção 8.1) citam esse uso das componentes como entradas de uma regressão múltipla ou de uma análise de agrupamento. Segundo, cada coeficiente se refere a uma dimensão interpretável. As componentes não são, porém, ortogonais ao ESCS (Seção 9.2), e por isso os coeficientes são lidos como efeitos parciais.

#### 3.5.2 Teste da razão de verossimilhanças

Para testar se um conjunto de $r - q$ preditores pode ser removido, $H_0: \boldsymbol{\beta}_{(2)} = \mathbf{0}_{((r-q)\times m)}$ (JW, Eq. 7-43), ajusta-se o modelo reduzido $\mathbf{Y} = \mathbf{Z}_1\boldsymbol{\beta}_{(1)} + \boldsymbol{\varepsilon}$. Sejam $n\hat{\boldsymbol{\Sigma}}$ e $n\hat{\boldsymbol{\Sigma}}_1$ as matrizes de somas de quadrados e produtos cruzados dos resíduos dos modelos completo e reduzido, e $\mathbf{E} = n\hat{\boldsymbol{\Sigma}}$, $\mathbf{H} = n(\hat{\boldsymbol{\Sigma}}_1 - \hat{\boldsymbol{\Sigma}})$ a soma de quadrados extra. A razão de verossimilhanças se expressa por variâncias generalizadas (Eq. 7-44), e a estatística equivalente é o $\Lambda$ de Wilks:

$$
\Lambda^{2/n} = \Lambda^* = \frac{|\hat{\boldsymbol{\Sigma}}|}{|\hat{\boldsymbol{\Sigma}}_1|} = \frac{|\mathbf{E}|}{|\mathbf{E} + \mathbf{H}|} = \prod_{s=1}^{\min(m,\, r-q)} \frac{1}{1 + \eta_s},
$$

em que $\eta_s$ são os autovalores de $\mathbf{H}\mathbf{E}^{-1}$ (JW, Seção 7.7; a mesma forma aparece para a MANOVA na Seção 6.4). Valores pequenos de $\Lambda^*$ são evidência contra $H_0$. Para a distribuição de referência, duas formas foram usadas.

- **Termo com um grau de liberdade** ($r - q = 1$), como cada componente ou o ESCS. A distribuição é **exata** sob normalidade:
$$
F = \frac{1 - \Lambda^*}{\Lambda^*}\cdot\frac{n - r - 1 - m + 1}{m} \sim F_{m,\; n - r - m},
$$
o que, com $n - r - 1 = 69$ e $m = 3$, dá $F_{3,\,67}$. É o caso de uma única restrição linear, análogo à linha de dois grupos da Tabela 6.3 de JW, que dá $F_{p,\ \sum n_\ell - p - 1}$ com $\sum n_\ell - 2$ graus de liberdade do erro.
- **Caso geral.** Pelo Result 7.11, sob $H_0$ e com $n$ grande, a estatística com a correção de Bartlett
$$
-\Big[n - r - 1 - \tfrac12(m - r + q + 1)\Big]\ln\Lambda^* \;\dot\sim\; \chi^2_{m(r-q)}.
$$
É a forma usada para os grupos (Seção 3.5.5). Para os termos com um grau de liberdade, ela foi calculada também, e os p-valores coincidem com os do F exato, arredondados a dois algarismos significativos.

O valor de $\Lambda^*$ calculado pelas fórmulas acima foi conferido contra a função `anova.mlm` do R.

Complementam o teste:

- as **correlações parciais** amostrais entre cada escore e cada resposta, eliminado o ESCS (JW, Seção 7.8, Eq. 7-63). Elas foram calculadas como a correlação entre os resíduos das regressões de cada variável sobre o ESCS, o que é a definição de JW (Eq. 7-62) aplicada à amostra;
- o **ganho de $R^2$** de cada resposta ao adicionar as $K$ componentes ao modelo que contém só o ESCS (JW, Seção 7.3);
- os coeficientes e erros-padrão das regressões univariadas para Matemática.

#### 3.5.3 Suposições e diagnóstico

A inferência supõe linearidade, homocedasticidade, normalidade multivariada dos erros e independência entre países. O diagnóstico seguiu JW (Seções 7.6 e 7.7):

- **resíduos contra valores ajustados**, para linearidade e homocedasticidade;
- **gráfico qui-quadrado** dos resíduos multivariados (JW, Seção 4.6). Com $d_i^2 = \hat{\boldsymbol{\varepsilon}}_i'\mathbf{S}_\varepsilon^{-1}\hat{\boldsymbol{\varepsilon}}_i$ ordenados, plotam-se os pares $\big(q_{c,m}((i - \frac12)/n),\ d_{(i)}^2\big)$, em que $q_{c,m}(\cdot)$ é o quantil da $\chi^2_m$. Sob normalidade, os pontos devem cair próximos da reta de inclinação 1;
- **influência de atípicos**: o modelo foi reajustado sem os países com $d_i^2 > \chi^2_3(0{,}01)$.

Há duas fontes de incerteza que os erros-padrão **não** incorporam. A primeira é que os escores são **regressores estimados**: $\hat{\mathbf{e}}_j$ foi calculado com os mesmos dados, e os erros-padrão são condicionais a $\hat{\mathbf{E}}_K$, como se as componentes fossem conhecidas. Como $\mathbf{Y}$ não foi usado na ACP, isso não produz viés de seleção, mas os intervalos ficam um pouco estreitos demais. A segunda é o erro amostral das médias nacionais (Seção 3.2).

#### 3.5.4 Normalidade multivariada e atípicos

O método principal é o de JW (Seções 4.6 e 4.7). Sob normalidade, pelo Result 4.7, $(\mathbf{x} - \boldsymbol{\mu})'\boldsymbol{\Sigma}^{-1}(\mathbf{x} - \boldsymbol{\mu}) \sim \chi^2_p$. As distâncias amostrais

$$
d_i^2 = (\mathbf{x}_i - \bar{\mathbf{x}})'\mathbf{S}^{-1}(\mathbf{x}_i - \bar{\mathbf{x}}), \qquad i = 1, \dots, n \quad (\text{JW, Eq. 4-32}),
$$

não são independentes nem exatamente qui-quadrado. Mas JW indicam que elas se comportam aproximadamente como $\chi^2_p$ quando $n$ e $n - p$ são maiores que 25 ou 30, condição satisfeita aqui ($n = 74$, $n - p = 65$). A normalidade foi avaliada pela linearidade do gráfico qui-quadrado (Seção 4.6) e resumida pela correlação entre $d_{(i)}^2$ e os quantis teóricos. Seguindo os passos de JW para detectar atípicos (Seção 4.7), foram considerados atípicos os países com $d_i^2$ acima de $\chi^2_p(0{,}001)$.

Como **procedimento complementar**, a normalidade também foi testada pelas medidas de assimetria e curtose multivariadas de Mardia. Com $\mathbf{S}_n$ o estimador de máxima verossimilhança da covariância (JW, Seção 4.3) e $g_{il} = (\mathbf{x}_i - \bar{\mathbf{x}})'\mathbf{S}_n^{-1}(\mathbf{x}_l - \bar{\mathbf{x}})$,

$$
b_{1,p} = \frac{1}{n^2}\sum_{i=1}^{n}\sum_{l=1}^{n} g_{il}^3, \qquad b_{2,p} = \frac{1}{n}\sum_{i=1}^{n} g_{ii}^2.
$$

Sob normalidade, $n\,b_{1,p}/6 \;\dot\sim\; \chi^2_{p(p+1)(p+2)/6}$ e $z = \big[b_{2,p} - p(p+2)(n-1)/(n+1)\big]\big/\sqrt{8p(p+2)/n} \;\dot\sim\; N(0, 1)$. Note-se que $b_{2,p}$ é a média de $g_{ii}^2$, os quadrados das distâncias do gráfico qui-quadrado calculadas com $\mathbf{S}_n$ em vez de $\mathbf{S}$. As mesmas medidas foram aplicadas aos 9 indicadores (Seção 4) e aos resíduos do modelo multivariado (Seção 7.1).

#### 3.5.5 MANOVA e MANCOVA dos grupos

Para os $G$ grupos de países, a MANOVA de um fator (JW, Seção 6.4) testa $H_0: \boldsymbol{\tau}_1 = \cdots = \boldsymbol{\tau}_G = \mathbf{0}$ no modelo $\mathbf{y}_{\ell j} = \boldsymbol{\mu} + \boldsymbol{\tau}_\ell + \mathbf{e}_{\ell j}$, com $\sum_\ell n_\ell\boldsymbol{\tau}_\ell = \mathbf{0}$, por $\Lambda^* = |\mathbf{W}|/|\mathbf{B} + \mathbf{W}|$ (Eq. 6-38). Com $G = 5$ grupos e $m = 3$ respostas, o caso não está na Tabela 6.3, e usou-se a aproximação de Bartlett (Eq. 6-39):

$$
-\Big(n - 1 - \frac{m + G}{2}\Big)\ln\Lambda^* \;\dot\sim\; \chi^2_{m(G-1)}.
$$

A **MANCOVA** foi formulada, como sugere JW (Seção 7.7), como um caso particular da regressão multivariada. A matriz de delineamento contém o intercepto, o ESCS e $G - 1$ indicadoras de grupo:

$$
\mathbf{y}_i = \boldsymbol{\mu} + \boldsymbol{\tau}_{g(i)} + \boldsymbol{\gamma}\,\text{ESCS}_i + \boldsymbol{\varepsilon}_i.
$$

O efeito dos grupos, dado o ESCS, é o teste do Result 7.11 que compara esse modelo ($r = G$ preditores) com o modelo só com o ESCS ($q = 1$), com $m(r - q) = 3(G - 1)$ graus de liberdade. Sem o ESCS ($r = G - 1$, $q = 0$), o Result 7.11 reproduz exatamente a estatística 6-39 da MANOVA, já que $n - r - 1 - \frac12(m - r + q + 1) = n - 1 - \frac{m + G}{2}$. As **médias ajustadas** são os valores previstos de cada grupo no ESCS médio da amostra.

A MANCOVA supõe que a inclinação $\boldsymbol{\gamma}$ é a mesma em todos os grupos (homogeneidade das regressões). Essa suposição poderia ser testada pelo próprio Result 7.11, acrescentando as interações grupo × ESCS, mas isso não foi feito e é uma limitação. Além disso, os grupos foram formados a partir de $\mathbf{X}$, e não de $\mathbf{Y}$, de modo que o teste não é circular. Mas a partição foi estimada com os mesmos dados, e o p-valor é condicional a ela. Por isso, as conclusões principais se apoiam nos escores contínuos (Seção 3.5.2), e a MANCOVA tem papel descritivo.

### 3.6 Efeitos dentro dos países

#### 3.6.1 Modelo no nível do aluno

Uma associação entre médias de países não implica a mesma associação entre indivíduos do mesmo país. Para cada país $c$ e cada indicador binário $D$, ajustou-se no nível do aluno o modelo de regressão linear (JW, Seção 7.2)

$$
\text{MAT}_{ic}^{(m')} = a_c + b_c D_{ic} + \gamma_c\,\text{ESCS}_{ic} + u_{ic}, \qquad m' = 1, \dots, 10,
$$

por mínimos quadrados ponderados, $\hat{\boldsymbol{\theta}}_c^{(m')} = (\mathbf{X}_c'\mathbf{W}_c\mathbf{X}_c)^{-1}\mathbf{X}_c'\mathbf{W}_c\,\mathbf{y}_c^{(m')}$, com $\mathbf{W}_c = \operatorname{diag}(w_i)$. É o estimador de mínimos quadrados de JW (Seção 7.3) aplicado às variáveis multiplicadas por $\sqrt{w_i}$. Os indicadores $D$ são: (i) distrai-se com o dispositivo na maioria das aulas; (ii) raramente desliga as notificações em aula; (iii) mais de 4 h/dia de lazer digital em dias de aula (classes 6 a 9 do item ST326Q05). O parâmetro $b_c$ é a **diferença média de proficiência** entre alunos com e sem o comportamento, no mesmo país e com o mesmo ESCS. Países com menos de 200 alunos com dados completos seriam excluídos, mas nenhum dos 74 chegou perto desse limite: o menor tem 1.913 alunos.

#### 3.6.2 Erro-padrão: pesos replicados e valores plausíveis

Os alunos do PISA não são uma amostra aleatória simples: são sorteados em dois estágios (escolas, depois alunos), e alunos da mesma escola não são independentes. O erro-padrão de mínimos quadrados, que supõe independência (JW, Seção 7.2), seria pequeno demais. Por isso, a variância de $\hat{b}_c$ foi estimada pelo procedimento prescrito pela OCDE para estes dados (OCDE, 2009, caps. 7–8), que combina duas fontes:

1. **Variância amostral.** Para cada valor plausível $m'$, reestima-se $b_c$ com cada um dos $R = 80$ pesos replicados fornecidos no arquivo, obtendo $\hat{b}_{c,r}^{(m')}$. Com o fator de Fay $k = 0{,}5$,
$$
U^{(m')} = \frac{1}{R(1-k)^2}\sum_{r=1}^{R}\big(\hat{b}_{c,r}^{(m')} - \hat{b}_c^{(m')}\big)^2 = \frac{1}{20}\sum_{r=1}^{80}\big(\hat{b}_{c,r}^{(m')} - \hat{b}_c^{(m')}\big)^2, \qquad U = \frac1M\sum_{m'} U^{(m')}.
$$
2. **Variância de imputação.** $B = \frac{1}{M-1}\sum_{m'}\big(\hat{b}_c^{(m')} - \hat{b}_c\big)^2$, com $\hat{b}_c = M^{-1}\sum_{m'} \hat{b}_c^{(m')}$.
3. **Variância total.** $\widehat{\operatorname{Var}}(\hat{b}_c) = U + (1 + M^{-1})B$.

Os pesos replicados incorporam a estratificação e a correlação entre alunos da mesma escola. O termo $(1 + M^{-1})B$ incorpora o fato de a proficiência ser uma variável latente, estimada com erro.

#### 3.6.3 Combinação entre países (procedimento complementar)

As 74 estimativas $y_c = \hat{b}_c$, com variâncias $v_c = \widehat{\operatorname{Var}}(\hat{b}_c)$ tratadas como conhecidas, foram combinadas por uma **meta-análise de efeitos aleatórios**, com o modelo

$$
y_c = \mu + \delta_c + e_c, \qquad \delta_c \sim N(0, \tau^2), \quad e_c \sim N(0, v_c),
$$

em que $\mu$ é o efeito médio entre sistemas e $\tau^2$ é a variância **real** do efeito entre países, além do erro amostral. A estimação é por momentos. Com pesos $w_c = v_c^{-1}$ e a média ponderada $\hat{\mu}_{\text{F}} = \sum_c w_c y_c/\sum_c w_c$, que é o estimador de mínimos quadrados generalizados sob $\tau^2 = 0$,

$$
Q = \sum_c w_c(y_c - \hat{\mu}_{\text{F}})^2, \qquad
\hat{\tau}^2 = \max\Big\{0,\ \frac{Q - (k-1)}{\sum_c w_c - \sum_c w_c^2/\sum_c w_c}\Big\}.
$$

O estimador de $\hat{\tau}^2$ iguala $Q$ ao seu valor esperado sob o modelo. Em seguida,

$$
\hat{\mu} = \frac{\sum_c w_c^* y_c}{\sum_c w_c^*}, \quad w_c^* = (v_c + \hat{\tau}^2)^{-1}, \qquad \operatorname{EP}(\hat{\mu}) = \Big(\sum_c w_c^*\Big)^{-1/2},
$$

com $k = 74$. Sob homogeneidade ($\tau^2 = 0$), $Q \;\dot\sim\; \chi^2_{k-1}$. A heterogeneidade é resumida por $I^2 = \max\{0, (Q - k + 1)/Q\}$, a fração da variação total das estimativas atribuível a diferenças reais entre países. O intervalo de Wald de $\hat{\mu}$ ignora a incerteza de $\hat{\tau}^2$. Com $k = 74$, esse efeito é pequeno. Além do efeito médio, contou-se em quantos países $|y_c/\sqrt{v_c}| > 1{,}96$, com cada sinal.

#### 3.6.4 Contraste entre países e dentro dos países

Para comparar as duas escalas, estimou-se também a inclinação **entre países**, regredindo $\overline{\text{MAT}}_c$ sobre $\bar{D}_c$ (a proporção de alunos com o comportamento, de 0 a 1) e $\overline{\text{ESCS}}_c$. Os dois coeficientes estão na mesma unidade: pontos de proficiência associados à passagem de 0% para 100% de alunos com o comportamento. Decompondo $D_{ic} = \bar{D}_c + (D_{ic} - \bar{D}_c)$, a inclinação entre países estima a associação com o componente $\bar{D}_c$, que carrega tudo o que distingue os países. A inclinação intrapaís estima a associação com o desvio individual. Ler a primeira como se fosse a segunda é a **falácia ecológica**. A diferença entre as duas mede quanto do contraste entre países se deve a fatores do país, e não do aluno.

### 3.7 Análises de sensibilidade

As escolhas de análise que poderiam alterar as conclusões foram variadas uma a uma:

| Escolha | Alternativa | Comparação |
|---|---|---|
| Amostra da ACP | só os 35 países da OCDE; sem atípicos ($d^2 \leq \chi^2_9(0{,}01)$) | cosseno entre os vetores de coeficientes |
| Correlação | Spearman, em vez de Pearson | cosseno entre os vetores de coeficientes |
| Espaço do agrupamento | 9 variáveis padronizadas, em vez dos $K$ escores | Rand ajustado com a partição original |
| Algoritmo | Ward sem refinamento, contra k-médias | Rand ajustado |
| Regressão | sem atípicos dos resíduos; com indicadora de OCDE | coeficiente da CP2 |

A comparação entre componentes usa o mesmo cosseno do alinhamento bootstrap (Seção 3.3.4), $|\hat{\mathbf{e}}_j'\tilde{\mathbf{e}}|$, em que $\tilde{\mathbf{e}}$ é a componente da análise alternativa mais próxima de $\hat{\mathbf{e}}_j$. O valor 1 indica a mesma direção, e 0, direções ortogonais.

### 3.8 Implementação

A agregação dos microdados foi feita em Python (pandas), e toda a análise, em R base, sem pacotes adicionais, com as funções escritas a partir das fórmulas acima (pasta `R/funcoes/`). Os resultados críticos foram conferidos contra implementações de referência do R (`prcomp`, `anova.mlm`) por asserções `stopifnot`. A semente é 731. O Apêndice A descreve a reprodução.

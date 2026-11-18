-- Filtro Pandoc para o PDF do relatorio:
-- (1) mantem cada figura junto da sua legenda ("**Figura N.** ...");
-- (2) evita que a legenda de uma tabela ("**Tabela N.** ...") fique
--     sozinha no pe da pagina, separada da tabela.

local function comeca_com(bloco, palavra)
  if not bloco or bloco.t ~= "Para" then return false end
  local primeiro = bloco.content[1]
  return primeiro and primeiro.t == "Strong"
    and pandoc.utils.stringify(primeiro):match("^" .. palavra .. " %d+%.") ~= nil
end

local function so_imagem(bloco)
  if not bloco or bloco.t ~= "Para" then return false end
  local n = 0
  for _, el in ipairs(bloco.content) do
    if el.t == "Image" then n = n + 1
    elseif el.t ~= "Space" and el.t ~= "SoftBreak" then return false end
  end
  return n == 1
end

-- linhas a reservar antes de um bloco de abertura (0 = bloco comum)
function reserva(bloco)
  if not bloco then return 0 end
  if bloco.t == "Header" then return bloco.level == 1 and 9 or 7 end
  local so_rotulo = bloco.t == "Para" and #bloco.content == 1 and bloco.content[1].t == "Strong"
  if comeca_com(bloco, "Tabela") or so_rotulo then return 12 end
  return 0
end

function Pandoc(doc)
  local saida, i, b = {}, 1, doc.blocks
  while i <= #b do
    if so_imagem(b[i]) and comeca_com(b[i + 1], "Figura") then
      table.insert(saida, pandoc.RawBlock("latex", "\\begin{figure}[H]\\centering"))
      table.insert(saida, pandoc.Plain(b[i].content))
      table.insert(saida, pandoc.RawBlock("latex", "\\par\\smallskip\\raggedright"))
      table.insert(saida, b[i + 1])
      table.insert(saida, pandoc.RawBlock("latex", "\\end{figure}"))
      i = i + 2
    else
      -- titulos e legendas reservam espaco somado ao dos blocos de abertura
      -- que os seguem, para nunca ficarem sozinhos no pe da pagina
      local linhas, j = 0, i
      while j <= #b and reserva(b[j]) > 0 do
        linhas = linhas + reserva(b[j]); j = j + 1
      end
      if linhas > 0 and (i == 1 or reserva(b[i - 1]) == 0) then
        table.insert(saida, pandoc.RawBlock("latex", "\\needspace{" .. linhas .. "\\baselineskip}"))
      end
      table.insert(saida, b[i])
      i = i + 1
    end
  end
  doc.blocks = saida
  return doc
end

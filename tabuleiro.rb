require_relative "celula.rb"
=begin
 - Lógica para encontrar os vizinhos de um campo (x,y) no tabuleiro:
    (x-1,y-1) (x-1, y) (x-1, y+1)
    (  x,y-1)  (x, y)  (  x, y+1)
    (x+1,y-1) (x+1, y) (x+1, y+1)

  Sendo que quando x == 0 ou x == total_linhas-1, a linha não é considerada, e o mesmo
  acontece para as colunas: y == 0 e y == total_colunas-1

=end
class Tabuleiro
  attr_reader :linhas, :colunas, :campos, :numero_bombas

  def initialize linhas, colunas, bombas
    @linhas = linhas
    @colunas = colunas
    @numero_bombas = bombas
    @campos = Array.new(linhas){ Array.new(colunas){ Celula.new(false) } }

  end

  def preenche_tabuleiro

    # Tratar a quantidade para qnd for meior qu eo numero de campos (m.n) do tabuleiro
    for i in (0...(@numero_bombas)) do
      @campos[rand(@linhas)][rand(@colunas)].bomba = true
    end

    # verifica
    gera_incidencia_bombas
  end

  def gera_incidencia_bombas
    for x in (0...(@linhas)) do
      for y in (0...(@colunas)) do
        # Se o campo (x,y) não for uma bomba, verifica se seus vizinhos são
        if !@campos[x][y].isbomba?
          conta_bombas_adjacentes(x,y)
        end
      end
    end
  end

  def conta_bombas_adjacentes(linha, coluna)
    # Se a linha ou coluna forem as iniciais da matriz (0,y) ou (x,0), os loops são iniciados
    # a partir da linha ou coluna, de modo que não considera a linha (x -1) para x == 0
    lin_inicio = (linha == 0) ? 0 : -1
    col_inicio = (coluna == 0) ? 0 : -1

    # O mesmo do caso acima, mas para as última linha e coluna da matriz
    lin_final = (linha == @linhas-1) ? 0 : 1
    col_final = (coluna == @colunas-1) ? 0 : 1

    for x in ((lin_inicio)..(lin_final)) do
      for y in ((col_inicio)..(col_final)) do
          if @campos[linha + x][coluna + y].isbomba?
            @campos[linha][coluna].vizinhos = @campos[linha][coluna].vizinhos + 1
          end
      end
    end
  end
  
  def verifica_campo (linha, coluna)
    if !(@campos[linha][coluna].isaberto?)
      if @campos[linha][coluna].isbomba?
        puts linha.to_s << " " << coluna.to_s << "" <<" BOMBA!!"
        exit
      elsif @campos[linha][coluna].vizinhos > 0
        @campos[linha][coluna].aberto = true
      else

        ## Se a linha ou coluna forem as iniciais da matriz (0,y) ou (x,0), os loops são iniciados
        # a partir da linha ou coluna, de modo que não considera a linha (x -1) para x == 0
        lin_inicio = (linha == 0) ? 0 : -1
        col_inicio = (coluna == 0) ? 0 : -1

        # O mesmo do caso acima, mas para as última linha e coluna da matriz
        lin_final = (linha == @linhas-1) ? 0 : 1
        col_final = (coluna == @colunas-1) ? 0 : 1

        for x in ((lin_inicio)..(lin_final)) do
          for y in ((col_inicio)..(col_final)) do
            @campos[linha][coluna].aberto = true
            verifica_campo(linha+x, coluna+y)
          end
        end
      end

    end


  end

end #class


a = Tabuleiro.new 8,8,5

a.preenche_tabuleiro

# Imprime a matriz de campos do tabuleiro
for x in (0...(a.linhas)) do
  for y in (0...(a.colunas)) do
    printf a.campos[x][y].to_s << " "
  end
  puts
end


puts "Digite uma posição: "
lin = gets.chomp()
col = gets.chomp()

a.verifica_campo(lin.to_i, col.to_i)
# Imprime a matriz de campos do tabuleiro
for x in (0...(a.linhas)) do
  for y in (0...(a.colunas)) do
      print(a.campos[x][y].aberto.to_s << " ")
  end
  puts
end


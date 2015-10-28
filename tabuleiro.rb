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
  attr_reader :rows, :columns, :numero_bombas, :campos_abertos
  attr_writer :campos_abertos

  def initialize linhas, colunas, bombas
    @rows = linhas
    @columns = colunas
    @numero_bombas = bombas
    @campos = Array.new(linhas){ Array.new(colunas){ Celula.new(false) } }
    @campos_abertos = 0

    @lista_abertos = []

  end

  def get_campo(linha, coluna)
    @campos[linha][coluna]
  end

  def gera_bombas

    # Tratar a quantidade para qnd for meior qu eo numero de campos (m.n) do tabuleiro
    for i in (0...(@numero_bombas)) do
      @campos[rand(@rows)][rand(@columns)].bomba = true
    end

    # verifica
    verifica_vizinhos
  end

  def verifica_vizinhos
    for x in (0...(@rows)) do
      for y in (0...(@columns)) do
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
    lin_final = (linha == @rows-1) ? 0 : 1
    col_final = (coluna == @columns-1) ? 0 : 1

    for x in ((lin_inicio)..(lin_final)) do
      for y in ((col_inicio)..(col_final)) do
          if @campos[linha + x][coluna + y].isbomba?
            @campos[linha][coluna].vizinhos = @campos[linha][coluna].vizinhos + 1
          end
      end
    end
  end
  
  def abre_campo (linha, coluna)
    # Caso o campo ainda não tenha sido clicado
    if !(@campos[linha][coluna].isaberto?)

      # Se for bomba
      if @campos[linha][coluna].isbomba?
        puts " BOMBA!!"
        exit
      # Se conter bombas vizinhas
      elsif @campos[linha][coluna].vizinhos > 0
        @campos[linha][coluna].aberto = true

        @campos_abertos += 1

        #@lista_abertos.push(@campos[linha][coluna])
      else

        @campos_abertos += 1
        @campos[linha][coluna].aberto = true

        ## Se a linha ou coluna forem as iniciais da matriz (0,y) ou (x,0), os loops são iniciados
        # a partir da linha ou coluna, de modo que não considera a linha (x -1) para x == 0
        lin_inicio = (linha == 0) ? 0 : -1
        col_inicio = (coluna == 0) ? 0 : -1

        # O mesmo do caso acima, mas para as última linha e coluna da matriz
        lin_final = (linha == @rows-1) ? 0 : 1
        col_final = (coluna == @columns-1) ? 0 : 1


        for x in ((lin_inicio)..(lin_final)) do
          for y in ((col_inicio)..(col_final)) do
            if !(@campos[linha+x][coluna+y].isaberto?)
              #@lista_abertos.push(@campos[linha][coluna])
              abre_campo(linha+x, coluna+y)
            end
          end
        end
      end

    end


  end

  def verifica_progresso
    (((@rows * @columns) - @campos_abertos) == @numero_bombas)
  end
end #class
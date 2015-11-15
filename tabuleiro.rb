require_relative "celula.rb"

class Tabuleiro
  attr_reader :rows, :columns, :numero_bombas, :campos_abertos, :campos
  attr_writer :campos_abertos

  def initialize linhas, colunas, bombas, widget
    @rows, @columns, @numero_bombas = linhas, colunas, bombas
    @campos = Array.new(linhas){ Array.new(colunas){ Celula.new(false) } }
    @campos_abertos = 0

    gera_bombas(widget)
  end

  def get_campo(linha, coluna)
    @campos[linha][coluna]
  end

  def gera_bombas(widget)
    @bomb_positions = []
    # Tratar a quantidade para qnd for maior que o numero de campos (m.n) do tabuleiro
    for i in (0...@numero_bombas)

      lin = rand(@rows)
      col = rand(@columns)

    while !(@bomb_positions.find_index({:x => lin, :y => col}).nil?) || (lin == widget.get_x && col == widget.get_y)        
        lin = rand(@rows)
        col = rand(@columns)
      end

      @campos[lin][col].bomba = true


      # Adiciona a posição (x,y) da bomba à uma lista
      @bomb_positions << {:x => lin, :y => col}
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

=begin
- Lógica para encontrar os vizinhos de um campo (x,y) no tabuleiro:
    (x-1,y-1) (x-1, y) (x-1, y+1)
    (  x,y-1)  (x, y)  (  x, y+1)
    (x+1,y-1) (x+1, y) (x+1, y+1)

  Sendo que quando x == 0 ou x == total_linhas-1, a linha não é considerada, e o mesmo
  acontece para as colunas: y == 0 e y == total_colunas-1
=end

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
    # Caso o campo ainda não tenha sido aberto
    if !(@campos[linha][coluna].isaberto?)
      # Se for bomba
      if @campos[linha][coluna].isbomba?
        puts " BOMBA!!"
        exit
      elsif @campos[linha][coluna].vizinhos > 0
        @campos[linha][coluna].aberto = true
        @campos_abertos += 1
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
              abre_campo(linha+x, coluna+y)
            end
          end
        end

      end
    end
  end

  # Verifica se os campos restantes são todos bombas, se sim, retorna true
  def is_done?
    return (((@rows * @columns) - @campos_abertos) == @numero_bombas)
  end

  # Retorna informações dos vizinhos de campo no tabuleiro
  # As seguintes informações são retornadas em um array:
  #   posição x, posição y, estado (aberto ou não) e número de vizinhos (caso esteja aberto)
  def get_vizinhos(x,y)
        # Se a linha ou coluna forem as iniciais da matriz (0,y) ou (x,0), os loops são iniciados
    # a partir da linha ou coluna, de modo que não considera a linha (x -1) para x == 0
    lin_inicio = (x == 0) ? 0 : -1
    col_inicio = (y == 0) ? 0 : -1

    # O mesmo do caso acima, mas para as última linha e coluna da matriz
    lin_final = (x == @rows-1) ? 0 : 1
    col_final = (y == @columns-1) ? 0 : 1

    vizinhos = []

    for i in ((lin_inicio)..(lin_final)) do
      for j in ((col_inicio)..(col_final)) do
        if (x+i != x) || (y+j != y)
          campo = get_campo(x+i,y+j)
          numero_vizinhos =  campo.isaberto? ? campo.vizinhos : "-"
          vizinhos.push({:x => x+i,:y => y+j, :aberto => campo.isaberto?, :vizinhos => numero_vizinhos})
        end
      end
    end
    
    vizinhos
  end

  def get_bomb_positions
    @bomb_positions
  end

  def self.get_all_opened(vizinhos)
    count = 0
    vizinhos.each do |campo|
      if(campo[:aberto])
        count += 1
      end
    end
    return count
  end

  def self.get_neighboors_closed(vizinhos)
    list = []
    vizinhos.each do |campo|
      if !(campo[:aberto])
        list << {:x => campo[:x],:y => campo[:y]}
      end
    end

    return list
  end

end #class
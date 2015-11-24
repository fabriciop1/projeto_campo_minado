require_relative 'tabuleiro.rb'
class ArtificialIntelligence

  def initialize (level,tabuleiro = nil)
    @bomb_fields = Array.new(){Hash.new()}
    @tabuleiro = tabuleiro

    probab = @tabuleiro.numero_bombas.to_f() / (@tabuleiro.rows * @tabuleiro.columns)

    @probability_fields = Array.new(@tabuleiro.rows){ Array.new(@tabuleiro.columns){ probab.round(3) } }

    @free_fields = []
    @possible_bombs = []
    @level = level
  end

  def choose_field(tabuleiro = nil)
    @tabuleiro = tabuleiro
    field = Hash.new

    update_lists

    if @level == 1
      field = random_play

    elsif @level == 2
      mark_bombs unless @free_fields.size > 0

      if @free_fields.size > 0
        field = @free_fields[0]
        @free_fields.delete_at(0)
      elsif @possible_bombs.size > 0
        index = rand(0..(@possible_bombs.size-1))
        field = @possible_bombs[index]
        @possible_bombs.delete_at(index)
      else
        field = random_play
      end

    else #level 3
      mark_bombs unless @free_fields.size > 0
      
      if @free_fields.size > 0
        field = @free_fields[0]
        @free_fields.delete_at(0)
      else
        field = calculate_probability()
      end

      for x in (0..(@tabuleiro.rows-1))
        for y in (0..(@tabuleiro.columns-1))
          print("#{@probability_fields[y][x].round(2)} ")
        end
        puts
      end
      p field
    end

    p "Bombas? " << [@bomb_fields].sample.to_s
    p "Livres? " << [@free_fields].sample.to_s
   # p "Possiveis? " << [@possible_bombs].sample.to_s

    return field
  end

=begin
  Method used to choose the fields during the AI`s turn on the level 2`of the game
=end
  def mark_bombs

    for x in 0..(@tabuleiro.rows-1)
      for y in 0..(@tabuleiro.columns-1)
        # Verifica se o campo est� fechado
        if !(@tabuleiro.get_campo(x,y).isaberto?)
          # Captura os neighboors do capo (x,y)
          neighboors = @tabuleiro.get_vizinhos(x,y)

          # Contailiza o numero de neighboors abertos
          neighboors_opened = @tabuleiro.get_neighboors_opened(x,y).size

          # The field is a bomb for sure
          if neighboors_opened == neighboors.size
            # Adiciona a nova coordenada de campo na lista de bombas, se ja existe essa coordenada, ela nao
            # adicionada
            @bomb_fields << {:x => x, :y => y}

          # The field isn`t a bomb, but its neighboors could be
          elsif (neighboors_opened < neighboors.size)
            list_closed = []

            # Verifica os vizinhos fechados e adiciona a uma lista
            neighboors.each do
              |neighboor|

              if (neighboor[:aberto])
                nboor = @tabuleiro.get_vizinhos(neighboor[:x],neighboor[:y])
                nboor_closed = @tabuleiro.get_neighboors_closed(neighboor[:x],neighboor[:y])

                # If the number of close neighboors is equal to the number of bombs around the field
                if(nboor_closed.size == neighboor[:vizinhos])
                  @bomb_fields << nboor_closed
                  @bomb_fields.flatten!.uniq!
                else
                  cont = 0
                  free_fields = []

                  # Search the fields that are known as bombs
                  nboor_closed.each do
                    |field|
                    if !(@bomb_fields.find_index({:x => field[:x], :y => field[:y]}).nil?)
                      cont += 1
                    else
                      if !(@tabuleiro.get_campo(field[:x],field[:y]).isaberto?)
                        free_fields << {:x => field[:x],:y => field[:y]}
                      end

                    end
                  end

                  if neighboor[:vizinhos] == cont
                    @free_fields << free_fields
                    @free_fields.flatten!.uniq!

                    # Delete if the field is in the possible bombs list
                    @possible_bombs.delete_if do |field|
                      @free_fields.include?(field)
                    end
                  else
                    @possible_bombs << free_fields
                    @possible_bombs.flatten!.uniq!
                  end

                end

              end
            end
          end

        end
      end
    end

  end

  def random_play
    linha = rand(0..(@tabuleiro.rows-1))
    coluna = rand(0..(@tabuleiro.columns-1))

    while @tabuleiro.get_campo(linha, coluna).isaberto?
      linha = rand(0..(@tabuleiro.rows-1))
      coluna = rand(0..(@tabuleiro.columns-1))
    end

    return {:x => linha, :y => coluna}
  end

  def update_lists
    @free_fields.delete_if do |field|
      @tabuleiro.get_campo(field[:x], field[:y]).isaberto?
    end
    @possible_bombs.delete_if do |field|
      @tabuleiro.get_campo(field[:x], field[:y]).isaberto?
    end
  end
  
  # define the 3rd level of the artificial intelligence, where random plays are avoided 
  def calculate_probability()
    for i in 0..(@tabuleiro.rows-1)
      for j in 0..(@tabuleiro.columns-1)

        if @tabuleiro.get_campo(i,j).isaberto?
          @probability_fields[i][j] = 0.0
        else

          neighboors = @tabuleiro.get_vizinhos(i,j)

          # Identify if the neighboor is the first one used in the calcs
          first = true

          # for each of the neighboors of the field being verified
          neighboors.each do |field|
            if @tabuleiro.get_campo(field[:x],field[:y]).isaberto?

              number_closed = @tabuleiro.get_neighboors_closed(field[:x],field[:y]).size

              if number_closed > 0

                # calculate the probability of the field according to its neighboors
                probability = @tabuleiro.get_campo(field[:x],field[:y]).vizinhos.to_f() / number_closed

                # If the neighboor is the first one verified
                if first
                  @probability_fields[i][j] = probability
                  first = false
                else
                  # if it`s not he first one, calculates the formula: probability of the union of n events
                  @probability_fields[i][j] = (@probability_fields[i][j] + probability) - (probability * @probability_fields[i][j])
                end

                # break the loop if the probability calculated is 1 or zero
                break if (@probability_fields[i][j] == 1.0) || (@probability_fields[i][j] == 0.0)
              end
            end

          end
        end
        
      end
    end

    # (Re)calcula a probabilidade para os campos fechados que não possuem nenhum vizinho aberto,
    # assi, dependendo do número de bombas já descobertass e as que faltam
    for i in 0..(@tabuleiro.rows-1)
      for j in 0..(@tabuleiro.columns-1)
        field = @tabuleiro.get_campo(i,j)
        if @tabuleiro.get_neighboors_opened(i,j).size == 0
          @probability_fields[i][j] = (@tabuleiro.numero_bombas - @bomb_fields.size).to_f() / @tabuleiro.get_number_closed()
        end
      end
    end

    get_smaller_probability
  end

  # Sort the probability matrix and get the field with the smaller change of being a bomb
  def get_smaller_probability
    smaller_value = Float::MAX
    coord_field = Hash.new
    for i in 0..(@tabuleiro.rows-1)
      for j in 0..(@tabuleiro.columns-1)
        if (@probability_fields[i][j] < smaller_value) &&
            (@probability_fields[i][j] != 1.0) && (@probability_fields[i][j] != 0.0) &&
            !(@tabuleiro.get_campo(i,j).isaberto?)
                smaller_value = @probability_fields[i][j]
                coord_field = {:x => i, :y => j}
        end
      end
    end

    coord_field
  end
  
end #class
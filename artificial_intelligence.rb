require_relative 'tabuleiro.rb'
class ArtificialIntelligence

  def initialize (level,tabuleiro = nil)
    @bomb_fields = Array.new(){Hash.new()}
    @free_fields = []
    @possible_bombs = []
    @level = level
    @tabuleiro = tabuleiro
  end

  def choose_field(tabuleiro = nil)
    @tabuleiro = tabuleiro
    field = Hash.new

    update_lists

    if @level == 1
      field = random_play
    elsif @level == 2
      mark_bombs

      if @free_fields.size > 0
        field = @free_fields[0]
        @free_fields.delete_at(0)
      elsif @possible_bombs.size > 0
        index = rand(0..(@possible_bombs.size-1))
        field = @possible_bombs[index]
        @possible_bombs.delete_at(index)
      else
        p "RANDOMMM"
        field = random_play
      end
    else

    end
    p "Bombas? " << [@bomb_fields].sample.to_s
    p "Livres? " << [@free_fields].sample.to_s
    p "Possiveis? " << [@possible_bombs].sample.to_s

    field
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
          neighboors_opened = Tabuleiro.get_all_opened(neighboors)

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
                nboor_closed = Tabuleiro.get_neighboors_closed(nboor)

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


   # printt
  end

  def random_play
    linha = rand(0..(@tabuleiro.rows-1))
    coluna = rand(0..(@tabuleiro.columns-1))

    while @tabuleiro.get_campo(linha, coluna).isaberto?
      linha = rand(0..(@tabuleiro.rows-1))
      coluna = rand(0..(@tabuleiro.columns-1))
    end

    {:x => linha, :y => coluna}
  end

  def printt
    @bomb_fields.each do |a|
      puts "Array: " << a.to_s
    end
  end

  def update_lists
    @free_fields.delete_if do |field|
      @tabuleiro.get_campo(field[:x], field[:y]).isaberto?
    end
    @possible_bombs.delete_if do |field|
      @tabuleiro.get_campo(field[:x], field[:y]).isaberto?
    end
  end
end #class
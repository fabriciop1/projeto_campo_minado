require 'gtk3'
=begin
 Classe herdade da classe Gtk::Button para uso no tabuleiro do jogo
=end


module Board
  class SpaceField < Gtk::Button

    #Iniciatliza os botões
    def initialize()
      super()
      @x = nil
      @y = nil
    end

    #  - x = posicao x do grid
    #  - y = posicao y do grid

    def set_x x
      @x = x
    end

    def get_x
      return @x
    end

    def set_y y
      @y = y
    end

    def get_y
      return @y
    end

  end
end
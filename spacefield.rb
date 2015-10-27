require 'gtk3'
=begin
 Classe herdade da classe Gtk::Button para uso no tabuleiro do jogo
=end


module Board
  class SpaceField < Gtk::Button
    type_register

    def initialize label
      super("label" => label.to_s)
      @x = nil
      @y = nil
    end

    # Define as novas propriedades para o button, no caso:
    #  - x = posição x do grid
    #  - y = posição y do grid

    install_property(GLib::Param::Int.new("x", # name
                                          "PosX", # nick
                                          "", # blurb
                                          0, # min
                                          100, # max
                                          0, # default
                                          GLib::Param::READABLE |
                                              GLib::Param::WRITABLE))

    install_property(GLib::Param::Int.new("y", # name
                                          "PosY", # nick
                                          "", # blurb
                                          0, # min
                                          100, # max
                                          0, # default
                                          GLib::Param::READABLE |
                                              GLib::Param::WRITABLE))

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
require 'gtk3'
require_relative 'spacefield'

class CampoMinadoApp < Gtk::Window

  def initialize
    super
    @rows = 8
    @columns = 8

    @bombs = Array.new(@rows) { Array.new(@columns) { [true, false].sample } }

    set_title "Celula Minado"
    set_window_position(:center)
    set_border_width 15

    signal_connect("destroy") { Gtk.main_quit }

    make_screen
    show_all
  end

  def make_screen
    #wrapper = Gtk::Grid.new
    vbox = Gtk::Box.new(:vertical, 1)
    hbox_newgame = Gtk::Box.new(:horizontal, 1)
    separator = Gtk::Separator.new(:horizontal)

    @newGame = Gtk::Button.new
    @newGame.set_size_request 40, 40
    @board = Gtk::Grid.new

    # Garante que todas as linhas e colunas possuam o mesmo tamanho
    @board.set_property "row-homogeneous", true
    @board.set_property "column-homogeneous", true

    # Adiciona uma imagem ao botão
    @iconNewGame = Gtk::Image.new(:file => "img/smile.png")
    @iconBomb = Gtk::Image.new(:file => "img/bomb2.png")
    @newGame.add Gtk::Box.new(:horizontal, 0).pack_start(@iconNewGame, :expand => false, :fill => true, :padding => 0)


    # Preencha a matriz "field" com botões e a incorpora ao tabuleiro "board"
    for x in 0..(@rows-1)
      for y in 0..(@columns-1)
        field = Board::SpaceField.new(@bombs[x][y] ? "" : " ")
        field.set_x x
        field.set_y y
        field.set_size_request 40, 40
        @bombs[x][y] = @bombs[x][y]

        @board.attach field, x, y, 1, 1

        field.signal_connect("clicked") {
            |_widget|
              if @bombs[_widget.get_x][_widget.get_y]
                @iconNewGame.file = "img/lose.png"
                #lb = Gtk::Label.new("Tst")
                @board.attach @iconBomb, _widget.get_x, _widget.get_y, 1,1
                @iconBomb.show
                #lb.add
                 _widget.hide()


                @board.set_sensitive(false)
                #_widget.set_sensitive(false)

              else
                @iconNewGame.file = "img/live_one_day_more.png"
              end
        }


      end
    end

    hbox_newgame.add @newGame

    halign = Gtk::Alignment.new 1, 1, 0, 1
    halign.add hbox_newgame


    vbox.pack_start(halign, :expand => false, :fill => true, :padding => 5)
    vbox.pack_start(separator, :expand => false, :fill => true, :padding => 5)
    vbox.pack_start(@board, :expand => true, :fill => true, :padding => 0)

    # Adiciona o tabuleiro na janela
    add vbox


  end

  def load_image(file)
    pixbuf = Gdk::Pixbuf.new file
    pixmap, mask = pixbuf.render_pixmap_and_mask
    image = Gtk::Pixmap.new(pixmap, mask)
  end
end

window = CampoMinadoApp.new
Gtk.main
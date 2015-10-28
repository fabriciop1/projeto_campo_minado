require 'gtk3'
require_relative 'spacefield'
require_relative 'tabuleiro'

class CampoMinadoApp < Gtk::Window

  # Constantes que armazenam as imagens utilziadas pelo jogo
  SMILE_IMG = "img/smile.png"
  BOMB_IMG = "img/bomb3.png"
  LOSE_IMG = "img/lose.png"
  MISSED_BOMB_IMG = "img/live_one_day_more.png"

  def initialize(linhas,colunas,bombas)
    super()
    init_game(linhas,colunas,bombas)

    set_title "Campo Minado"
    set_window_position(:center)
    #set_decorated(false)
    set_border_width 10
    signal_connect("destroy") { Gtk.main_quit }

    make_screen
    show_all
  end

  def init_game(linhas, colunas, bombas)
    @rows = linhas
    @columns = colunas
    @bombas = bombas
    @campos_abertos = 0

    # Matriz de bot�es do campo minado
    @field = Array.new(linhas){ Array.new(colunas) {Board::SpaceField.new('')}}

    @tabuleiro = Tabuleiro.new(linhas, colunas, bombas)
    @tabuleiro.gera_bombas
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

    # Adiciona uma imagem ao bot�o
    @iconNewGame = Gtk::Image.new(:file => SMILE_IMG)
    @iconBomb = Gtk::Image.new(:file => BOMB_IMG)
    @newGame.add Gtk::Box.new(:horizontal, 0).pack_start(@iconNewGame, :expand => false, :fill => true, :padding => 0)


    # Preencha a matriz "field" com bot�es e a incorpora ao tabuleiro "board"
    for x in 0..(@rows-1)
      for y in 0..(@columns-1)
        @field[x][y].set_x x
        @field[x][y].set_y y
        @field[x][y].set_size_request 40, 40

        # Anexa o bot�o (campo) ao tabuleiro (board) na posi��o (x,y)
        @board.attach @field[x][y], x, y, 1, 1

        # Cria o evento para quando o campo for clicado
        @field[x][y].signal_connect("clicked") {
            |_widget|
            campo_clicado(_widget)
        }

      end
    end

    lbl_bombas = Gtk::Label.new
    lbl_bombas.set_markup("<span foreground='gray' size='xx-large' weight='bold'>" << ( (@bombas < 10) ? "00" << @bombas.to_s : "0" << @bombas.to_s ) << "</span>")


    hbox_newgame.pack_start(@newGame, :expand => false, :fill => true, :padding => 5)

    # Alinha o bot�o do lado direito
    halign = Gtk::Alignment.new 1, 1, 0, 1
    halign.add hbox_newgame

    # Empilha na caixa vertical os elementos criados
    vbox.pack_start(menu, :expand => false, :fill => true, :padding => 0)
    vbox.pack_start(halign, :expand => false, :fill => true, :padding => 5)
    vbox.pack_start(separator, :expand => false, :fill => true, :padding => 5)
    vbox.pack_start(@board, :expand => false, :fill => false, :padding => 0)

    # Adiciona o tabuleiro na janela
    fixed = Gtk::Fixed.new
    fixed.put lbl_bombas, 12,41
    fixed.put vbox, 0,0

    img = Gtk::Image.new(:file => "img/pontos_bg.png")
    fixed.put img, 2,30
    add fixed
    #add vbox

  end

  def menu
    mb = Gtk::MenuBar.new

    filemenu = Gtk::Menu.new
    filem = Gtk::MenuItem.new "File"
    filem.set_submenu filemenu

    exit = Gtk::MenuItem.new "Exit"
    exit.signal_connect "activate" do
      Gtk.main_quit
    end


    sep = Gtk::SeparatorMenuItem.new

    filemenu.append sep
    filemenu.append exit

    mb.append filem

    return mb

  end

  def campo_clicado(_widget)
    # O campo clicado � uma bomba?
    if @tabuleiro.get_campo(_widget.get_x,_widget.get_y).isbomba?

      @iconNewGame.file = LOSE_IMG
      #lb = Gtk::Label.new("Tst")
      @board.attach @iconBomb, _widget.get_x, _widget.get_y, 1,1
      _widget.hide()
      @iconBomb.show

      @board.set_sensitive(false)
      #_widget.set_sensitive(false)

      #message = Gtk::MessageDialog.new(:parent => self, :flags => :destroy_with_parent,
      #                      :type => :info, :buttons_type => :close,
      #                      :message => "Você perdeu =(")
      #                    message.show_all

    else

      @iconNewGame.file = MISSED_BOMB_IMG

      @tabuleiro.abre_campo(_widget.get_x,_widget.get_y)

      for i in 0..(@rows-1)
        for j in 0..(@columns-1)
          campo = @tabuleiro.get_campo(i,j)

          if campo.isaberto?
            @field[i][j].hide()
            label = Gtk::Label.new #(:label => ((tabuleiro.vizinhos == 0) ? "<large>5</large> " : tabuleiro.vizinhos.to_s))
            vizinhos = (campo.vizinhos == 0) ? " - " : campo.vizinhos.to_s
            label.set_markup("<span foreground='blue' size='large'>" << (vizinhos) << "</span>")

            @board.attach label, i, j, 1,1
            label.show

          end
        end
      end

      # Verifica o numero de bombas restantes e diz se o player ganhou
      verifica_progresso

    end # else
  end

  def verifica_progresso
    msg = "Sortudo! Voce conseguiu sobreviver"

    if(@tabuleiro.verifica_progresso)
      message = Gtk::MessageDialog.new(:parent => self, :flags => :destroy_with_parent,
                                       :type => :info, :buttons_type => :close,
                                       :message => msg)


      message.run
      message.destroy

      @board.set_sensitive(false)
    end
  end


  def load_image(file)
    pixbuf = Gdk::Pixbuf.new file
    pixmap, mask = pixbuf.render_pixmap_and_mask
    image = Gtk::Pixmap.new(pixmap, mask)
  end

end


window = CampoMinadoApp.new(10,10,5)

Gtk.main
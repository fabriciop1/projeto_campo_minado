require 'gtk3'
require_relative 'spacefield'
require_relative 'tabuleiro'

class CampoMinadoApp < Gtk::Window

  # Constantes que armazenam as imagens utilziadas pelo jogo
  SMILE_IMG = "img/smile.png"
  BOMB_IMG = "img/bomb3.png"
  LOSE_IMG = "img/lose-dimas.png"
  MISSED_BOMB_IMG = "img/live_one_day_more.png"

  PLAYER_MACHINE = "Mr. Robot"

  def initialize(linhas,colunas,bombas)
    super()

    init_game(linhas,colunas,bombas)

    set_title "Campo Minado"
    set_window_position(:center)
    set_border_width 15

    signal_connect("destroy") { Gtk.main_quit }

    make_screen
    show_all
    timer
  end

  def init_game(linhas, colunas, bombas)
    #@time = 0
    @rows = linhas
    @columns = colunas
    @bombas = bombas
    @campos_abertos = 0

    # Matriz de bot�es do campo minado
    @field = Array.new(linhas){ Array.new(colunas) {Board::SpaceField.new('')}}
    @label = Array.new(linhas){ Array.new(colunas) {}}

    @tabuleiro = Tabuleiro.new(linhas, colunas, bombas)
    @sensitive = true
    @activatedLevel = 1
  end

  def make_screen
    #wrapper = Gtk::Grid.new
    vbox = Gtk::Box.new(:vertical, 1)
    hbox_newgame = Gtk::Box.new(:horizontal, 1)
    separator = Gtk::Separator.new(:horizontal)
    #Cria o menu para escolha de níveis
    mb = Gtk::MenuBar.new
    levelmenu = Gtk::Menu.new
    level1 = Gtk::MenuItem.new("Nível 1")
    level2 = Gtk::MenuItem.new("Nível 2")
    level3 = Gtk::MenuItem.new("Nível 3")
    levels = Gtk::MenuItem.new("Níveis")

    levelmenu.append(level1)
    levelmenu.append(level2)
    levelmenu.append(level3)

    levels.set_submenu(levelmenu)

    mb.append(levels)

    # Adicionando uma tool bar de status, para informar quando o player máquina está "pensando"
    @lbl_player = Gtk::Label.new
    toolbar = Gtk::Toolbar.new
    tl_item = Gtk::ToolItem.new
    tl_item.add @lbl_player
    toolbar.insert(tl_item, 0)


    @newGame = Gtk::Button.new
    @newGame.set_size_request 40, 40

    @board = Gtk::Grid.new
    # Garante que todas as linhas e colunas possuam o mesmo tamanho
    @board.set_property "row-homogeneous", true
    @board.set_property "column-homogeneous", true

    # Adiciona uma imagem ao bot�o
    @iconNewGame = Gtk::Image.new(:file => SMILE_IMG)
    @iconBomb = Gtk::Image.new(:file => BOMB_IMG)

    @newGame.add @iconNewGame #Gtk::Box.new(:horizontal, 0).pack_start(@iconNewGame, :expand => false, :fill => true, :padding => 0)

    # Iniciar novo jogo caso o botão Dimas seja clicado
    @newGame.signal_connect("clicked") {|widget| reset_board }


    level1.signal_connect("activate") do
      @activatedLevel = 1
    end
    level2.signal_connect("activate") do 
      @activatedLevel = 2
    end
           
    level3.signal_connect("activate") do
      @activatedLevel = 3
    end

    # Desenha o tabuleiro na janela
    draw_board()

    hbox_newgame.add @newGame
    # Alinha o botao do lado direito
    halign = Gtk::Alignment.new 0.5, 1, 0, 0
    halign.add hbox_newgame

    @lbl_timer = Gtk::Label.new
    @lbl_timer.set_markup("<span foreground='gray' size='xx-large' weight='bold'> 000</span>")

    halign1 = Gtk::Alignment.new 1, 1, 0, 1
    halign1.add @lbl_timer

    hb = Gtk::Box.new(:horizontal, 1)
    hb.pack_start(halign, :expand => false, :fill => false, :padding => 0)
    hb.pack_start(halign1, :expand => true, :fill => true, :padding => 0)

    # Empilha na caixa vertical os elementos criados
    vbox.pack_start(mb, :expand => false, :fill => false, :padding => 0)
    vbox.pack_start(hb, :expand => true, :fill => true, :padding => 0)
    #vbox.pack_start(halign1, :expand => false, :fill => false, :padding => 0)
    vbox.pack_start(Gtk::Separator.new(:horizontal), :expand => false, :fill => true, :padding => 5)
    vbox.pack_start(@board, :expand => false, :fill => false, :padding => 0)
    vbox.pack_start(Gtk::Separator.new(:horizontal), :expand => false, :fill => true, :padding => 5)
    vbox.pack_start(toolbar, :expand => true, :fill => true, :padding => 3)

    lbl_bombas = Gtk::Label.new
    lbl_bombas.set_markup("<span foreground='gray' size='xx-large' weight='bold'>" << ( (@bombas < 10) ? "00" << @bombas.to_s : "0" << @bombas.to_s ) << "</span>")

   # fixed = Gtk::Fixed.new
   # fixed.put @lbl_timer, 12,43

    # Adiciona o tabuleiro na janela
    #fixed.put vbox, 0,0
    #wrap_lbl_bombas = Gtk::Image.new(:file => "img/pontos_bg.png")
    #fixed.put wrap_lbl_bombas, 2,33

    # add fixed
    add vbox
  end

  def draw_board()
    # Preencha a matriz "field" com bot�es e a incorpora ao tabuleiro "board"
    for x in 0..(@rows-1)
      for y in 0..(@columns-1)

        @field[x][y].set_x(x)
        @field[x][y].set_y(y)
        @field[x][y].set_size_request(40, 40)

        # Anexa o botao (campo) ao tabuleiro (board) na posicao (x,y)
        @board.attach @field[x][y], x, y, 1, 1

        # Cria o evento para quando o campo for clicado
        @field[x][y].signal_connect("clicked") {
            |_widget|

          perdeu = campo_clicado(_widget)

          if !perdeu
            player_ia = Thread.new {
              change_lbl_player("#{PLAYER_MACHINE} está pensando...")
              sleep(1)

              if(@activatedLevel == 1)
                random_play #IA parte 1
              elsif(@activatedLevel == 2)

              else

              end

            }
          end

        } #signal_connect

      end
    end
  end

  def campo_clicado(_widget)
    # O campo clicado e uma bomba?
    if @tabuleiro.get_campo(_widget.get_x,_widget.get_y).isbomba?

      @timer.terminate

      @iconNewGame.file = LOSE_IMG
      #lb = Gtk::Label.new("Tst")
      @board.attach @iconBomb, _widget.get_x, _widget.get_y, 1,1
      _widget.hide()
      @iconBomb.show

      @board.set_sensitive(false)
      @sensitive = false
      #_widget.set_sensitive(false)


      get_message("Você perdeu!")
      change_lbl_player("Mr. Robot: Desculpe, mas é... ganhei!")
      return true
    else

      @iconNewGame.file = MISSED_BOMB_IMG

      @tabuleiro.abre_campo(_widget.get_x,_widget.get_y)
      
      abre_vizinhos("user")
    end # else

    false
  end

  def abre_vizinhos (player)
    if(player == "user")
      color = "blue"
    else
      color = "red"
    end
    for i in 0..(@rows-1)
      for j in 0..(@columns-1)
        tabuleiro = @tabuleiro.get_campo(i,j)

        if tabuleiro.isaberto?
          @field[i][j].hide()
          @label[i][j] = Gtk::Label.new #(:label => ((tabuleiro.vizinhos == 0) ? "<large>5</large> " : tabuleiro.vizinhos.to_s))
          vizinhos = (tabuleiro.vizinhos == 0) ? " - " : tabuleiro.vizinhos.to_s
          @label[i][j].set_markup("<span foreground='"<< color << "' size='large'>" << (vizinhos) << "</span>")
    
          @board.attach @label[i][j], i, j, 1,1
          @label[i][j].show
        end
        verifica_progresso
      end
    end
  end

  def verifica_progresso
    if @tabuleiro.is_done?
      get_message("Você conseguiu sobreviver!")
      @board.set_sensitive(false)
      @sensitive = false
    end
  end


  def get_message(message)
    GLib::Idle.add do
      message = Gtk::MessageDialog.new(:parent => self, :flags => :destroy_with_parent,
                                       :type => :info, :buttons_type => :close,
                                       :message => "#{message}")
      message.run
      message.destroy
      false
    end
  end
 
=begin
 Method that corresponds to the AI part I of the game (random choices of places to play)
=end
  def random_play
    if (@sensitive)
      linha = rand(@rows)
      coluna = rand(@columns)

      if !(@tabuleiro.get_campo(linha,coluna).isaberto?)

        if !(@tabuleiro.get_campo(linha,coluna).isbomba?)

          @tabuleiro.abre_campo(linha,coluna)
          abre_vizinhos("AI")
          change_lbl_player("Mr. Robot: Sua vez... Mr. HowYouDareChallengeMr.Robot?")

        else

          @timer.terminate

          @iconNewGame.file = LOSE_IMG
          @board.attach @iconBomb, linha, coluna, 1,1
          @iconBomb.show
          @board.set_sensitive(false)
          @sensitive = false
          @field[linha][coluna].hide()

          change_lbl_player("Mr. Robot: Isso foi apenas sorte sua, não vá se achando")
          get_message("Nível 1: IA perdeu!")
        end
      else
        random_play
      end
    end

  end

  def change_lbl_player (msg)
    GLib::Idle.add do
      @lbl_player.label = msg
    false
  end

  end

  def reset_board
    @timer.terminate
    @lbl_timer.label = "<span foreground='gray' size='xx-large' weight='bold'>00:00</span>"

    @tabuleiro = Tabuleiro.new(@rows, @columns, @bombas)
    @sensitive = true
    @iconNewGame.file = SMILE_IMG

    @board.set_sensitive(true)

    for x in 0..(@rows-1)
      for y in 0..(@columns-1)
        if !@field[x][y].visible?
          @field[x][y].show
        end
        if @label[x][y].class.to_s == "Gtk::Label"
          @label[x][y].set_markup("")
        end

      end
    end

    timer
  end

  def timer
    seg = 0
    min = 0
    @timer = Thread.new{
      while true
        seg = (seg < 10) ? ("0" << seg.to_s) : seg
        if(seg.to_i > 59)
          seg = "00"
          min = min.to_i + 1
        end

        min = (min.to_i < 10) ? ("0" << min.to_i.to_s) : min.to_i

        @lbl_timer.label = "<span foreground='gray' size='xx-large' weight='bold'>#{min}:#{seg}</span>"

        seg = seg.to_i + 1
        sleep(1)
      end
    }

    #@timer.join

  end

  def load_image(file)
    pixbuf = Gdk::Pixbuf.new file
    pixmap, mask = pixbuf.render_pixmap_and_mask
    image = Gtk::Pixmap.new(pixmap, mask)
  end
end

window = CampoMinadoApp.new(10,10,22)

Gtk.main
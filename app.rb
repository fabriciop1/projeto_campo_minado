require 'gtk3'
require_relative 'spacefield'
require_relative 'tabuleiro'
require_relative 'random'

class CampoMinadoApp < Gtk::Window

  # Constantes que armazenam as imagens utilziadas pelo jogo
  SMILE_IMG = "img/smile.png"
  BOMB_IMG = "img/bomb2.png"
  LOSE_IMG = "img/lose.png"
  MISSED_BOMB_IMG = "img/live_one_day_more.png"

  def initialize(linhas,colunas,bombas)
    super()

    init_game(linhas,colunas,bombas)

    set_title "Campo Minado"
    set_window_position(:center)
    set_border_width 15

    signal_connect("destroy") { Gtk.main_quit }

    make_screen
    show_all
  end

  def init_game(linhas, colunas, bombas)
    #@time = 0
    @rows = linhas
    @columns = colunas
    @bombas = bombas
    @campos_abertos = 0

    # Matriz de bot�es do campo minado
    @field = Array.new(linhas){ Array.new(colunas) {Board::SpaceField.new('')}}

    @tabuleiro = Tabuleiro.new(linhas, colunas, bombas)
    @tabuleiro.gera_bombas
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

    # Iniciar novo jogo caso o botão Dimas seja clicado
   # @newGame.signal_connect("clicked") do |widget|
   #   print widget
   # end

    level1.signal_connect("activate") do
      @activatedLevel = 1
    end
    level2.signal_connect("activate") do 
      @activatedLevel = 2
    end
           
    level3.signal_connect("activate") do
      @activatedLevel = 3
    end
    
    # Preencha a matriz "field" com bot�es e a incorpora ao tabuleiro "board"
    for x in 0..(@rows-1)
      for y in 0..(@columns-1)
        @field[x][y].set_x(x)
        @field[x][y].set_y(y)
        @field[x][y].set_size_request(40, 40)

        # Anexa o bot�o (campo) ao tabuleiro (board) na posi��o (x,y)
        @board.attach @field[x][y], x, y, 1, 1
        
        # Cria o evento para quando o campo for clicado
        @field[x][y].signal_connect("clicked") {
            |_widget|
            campo_clicado(_widget)
            if(@activatedLevel == 1)
                random_play #IA parte 1
            elsif(@activatedLevel == 2) 
              
            else 
              
            end
           
        }

      end
    end


    hbox_newgame.add @newGame
    # Alinha o bot�o do lado direito
    halign = Gtk::Alignment.new 0.5, 1, 0, 0
    halign.add hbox_newgame

    # Empilha na caixa vertical os elementos criados
    vbox.pack_start(mb, :expand => false, :fill => false, :padding => 0)  
    vbox.pack_start(halign, :expand => false, :fill => true, :padding => 5)
    vbox.pack_start(separator, :expand => false, :fill => true, :padding => 5)
    vbox.pack_start(@board, :expand => false, :fill => false, :padding => 0)

    # Adiciona o tabuleiro na janela
    add vbox


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
      @sensitive = false
      #_widget.set_sensitive(false)

      get_message("Você perdeu!")

    else

      @iconNewGame.file = MISSED_BOMB_IMG

      @tabuleiro.abre_campo(_widget.get_x,_widget.get_y)
      
      abre_vizinhos
    end # else
    
  end

  def abre_vizinhos
    for i in 0..(@rows-1)
      for j in 0..(@columns-1)
        tabuleiro = @tabuleiro.get_campo(i,j)
    
          if tabuleiro.isaberto?
            @field[i][j].hide()
            label = Gtk::Label.new #(:label => ((tabuleiro.vizinhos == 0) ? "<large>5</large> " : tabuleiro.vizinhos.to_s))
            vizinhos = (tabuleiro.vizinhos == 0) ? " " : tabuleiro.vizinhos.to_s
            label.set_markup("<span foreground='blue' size='large'>" << (vizinhos) << "</span>")
    
           @board.attach label, i, j, 1,1
           label.show
           @campos_abertos += 1
          end
          verifica_progresso
      end
    end
    @campos_abertos = 0
  end

  def verifica_progresso
    if(((@rows*@columns) - @campos_abertos) == @bombas)
      get_message("Você conseguiu sobreviver!")
      @board.set_sensitive(false)
      @sensitive = false
    end
  end

  def load_image(file)
    pixbuf = Gdk::Pixbuf.new file
    pixmap, mask = pixbuf.render_pixmap_and_mask
    image = Gtk::Pixmap.new(pixmap, mask)
  end

 def get_message(message)
   message = Gtk::MessageDialog.new(:parent => self, :flags => :destroy_with_parent,
                                                  :type => :info, :buttons_type => :close,
                                                  :message => "#{message}")
   message.run
   message.destroy
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
          abre_vizinhos
        else
          @iconNewGame.file = LOSE_IMG
          @board.attach @iconBomb, linha, coluna, 1,1
          @iconBomb.show
          @board.set_sensitive(false)
          @sensitive = false
          @field[linha][coluna].hide()
          get_message("Nível 1: IA perdeu!")
        end
      else
        random_play
      end
   end
 end
end

window = CampoMinadoApp.new(7,7, 6)

Gtk.main
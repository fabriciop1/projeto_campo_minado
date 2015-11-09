require 'gtk3'
#require "win32/sound"
require_relative 'spacefield'
require_relative 'tabuleiro'

#include Win32

class CampoMinadoApp < Gtk::Window

  # Constantes que armazenam as imagens utilziadas pelo jogo
  SMILE_IMG = "img/smile.png"
  BOMB_IMG = "img/bomb3.png"
  BOMB_QUESTION_IMG = "img/bomb_question.png"
  LOSE_IMG = "img/lose-dimas.png"
  LOSE_AI_IMG = "img/lose.png"
  MISSED_BOMB_IMG = "img/live_one_day_more.png"

  PLAYER_MACHINE = "Estudante de PLP"

  def initialize(linhas,colunas, pai)
    super()
    @parent = pai

    # Gera um número aleatório de bombas, entre 1/3 e 1/2 do número total de casas
    bombas = rand( Integer((linhas*colunas)/4) .. Integer((linhas*colunas)/3) )
    
    init_game(linhas,colunas,bombas)

    set_title "Campo Minado"
    set_window_position(:center)
    set_border_width 1
    set_icon("img/bomb2.png")
    self.resizable = (false)

    signal_connect("destroy"){
      Gtk.main_quit
      #destroy
     # @parent.show
    }
    override_background_color :normal, Gdk::RGBA::new(1,1,1,1)
    make_screen
    @AI = ArtificialIntelligence.new(2,@tabuleiro)

    show_all
    timer

  end

  def init_game(linhas, colunas, bombas)
    @rows, @columns, @bombas= linhas, colunas, bombas
    @marked_bombs = 0

    # Matriz de bot�es do campo minado
    @field = Array.new(linhas){ Array.new(colunas) {Board::SpaceField.new('')}}
    @label = Array.new(linhas){ Array.new(colunas) {}}

    @tabuleiro = Tabuleiro.new(linhas, colunas, bombas)
    @activatedLevel = 1
  end

  def make_screen

    #Cria o menu para escolha de níveis
    mb = Gtk::MenuBar.new
    levelmenu = Gtk::Menu.new
    levels = Gtk::MenuItem.new("Jogo")

    novo_jogo = Gtk::MenuItem.new("Novo")
    novo_jogo.signal_connect("activate"){
      window.destroy
      set_modal(false)
      @parent.show

    }

    level1 = Gtk::MenuItem.new("Nível 1")
    level2 = Gtk::MenuItem.new("Nível 2")
    level3 = Gtk::MenuItem.new("Nível 3")

    #levelmenu.append(level1)
    #levelmenu.append(level2)
    #levelmenu.append(level3)
    levelmenu.append(novo_jogo)

    levels.set_submenu(levelmenu)

    levelmenu.append Gtk::SeparatorMenuItem.new

    exit_btn = Gtk::MenuItem.new "Sair"
    exit_btn.signal_connect("activate"){ Gtk.main_quit }

    levelmenu.append exit_btn

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
    @board.set_column_spacing 3
    @board.set_row_spacing 3
    @board.set_row_homogeneous true
    @board.set_column_homogeneous true

    # Adiciona uma imagem ao bot�o
    @iconNewGame = Gtk::Image.new(:file => SMILE_IMG)
    @iconBomb = Gtk::Image.new(:file => BOMB_IMG)

    @newGame.add @iconNewGame #Gtk::Box.new(:horizontal, 0)..pack_start(button1, :expand => false, :fill => true, :padding => 0)

    # Iniciar novo jogo caso o botão Dimas seja clicado
    @newGame.signal_connect("clicked") {|widget| reset_board }

    verify_level(level1, level2, level3)

    # Desenha o tabuleiro na janela
    draw_board()

    # Box horizontal par ao botão de novo jogo
    hbox_newgame = Gtk::Box.new(:horizontal, 1)
    hbox_newgame.add @newGame

    # Alinha o botao do lado direito
    halg_btn_new_game = Gtk::Alignment.new 0.5, 1, 0, 0
    halg_btn_new_game.add hbox_newgame

    # Timer de duração de cada partida
    @lbl_timer = Gtk::Label.new
    @lbl_timer.set_markup("<span foreground='gray' size='xx-large' weight='bold'> 000</span>")

    # Mostra o número de bombas presentes no campo
    @lbl_bombas = Gtk::Label.new
    @lbl_bombas.set_markup("<span foreground='gray' size='xx-large' weight='bold'>" << ( (@bombas < 10) ? "00" << @bombas.to_s : "0" << @bombas.to_s ) << "</span>")

    # Box horizontal que engloba o label de bombas e uma imagem
    hbox_bombs = Gtk::Box.new(:horizontal, 1)
    hbox_bombs.pack_start(@lbl_bombas, :expand => false, :fill => false, :padding => 10)
    hbox_bombs.pack_start(Gtk::Image.new(:file => "img/bomb2.png"), :expand => false, :fill => false, :padding => 0)

    # Box horizontal que engloba o timer e uma imagem
    hbox_timer = Gtk::Box.new(:horizontal, 1)
    hbox_timer.pack_start(Gtk::Image.new(:file => "img/clock.png"), :expand => false, :fill => false, :padding => 0)
    hbox_timer.pack_start(@lbl_timer, :expand => false, :fill => false, :padding => 10)


    halg_timer = Gtk::Alignment.new 1, 1, 0, 1
    halg_timer.add hbox_timer

    halg_lbl_bombas = Gtk::Alignment.new 1, 1, 0, 1
    halg_lbl_bombas.add hbox_bombs

    # box "rodapé" contém os lables de bombas e timer
    hbox_footer = Gtk::Box.new(:horizontal, 1)
    hbox_footer.pack_start(halg_timer, :expand => false, :fill => false, :padding => 0)
    hbox_footer.pack_start(halg_lbl_bombas, :expand => true, :fill => true, :padding => 0)

    # Place the board in a frame, so that it can have a border around it
    frm_inner_box = Gtk::Box.new(:horizontal, 1).pack_start(@board, :expand => false, :fill => false, :padding => 3)
    frame = Gtk::Frame.new
    frame.add Gtk::Box.new(:vertical, 1).pack_start(frm_inner_box, :expand => false, :fill => false, :padding => 3)
    frame.override_background_color(:normal, Gdk::RGBA.new(0.9,0.9,0.9, 0.6))


    # Empilha em uma box vertical os elementos criados
    vbox = Gtk::Box.new(:vertical, 1)
    vbox.pack_start(halg_btn_new_game, :expand => true, :fill => true, :padding => 10)
        .pack_start(Gtk::Separator.new(:horizontal), :expand => false, :fill => true, :padding => 2)
        .pack_start(frame, :expand => false, :fill => false, :padding => 2)
        .pack_start(Gtk::Separator.new(:horizontal), :expand => false, :fill => true, :padding => 5)
        .pack_start(hbox_footer, :expand => true, :fill => true, :padding => 0)
        .pack_start(Gtk::Separator.new(:horizontal), :expand => false, :fill => true, :padding => 5)
        .pack_start(toolbar, :expand => true, :fill => true, :padding => 5)

    # Usada para ser possível dar um espaçamento lateral entre o vbox e as margens da janela
    main_box = Gtk::Box.new(:horizontal,1)
    main_box.pack_start(vbox, :expand => true, :fill => true, :padding => 20)

    # Adiciona o menu e os outros elementos criados à janela
    add Gtk::Box.new(:vertical, 1).pack_start(mb, :expand => true, :fill => true, :padding => 0)
            .pack_start(main_box, :expand => true, :fill => true, :padding => 0)

  end

  def draw_board()
    # Preencha a matriz "field" com bot�es e a incorpora ao tabuleiro "board"
    for x in 0..(@rows-1)
      for y in 0..(@columns-1)

        # Atribui a posição em que o botão do campo se encontra
        @field[x][y].set_x(x)
        @field[x][y].set_y(y)
        @field[x][y].set_size_request(40, 40)

        # Anexa o botao (campo) ao tabuleiro (board) na posicao (x,y)
        @board.attach @field[x][y], x, y, 1, 1

        #Cria o evento para quando o campo for clicado com o botão esquerdo
        verify_right_click(x, y)
        # Cria o evento para quando o campo for clicado
        @field[x][y].signal_connect("clicked") {
          |_widget|

          @board.set_sensitive(false)
          perdeu = campo_clicado(_widget)

          if !perdeu

            e = @AI.choose_field(@tabuleiro)

            # Cria uma nova Thread para a IA jogar, e espera 1 segundo
            # para que o jogador possa ver onde a IA jogou

            player_ia = Thread.new {

              change_lbl_player("#{PLAYER_MACHINE} está pensando...")
              sleep(1)
              @board.set_sensitive(true)

              machine_play(e)

            } #end of Thread
          end

        } # end of signal_connect

      end
    end
  end

  # Comandos executados quando um botão (espaço) do campo é clicado
  def campo_clicado(_widget)
    # O campo clicado e uma bomba?
    if @tabuleiro.get_campo(_widget.get_x,_widget.get_y).isbomba?
      # Para o timer
      @timer.terminate

      # Muda a imagem do botão de novo jogo
      @iconNewGame.file = LOSE_IMG
      #
      # # Mosta um ícone de bomba no local clicado
      # @board.attach @iconBomb, _widget.get_x, _widget.get_y, 1,1
      #
      # _widget.hide()
      # @iconBomb.show
      show_all_bombs
      # Desabilita o tabuleiro
      @board.set_sensitive(false)

      #show_message("Você perdeu!")
      change_lbl_player("#{PLAYER_MACHINE} lives!")
      # a = Thread.new{
      #   sleep(0.3)
      #   Sound.play("./sound/bomb.wav") # play a file from disk
      # }
      return true
    else

      @iconNewGame.file = MISSED_BOMB_IMG

      @tabuleiro.abre_campo(_widget.get_x,_widget.get_y)
      
      abre_vizinhos("user")
    end # else

    false
  end

  def abre_vizinhos (player)
    # Atribui uma cor ao campo aberto, dependendo de quem jogou
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
      show_message("Você conseguiu sobreviver!")
      @board.set_sensitive(false)
    end
  end

  def verify_right_click(i, j)
    @field[i][j].signal_connect("button_press_event") do |widget, event|
      if (event.button == 3)

        if @marked_bombs <= @bombas
          # Se o botão aida não tiver sido marcado
          if @field[i][j].image == nil

            @marked_bombs += 1
            image = Gtk::Image.new(:file => BOMB_QUESTION_IMG)
            #@board.attach image, i, j, 1, 1

            @field[i][j].image = image
            image.show
            @tabuleiro.get_campo(i,j).aberto = true

          # Se o botão clicado não esctiver marcado e o número de bombas marcados for maior que zero
          elsif  (@marked_bombs > 0) && (@field[i][j].image != nil)
            @marked_bombs -= 1
            @field[i][j].image = nil
          end

        end

        bombas_restantes = (@bombas - @marked_bombs)
        @lbl_bombas.set_markup("<span foreground='gray' size='xx-large' weight='bold'>" << ( (bombas_restantes < 10) ? "00" << bombas_restantes.to_s : "0" << bombas_restantes.to_s ) << "</span>")

      end
    end

  end   
    
  def show_message(message)
    GLib::Idle.add do
      message = Gtk::MessageDialog.new(:parent => self, :flags => :destroy_with_parent,
        :type => :info, :buttons_type => :close,
        :message => "#{message}")
      message.run
      message.destroy
      false
    end
  end
 

  # Method that corresponds to the AI part I of the game (random choices of places to play)
  def machine_play(coord)
    if (is_board_enable?)
      p coord
      p coord[:x]
      p coord[:y]
      linha = coord[:x]
      coluna = coord[:y]

      if !(@tabuleiro.get_campo(linha,coluna).isaberto?)

        if !(@tabuleiro.get_campo(linha,coluna).isbomba?)

          @tabuleiro.abre_campo(linha,coluna)
          abre_vizinhos("AI")
          change_lbl_player("#{PLAYER_MACHINE}: Sua vez...")

        else
          @timer.terminate

          @iconNewGame.file = LOSE_AI_IMG
          @board.attach @iconBomb, linha, coluna, 1,1
          @iconBomb.show

          Thread.new{
            sleep(0.3)
            show_all_bombs
            sleep(0.3)
            show_message("Nível 1: #{PLAYER_MACHINE} perdeu!")
          }

          @board.set_sensitive(false)

          change_lbl_player("#{PLAYER_MACHINE}: Isso foi apenas sorte sua...")
        end
      end
    end

  end

  def change_lbl_player (msg)
    GLib::Idle.add do
      @lbl_player.label = msg
      false
    end
  end
  
  # New game
  def reset_board
    window.destroy
    set_modal(false)
    window = CampoMinadoApp.new(@rows, @columns, @parent).set_modal(true)
  end
  # end of method
  
  #verify which IA level the user wants to play
  def verify_level(level1, level2, level3)
    level1.signal_connect("activate") do
      @activatedLevel = 1
    end
    level2.signal_connect("activate") do 
      @activatedLevel = 2
    end
               
    level3.signal_connect("activate") do
      @activatedLevel = 3
    end
  end
  #end of function

  def show_all_bombs
    @tabuleiro.get_bomb_positions.each {
        |bomb|

      # Mosta um ícone de bomba no local clicado
      @board.attach Gtk::Image.new(:file => BOMB_IMG).show, bomb[:x], bomb[:y], 1,1

      @field[bomb[:x]][bomb[:y]].hide
    }
  end

  # Timer usado no jogo
  def timer
    seg = 0
    min = 0

    # Cria uma nova Thread para executar o timer
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
  end
  # end of method

  # verify if the board is enable for the user to play
  def is_board_enable?
    @board.sensitive?
  end

  def exit_game
    self.destroy
    @parent.show
  end

  #load an image to be put to the button
  def load_image(file)
    pixbuf = Gdk::Pixbuf.new file
    pixmap, mask = pixbuf.render_pixmap_and_mask
    image = Gtk::Pixmap.new(pixmap, mask)
  end
  #end of function
  
end
#end of class

#main()
#window = CampoMinadoApp.new(10,10)

#Gtk.main
#end of main()
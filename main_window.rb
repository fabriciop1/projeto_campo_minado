require 'gtk3'
require_relative 'app.rb'
require_relative 'artificial_intelligence.rb'

class MainWindow < Gtk::Window
  LOGO_IMG = "img/big_bomb.png"
  def initialize
    super()
    set_title "Campo Minado"
    set_window_position(:center)
    set_border_width 25
    set_icon("img/bomb2.png")
    set_default_size 500, 200
    self.resizable = (false)
    signal_connect("destroy") { Gtk.main_quit }
    override_background_color :normal, Gdk::RGBA::new(1,1,1,1)
    make_screen

    show_all
  end

  def make_screen
    logo = Gtk::Image.new(:file => LOGO_IMG)

    small = Gtk::RadioButton.new(:label => 'Pequeno (8 x 8)')
    medium = Gtk::RadioButton.new(:label => 'Médio (12 x 12)', :member => small)
    large = Gtk::RadioButton.new(:label => 'Grande (14 x 14)', :member => small)

    label = Gtk::Label.new(" Tamanho:")

    bx_tam = Gtk::Box.new(:vertical, 3)
    bx_tam.pack_start(label, :expand => true, :fill => true, :padding => 8)
    bx_tam.pack_start(small, :expand => true, :fill => true, :padding => 0)
    bx_tam.pack_start(medium, :expand => true, :fill => true, :padding => 0)
    bx_tam.pack_start(large, :expand => true, :fill => true, :padding => 0)

    level1 = Gtk::RadioButton.new(:label => "Fácil")
    level2 = Gtk::RadioButton.new(:label => "Médio", :member => level1)
    level3 = Gtk::RadioButton.new(:label => "Difícil", :member => level1)

    lbl_level = Gtk::Label.new(" Nível:")

    bx_lvl = Gtk::Box.new(:vertical, 3)
    bx_lvl.pack_start(lbl_level, :expand => true, :true => true, :padding => 8)
    bx_lvl.pack_start(level1, :expand => true, :fill => true, :padding => 0)
    bx_lvl.pack_start(level2, :expand => true, :fill => true, :padding => 0)
    bx_lvl.pack_start(level3, :expand => true, :fill => true, :padding => 0)

    hbox = Gtk::Box.new(:horizontal, 1)
    hbox.pack_start(bx_tam, :expand => true, :true => true, :padding => 8)
    hbox.pack_start(bx_lvl, :expand => true, :true => true, :padding => 8)

    frame = Gtk::Frame.new
    frame.set_hexpand true
    frame.set_vexpand true
    frame.override_background_color(:normal, Gdk::RGBA.new(0.9,0.9,0.9, 0.4))
    frame.add Gtk::Box.new(:vertical,1).pack_start(hbox, :expand => true, :true => true, :padding => 10).pack_start(Gtk::Label.new(" "), :expand => true, :true => true, :padding => 10)

    lbl = Gtk::Label.new
    lbl.set_markup("<span size='large'> Jogar </span>")
    jogar = Gtk::Button.new
    jogar.add lbl
    jogar.set_size_request 80,40

    jogar.signal_connect("clicked") do |widget|
      hide
      linhas = small.active? ? 8 : (medium.active? ? 12 : 14)
      colunas = small.active? ? 8 : (medium.active? ? 12 : 14)

      level_chosen = (level1.active?) ? 1 : ((level2.active?) ? 2 : 3)

      CampoMinadoApp.new(level_chosen, linhas, colunas, self).set_modal(true)
    end

    fixed = Gtk::Fixed.new
    fixed.put(logo, 0, 0)
    fixed.put(frame, 250, 30)
    fixed.put(jogar, 325, 190)

    add fixed
  end
end

main_window = MainWindow.new
Gtk.main
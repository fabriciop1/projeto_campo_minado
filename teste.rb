require "gtk3"
Gtk.init
window = Gtk::Window.new
window.title = "Janela Exemplo"
window.signal_connect("destroy"){ Gtk.main_quit }

container = Gtk::HBox.new
b1 = Gtk::Button.new(:label => "BT 1")
b2 = Gtk::Button.new(:label => "BT 2")
b3 = Gtk::Button.new(:label => "BT 3")
container.add b1
container.add b2
container.add b3
i = 0
Thread.new{
  while true
    i += 1
    b1.label = "BT " << (i).to_s
    p b1.label
    sleep(1)
  end
}
window.add container
window.show_all


Gtk.main

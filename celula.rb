class Celula

  attr_reader :bomba, :aberto, :vizinhos
  attr_writer :bomba, :aberto, :vizinhos

  def initialize (bomba)
    @bomba = false
    @aberto = false
    @vizinhos = 0 #vizinhos que são bombas ao redor de um campo 
  end

  def isbomba?
    @bomba
  end

  def isaberto?
    @aberto
  end

end
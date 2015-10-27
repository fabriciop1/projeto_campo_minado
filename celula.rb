class Celula

  attr_reader :vizinhos
  attr_writer :bomba, :aberto, :vizinhos

  def initialize (bomba)
    @bomba = false
    @aberto = false
    @vizinhos = 0
  end

  def to_s
    if @bomba
      "B"
    else
      vizinhos.to_s
    end
  end

  def isbomba?
    @bomba
  end

  def isaberto?
    @aberto
  end


end
class Celula

  attr_reader :bomba, :aberto
  attr_writer :bomba, :aberto, :vizinhos

  def initialize (bomba)
    @bomba = false
    @aberto = false
    @vizinhos = 0
  end

  def to_s
    if @bomba
      return 'B'
    end

    return @vizinhos.to_s
  end

  def isbomba?
    @bomba
  end

  def isaberto?
    @aberto
  end

  def vizinhos
    @vizinhos
  end
end
@a
def teste
  p @a
  a = rand(4)
  if @a != a
    @a = a
  else
    teste
  end
end

teste
p "Segund"
teste
p @a
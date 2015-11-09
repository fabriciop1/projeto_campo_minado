a = [{x:1, :y => 2}, "casa", 4,5,6]
b = [{:x => 1, :y => 2},{:x => 1, :y => 3}]
t = 0

a << b

p a.flatten!.uniq!
p a
p a.uniq!
p a
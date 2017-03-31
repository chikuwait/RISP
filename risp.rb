
def token(str)
  str.gsub(/[()]/, ' \0 ').split
end

puts token(ARGV[0])

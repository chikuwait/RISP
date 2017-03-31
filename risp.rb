def token(str)
  raise ArgumentError,'There is no argument' if str == nil
  str.gsub(/[()]/, ' \0 ').split
end
puts token(ARGV[0])

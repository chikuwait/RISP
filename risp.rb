def token(str)
  raise ArgumentError,'There is no argument' if str == nil
  str.gsub(/[()]/, ' \0 ').split
end

def read(tokens)
  raise SytanxError 'unexpected EOF while reading' if tokens.length == 0
  case token = tokens.shift

  when '('
    ary = []
    until tokens[0] == ')'
      ary.push read(tokens)
    end
    tokens.shift
    ary
  when ')'
    raise SyntaxError, 'unexpected )'
  else
    atom(token)
  end
end

module Kernel
  def symbol(obj)
    obj.intern
  end
end

def atom(token,type=[:Integer, :Float, :Symbol])
  send(type.shift, token)
rescue ArgumentError
  retry
end
def read(s)
  read(token(s))
end
token(ARGV[0])

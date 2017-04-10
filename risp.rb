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
  def Symbol(obj)
    obj.intern
  end
end

def atom(token,type=[:Integer, :Float, :Symbol])
  send(type.shift, token)
rescue ArgumentError
  retry
end

def reader_interface(s)
  read(token(s))
end

def evaluate(x, env = $global_env)
    case x
    when Symbol
        env.find(x)[x]
    when Array
        case x.first
        when :quote
            _, exp = x
            exp
        when :if
            _, test, conseq, alt = x
            evaluate((evaluate(test,env) ? conseq : alt),env)
        when :set!
            _, var, exp = x
            env.find(var)[var] = evaluate(exp,env)
        when :define
            _, var, exp = x
            env[var] = evaluate(exp,env)
        when :lambda
            _, vars, exp = x
            lambda{|*args| evaluate(exp,Env.new(vars,args,env))}
        else
            proc, *exps = x.inject([]) { |mem, exp| mem << evaluate(exp,env)}
            proc[*exps]
        end
    else
      x
    end
end

class Env < Hash
  def initialize(parms = [], args = [], outer = nil)
    h = hash[parms.zip(args)]
    self.merge!(h)
    self.merge!(yeild) if block_given?
    @outer = outer
  end

  def find(key)
    self.has_key?(key) ? self : @outer.find(key)
  end
end

$global_env = Env.new do
    {
         :+     => ->x,y{x+y},      :-      => ->x,y{x-y},
         :*    => ->x,y{x*y},       :/     => ->x,y{x/y},
         :not    => ->x{!x},        :>    => ->x,y{x>y},
         :<     => ->x,y{x<y},      :>=     => ->x,y{x>=y},
         :<=   => ->x,y{x<=y},      :'='   => ->x,y{x==y},
         :equal? => ->x,y{x.equal?(y)}, :eq?   => ->x,y{x.eql? y},
         :length => ->x{x.length},  :cons => ->x,y{[x,y]},
         :car   => ->x{x[0]},       :cdr    => ->x{x[1..-1]},
         :append => ->x,y{x+y},     :list  => ->*x{[*x]},
         :list?  => ->x{x.instance_of?(Array)},
         :null? => ->x{x.empty?},   :symbol? => ->x{x.instance_of?(Symbol)}
    }
end

def to_string(exp)
  puts (exp.instance_of?(Array)) ? '('+ exp.map(&:to_s).join(" ") + ')' : "#{exp}"
end
require "readline"
reader_interface(ARGV[0])

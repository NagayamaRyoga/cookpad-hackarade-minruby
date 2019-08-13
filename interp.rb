require "minruby"

# An implementation of the evaluator
def evaluate(exp, env)
  # exp: A current node of AST
  # env: An environment (explained later)

  case exp[0]

#
## Problem 1: Arithmetics
#

  when "lit"
    exp[1] # return the immediate value as is

  when "+"
    evaluate(exp[1], env) + evaluate(exp[2], env)
  when "-"
    evaluate(exp[1], env) - evaluate(exp[2], env)
  when "*"
    evaluate(exp[1], env) * evaluate(exp[2], env)
  when "/"
    evaluate(exp[1], env) / evaluate(exp[2], env)
  when "%"
    evaluate(exp[1], env) % evaluate(exp[2], env)
  when "=="
    evaluate(exp[1], env) == evaluate(exp[2], env)
  when "!="
    evaluate(exp[1], env) != evaluate(exp[2], env)
  when "<"
    evaluate(exp[1], env) < evaluate(exp[2], env)
  when ">"
    evaluate(exp[1], env) > evaluate(exp[2], env)
  # ... Implement other operators that you need


#
## Problem 2: Statements and variables
#

  when "stmts"
    exp.drop(1).inject(nil) {|_, exp| evaluate(exp, env)}

  # The second argument of this method, `env`, is an "environement" that
  # keeps track of the values stored to variables.
  # It is a Hash object whose key is a variable name and whose value is a
  # value stored to the corresponded variable.

  when "var_ref"
    env[exp[1]]

  when "var_assign"
    env[exp[1]] = evaluate(exp[2], env)


#
## Problem 3: Branchs and loops
#

  when "if"
    if evaluate(exp[1], env)
      evaluate(exp[2], env)
    else
      evaluate(exp[3], env)
    end

  when "while"
    while evaluate(exp[1], env)
      evaluate(exp[2], env)
    end

#
## Problem 4: Function calls
#

  when "func_call"
    # Lookup the function definition by the given function name.
    func = $function_definitions[exp[1]]

    if func.nil?
      # We couldn't find a user-defined function definition;
      # it should be a builtin function.
      # Dispatch upon the given function name, and do paticular tasks.
      case exp[1]
      when "p"
        # MinRuby's `p` method is implemented by Ruby's `p` method.
        p(evaluate(exp[2], env))
      when "Integer"
        Integer(evaluate(exp[2], env))
      else
        raise("unknown builtin function")
      end
    else


#
## Problem 5: Function definition
#
      new_env = env.clone()
      exp.drop(2).zip(func[2]).each do |exp, name|
        new_env[name] = evaluate(exp, env)
      end
      evaluate(func[3], new_env)
    end

  when "func_def"
    $function_definitions[exp[1]] = exp


#
## Problem 6: Arrays and Hashes
#

  # You don't need advices anymore, do you?
  when "ary_new"
    exp.drop(1).collect {|exp| evaluate(exp, env)}

  when "ary_ref"
    arr = evaluate(exp[1], env)
    index = evaluate(exp[2], env)
    arr[index]

  when "ary_assign"
    arr = evaluate(exp[1], env)
    index = evaluate(exp[2], env)
    value = evaluate(exp[3], env)
    arr[index] = value

  when "hash_new"
    exp.drop(1).each_cons(2).inject({}) do |h, x|
      index = evaluate(x[0], env)
      value = evaluate(x[1], env)
      h[index] = value
      h
    end

  else
    p("error")
    pp(exp)
    raise("unknown node")
  end
end


$function_definitions = {}
env = {}

# `minruby_load()` == `File.read(ARGV.shift)`
# `minruby_parse(str)` parses a program text given, and returns its AST
ast = minruby_parse(minruby_load())
p ast
evaluate(ast, env)

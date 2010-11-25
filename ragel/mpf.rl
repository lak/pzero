require "rubygems"
require "awesome_print"

%%{
  machine mpf;

  action foo {
    puts "OK"
  }

  action mark {
    @tokenstack.push(p)
    #puts "Mark: #{self.line(string, p)}##{self.column(string, p)}"
  }

  action stack_string {
    #puts "Stack string: #{self.line(string, p)}##{self.column(string, p)}"
    #ap @tokenstack
    startpos = @tokenstack.pop
    endpos = p
    token = string[startpos ... endpos]
    @stack << token
  }

  action resource {
    name = @stack.pop
    @resources.each do |resource|
      @types[name] << resource
    end
    @resources = nil
  }

  action resource_entry {
    @resources ||= Hash.new { |h,k| h[k] = [] }
    name = @stack.pop
    @resources[name] << @parameters
    #ap name => @parameters

    # Clear parameters
    @parameters = nil
  }

  action parameter {
    @parameters ||= Hash.new { |h,k| h[k] = [] }
    value = @stack.pop
    name = @stack.pop
    #puts "parameter: #{name} => #{value}"
    @parameters[name] << value
  }

  action reference {
    resource_name = @stack.pop
    resource_type = @stack.pop
    @references ||= Array.new
    ref = { :type => resource_type, :name => resource_name }
    def ref.to_s
      "#{self[:type]}[#{self[:name]}]"
    end
    @references.push(ref)
  }

  action edge {
    relationship = @stack.pop
    a, b = @references.pop(2)
    @edges << [a, relationship, b]
  }

    
  ws = ([ \t\n])* ;
  arrow = ( "->" | "<-" | "~>" | "<~" ) >mark %stack_string ;
  uppercase_name = ( [A-Z][A-Za-z0-9:]* ) >mark %stack_string ;

  quoted_string = ( ( "\"" ( ( (any - [\\"\n]) | "\\" any )* ) "\"" ) |
                    ( "'" ( ( (any - [\\'\n]) | "\\" any )* ) "'" ) )
                  >mark %stack_string ;
  #naked_string = ( /[A-Za-z0-9_]+/ ) >mark %stack_string ;
  naked_string = ( alnum | "_" )+ >mark %stack_string ;
  string = ( quoted_string | naked_string ) ;

  type_name = ( [A-Za-z0-9_:]+ ) >mark %stack_string ;
  param_name = ( [A-Za-z0-9_]+ ) >mark %stack_string ;
  param_value = string ;

  parameter = ( param_name ws "=>" ws param_value ) %parameter ;
  parameters = parameter ( ws "," ws parameter )* ;

  reference = ( uppercase_name "[" string "]" ) %reference;
  #edge = ( reference ws arrow ws reference ( ws arrow ws reference )* ) @edge ;
  edge = ( reference ws arrow ws reference ) %edge ;
  
  resource_name = string;
  resource_entry = ( resource_name ws ":" ws parameters? ws ";" ) %resource_entry ;
  resource_entries = ( resource_entry ( ws resource_entry )* ) ;

  resource = ( type_name ws "{" ws resource_entries ws "}" ) %resource ;
  statement = (ws (resource | edge ) )+ ;

  main := statement*
          0 @{ puts "Failed" }
          $err { 
            # Compute line and column of the cursor (p)
            puts "Error at line #{self.line(string, p)}, column #{self.column(string, p)}: #{string[p .. -1].inspect}"
          } ;
}%%

class MPF
  attr_accessor :eof

  def initialize
    # BEGIN RAGEL DATA
    %% write data;
    # END RAGEL DATA

    @tokenstack = Array.new
    @stack = Array.new

    @types = Hash.new { |h,k| h[k] = [] }
    @edges = []
  end

  def parse(string)
    data = string.unpack("c*")

    # BEGIN RAGEL INIT
    %% write init;
    # END RAGEL INIT

    begin 
      # BEGIN RAGEL EXEC 
      %% write exec;
      # END RAGEL EXEC
    rescue => e
      # Compute line and column of the cursor (p)
      $stderr.puts "Exception at line #{self.line(string, p)}, column #{self.column(string, p)}: #{string[p .. -1].inspect}"
      raise e
    end

    # Print our state
    @types.each do |type, resources|
      ap type => resources
    end
    @edges.each do |a, relationship, b|
      puts "Edge: #{a} #{relationship} #{b}"
    end
    return cs
  end

  def line(str, pos)
    return str[0 .. pos].count("\n") + 1
  end

  def column(str, pos)
    return str[0 .. pos].split("\n").last.length
  end

end # class MPF

def parse(string)
  puts "result %s" % MPF.new.parse(string)
end

parse(File.open(ARGV[0]).read)

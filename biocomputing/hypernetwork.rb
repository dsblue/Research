DATAFILE = ARGV[0].to_s
POPSIZE = ARGV[1].to_i

LEN = ARGV[2].to_i
GC_RATIO = ARGV[3].to_f

class Array
  def shuffle!
    size.downto(1) { |n| push delete_at(rand(n)) }
    self
  end
end

NN_PARAMS = {
  "A"=>4.31,
  "T"=>4.31,
  "C"=>4.05,
  "G"=>4.05,
  "AA"=>-4.26,
  "TT"=>-4.26,
  "AT"=>-3.67,
  "TA"=>-2.5,
  "CA"=>-6.12,
  "TG"=>-6.12,
  "GT"=>-6.09,
  "AC"=>-6.09,
  "CT"=>-5.40,
  "AG"=>-5.40,
  "GA"=>-5.51,
  "TC"=>-5.51,
  "CG"=>-9.07,
  "GC"=>-9.36,
  "GG"=>-7.66,
  "CC"=>-7.66,
}

class CandidateSolution
  attr_accessor :size
  attr_accessor :solution
  attr_accessor :g
  
  def initialize()
    @size = LEN
    @solution = Array.new(LEN)
    
    n = ['A','T','C','G']
    mid = GC_RATIO * @size
    ok = false
    
    while (!ok) 
    
      for i in (1..@size)
        if (i <= mid)
          @solution[i-1] = n[rand(2)]   # A/T
        else
          @solution[i-1] = n[rand(2)+2] # C/G
        end
      end
    
      @solution.shuffle!
      ok = true
      
      # Check solution
      # Is the first half the reverse comp of the second half?
      mid = (@size/2).to_int
      for i in (1..mid)
        if (@solution[i-1] == 'A' && @solution[@size - i] == 'T')
          ok = false
        elsif (@solution[i-1] == 'T' && @solution[@size - i] == 'A')
          ok = false
        elsif (@solution[i-1] == 'C' && @solution[@size - i] == 'G')
          ok = false
        elsif (@solution[i-1] == 'G' && @solution[@size - i] == 'C')
          ok = false
        end          
      end
      
      ok = true
    end
    
    ## Determine the average free energy for the sequence
    @g = NN_PARAMS[@solution[0]]
    for i in (1..@size-1) 
      str = [ @solution[i-1], @solution[i]]
      @g += NN_PARAMS[str.join]  
    end
    @g += NN_PARAMS[@solution[@size-1]]
  end

  def reverse_comp
    rev = @solution.reverse
    rev.map! { |x| 
      if (x == 'A') 
        x = 'T'
      elsif (x == 'T') 
        x = 'A'
      elsif (x == 'C') 
        x = 'G'
      elsif (x == 'G') 
        x = 'C'
      end
    }
    return rev
  end
  
  def to_s
    @solution.join
  end

  def fitness
    ones = 0;
    @solution.each { |i| 
      if i == 1
        ones = ones + 1
      end
    }
    return ones / (1.0 * @size)
  end
  
end


File.open(DATAFILE, 'r') do |f1|  
  ## Build the word hash
  
  while line = f1.gets  
    line.split(/[\.?!;]/).each { |sentence| 
      p "--------"
      sentence.split.each { |word|
        p word
      }      
    }
    
#    puts line  
  end  
end  


population = Array.new

for i in (0..POPSIZE) 
  population[i] = CandidateSolution.new
end

population.uniq!

## Todo remove reverse comps 

# Sort by free energy
population = population.sort_by { |x| x.g }

population.each { |s| puts "#{s.to_s} , #{s.g}" }

#p sol
#p sol.reverse_comp.join



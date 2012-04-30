DATAFILE = ARGV[0].to_s
LEN = ARGV[1].to_i
GC_RATIO = ARGV[2].to_f

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


#################################################################

WORDS = Hash.new
HYPEREDGES = Hash.new

puts "Loading dataset from #{DATAFILE}..."
puts "Creating Hyperedges"

File.open(DATAFILE, 'r') do |f1|    
  while line = f1.gets  
    line.split(/[\.?!;]/).each { |sentence| 
      a = sentence.split
      a.map! { |x| x.upcase }

      a.each { |word|
        if (WORDS[word]) 
          WORDS[word] += 1
        else 
          WORDS[word] = 1
        end
      }

      i = 0
      while ((i+2) < a.size) 
        #build an edge
        edge = [a[i], a[i+1], a[i+2]]
        if (HYPEREDGES[edge]) 
          HYPEREDGES[edge] += 1
        else
          HYPEREDGES[edge] = 1
        end
        i += 1 
      end
    }
  end  
end  

sorted_words = WORDS.to_a.sort_by { |x| -x[1] }
sorted_edges = HYPEREDGES.to_a.sort_by { |x| -x[1] }

puts "Found #{sorted_words.size} words"
puts "Found #{HYPEREDGES.size} hyperedges"
puts "Listing top 10 hyperedges"
for i in (0..9) 
  puts "  #{sorted_edges[i][0].join(' ')}: #{sorted_edges[i][1]}"
end

puts "Creating #{2*sorted_words.size} sequences of length #{LEN}"
puts "Using a GC Ratio of #{GC_RATIO}"

population = Array.new

while population.size < (2 * sorted_words.size)
  sol = CandidateSolution.new
  
  ## Remove reverse comps 
  rev = sol.reverse_comp
  found = false
  population.each { |s| 
    if (rev == s.solution) 
      found = true
    end
  }
  
  if (!found)
    population << sol
    population.uniq!
  end
end


# Sort by free energy
sorted_seq = population.sort_by { |x| x.g }

#population.each { |s| puts "#{s.to_s} , #{s.g}" }

puts "Created nucleotide sequences"
puts "Listing top 10, sorted by estimated free energy (kJ/mol):"
for i in (0..9) 
  puts "  #{sorted_seq[i]}, free energy #{sorted_seq[i].g}"
end

puts "Assigning nucleotide sequences to Hyperedges:"

dict = Hash.new
sorted_words.each_with_index { |w,i|
  dict[w[0]] = sorted_seq[i]
}

HYPEREDGES.each { |e,w| 
  puts "#{e.join(' ')} (#{w}):\t #{dict[e[0]]}#{dict[e[1]]}#{dict[e[1]]}#{dict[e[2]]}"
}


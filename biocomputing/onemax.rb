N = ARGV[0].to_i

def population(n) 
  pop = Array.new
  for i in (1..n)
    pop[i-1] = rand(2)
  end
  return pop
end

def fitness(p)
  ones = 0;
  p.each { |i| 
    if i == 1
      ones = ones + 1
    end
  }
  return ones / (1.0 * p.size)
end

def prune(s)
  
end

##
##
##
class CantidateSolution
  attr_accessor :size
  
  def initialize(size)
    @size = size
    @solution = Array.new

    for i in (1..size)
      @solution[i-1] = rand(2)
    end
  end

  def to_s
    @solution
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

class Population
  
  def initialize(size, length)
    @size = size
    @solutionLength = length

    @population = Array.new

    for i in (1..size)
      @population[i-1] = CantidateSolution.new(length)
    end
  end

  

  def print
    @population.each { |s|
      p s,s.fitness
    }
  end

end

s1 = CantidateSolution.new(10)

p s1.to_s
p s1.fitness

p1 = Population.new(5,2)

p1.print

#######################################

solutions = Array.new(N)
fitgroup = Array.new

for s in (0..solutions.size-1)
  solutions[s] = population(1000)     
end

solutions.each { |s|  
   fitgroup.push(fitness(s))
}

#p fitgroup.sort

STRLEN = ARGV[0].to_i
POPSIZE = ARGV[1].to_i

## What percent to discard each itteration
#DISCARD = 0.50
DISCARD = ARGV[2].to_i * 0.01
## Mutation rate
#MUTATE = 0.10
MUTATE = ARGV[3].to_i * 0.01

class CantidateSolution
  attr_accessor :size
  attr_accessor :solution
  
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

  def breed(mate)
  
    point = rand(@solution.size)
    child = CantidateSolution.new(@solution.size)
    start_mom = rand(2)
    for i in (0..@solution.size-1) 
      if (i < point) 
        if (start_mom == 0)
          child.solution[i] = @solution[i]      
        else
          child.solution[i] = mate.solution[i]
        end
      else 
        if (start_mom == 0)
          child.solution[i] = mate.solution[i]
        else
          child.solution[i] = @solution[i]    
        end
      end
    end

    ## Add point mutation
    point = rand(@solution.size)
    if ( rand() < MUTATE )
      if ( child.solution[point] == 1 )
        child.solution[point] = 0
      else 
        child.solution[point] = 1
      end
    end
        
    return child
    
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
      p s.fitness
    }
  end

  def itterate

    ## Sort the population by fitness
    @population = @population.sort { |a, b| a.fitness <=> b.fitness  }
  
    ## Print best
    ##p @population[@population.size-1]

    ## Replace the least fit by offspring of the most fit
    mid = (@population.size * DISCARD).floor
    best = (@population.size-1) - mid

    for i in (mid..@population.size-1)
      mom = @population[mid + rand(best)]
      dad = @population[mid + rand(best)]    
      child = mom.breed(dad)
      @population[i] = child  
    end
  
  end

  def check
    max = false
    @population.each { |s|
      if ( s.fitness == 1.0 )
#        puts "Found solution: #{ s.to_s } "
        max = true
      end
    }
    return max
  end

end

#######################################

p1 = Population.new(POPSIZE,STRLEN)

i = 0;
while !p1.check
#  puts "Itteration ##{i}"
  i = i + 1
  p1.itterate
end

puts "Itteration ##{i}"
 
#p1.print


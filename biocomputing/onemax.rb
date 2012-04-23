N = ARGV[0].to_i

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

#######################################

p1 = Population.new(100,N)

p1.print

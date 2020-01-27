require 'set'

class Game
  attr_reader :codeword, :alphabet, :guessed

  def initialize
    @codeword = gen_codeword()
    @alphabet = gen_alpha_set()
    @guessed = Set.new

  end

  def gen_codeword
    # convert nouns.txt to an array of strings
    words = File.readlines('assets/nouns.txt').map do |line|
      line.split.map(&:to_s)
    end
    
    # randomly choose the codeword from the words array
    return words.sample
  end

  def gen_alpha_set
    set = Set.new
    return set | ('a'..'z')
  end

  def render
    puts @codeword
  end
  
end


# starts a new game when <ruby game.rb> is run in CLI
if $PROGRAM_NAME == __FILE__
  Game.new.render
end
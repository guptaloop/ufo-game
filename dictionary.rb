class Dictionary

  def self.read_file
    File.readlines("assets/nouns.txt").map { |word| word.chomp.upcase }
  end

  attr_reader :codeword, :matches, :char_idxs, :hash

  def initialize(words = Dictionary.read_file)
    @codeword = words.sample
    @matches = create_codeword_matches(words)
    @char_idxs = create_codeword_char_idxs()
    @hash = (codeword.length).times.map { "_" }
  end

  def create_codeword_matches(words)
    set = Set.new
		words.each do |word|
			set.add(word) if word.length == @codeword.length 
		end
    set
  end

  def get_codeword
    @codeword
  end

  def get_matches
    @matches
  end

	def create_codeword_char_idxs()
		obj = {}
		@codeword.each_char.with_index do |char, idx|
			obj[char] ? obj[char] << idx : obj[char] = [idx]
		end
		obj
	end

  def update_codeword_hash(guess)
		idxs = @char_idxs[guess]
		idxs.each { |idx| @hash[idx] = guess }
	end
  
  def display_codeword_hash
		puts "Codeword: "
		puts @hash.join(" ")
		puts
	end

	def codeword_solved?
		!@hash.include?("_") ? true : false
  end
  
  ## BONUS - dictionary matches algorithm
	
	def display_matches
		puts "Number of dictionary matches: #{@matches.size}"
		puts
	end

	def update_matches(guess_type, guesses)
		@matches.each do |word|
			guesses.each do |letter|
				if (guess_type == 'correct' && word.include?(letter))
					compare_letters(word, letter)
				elsif (guess_type == 'correct' && !word.include?(letter))
					@matches.delete(word)
				elsif (guess_type == 'incorrect' && word.include?(letter))
					@matches.delete(word)
				end
			end
		end
	end

	def compare_letters(word, letter)
		@char_idxs[letter].each do |idx|
			@matches.delete(word) unless word[idx] == letter
		end
	end

end
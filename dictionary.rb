class Dictionary

  def self.read_file
    File.readlines("assets/nouns.txt").map { |word| word.chomp.upcase }
  end

  attr_accessor :codeword

  def initialize(words = Dictionary.read_file)
    @codeword = words.sample
    @char_idxs = create_codeword_char_idxs()
    @codeword_matches = create_codeword_matches(words)
    @codeword_hash = (@codeword.length).times.map { "_" }
	end

	# public API for Game class
	
	def is_codeword_solved?
		!@codeword_hash.include?("_") ? true : false
  end
		
	def render_codeword_hash
		puts "\nCodeword: "
		puts @codeword_hash.join(" ")
	end

	def update_codeword_hash(guess)
		# reassigns hash(es) to reveal correctly guessed letters
		idxs = @char_idxs[guess]
		idxs.each { |idx| @codeword_hash[idx] = guess }
	end
  
	def render_codeword_matches
		puts "\nNumber of dictionary matches: #{@codeword_matches.size}"
	end
	
	# BONUS - dictionary matches algorithm
	def update_codeword_matches(guess_type, guesses)
		@codeword_matches.each do |word|
			guesses.each do |letter|
				# conditionals narrow matches after each guess is made
				if (guess_type == 'correct' && word.include?(letter))
					compare_letters(word, letter)
				elsif (guess_type == 'correct' && !word.include?(letter))
					@codeword_matches.delete(word)
				elsif (guess_type == 'incorrect' && word.include?(letter))
					@codeword_matches.delete(word)
				end
			end
		end
	end

	# no need to expose these methods outside of this class
	private

	def compare_letters(word, letter)
		# checks if every occurrence of a correct letter in the codeword also 
		# occurs at the same index in a potential match
		@char_idxs[letter].each do |idx|
			@codeword_matches.delete(word) unless word[idx] == letter
		end
	end

	# takes the codeword, and creates a hash with each unique char as a key, and 
	# an array of its indices as a value -- e.g. "MOM" => { 'M': [0,2], 'O': [1] }
	def create_codeword_char_idxs()
		obj = {}
		@codeword.each_char.with_index do |char, idx|
			obj[char] ? obj[char] << idx : obj[char] = [idx]
		end
		obj
	end

	# once codeword is initialized, narrow down potential matches to words 
	# that have the same length 
  def create_codeword_matches(words)
    set = Set.new
		words.each do |word|
			set.add(word) if word.length == @codeword.length 
		end
    set
	end

end # class end
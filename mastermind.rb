require 'pry'

# TODO: let the computer set the code
# TODO: maybe move some methods into the human class
# TODO: a lot of the attr_accessors probably don't need to exist because they're external accessors

class Game

    attr_accessor :board, :guess_number

    private

    attr_accessor :player1, :player2, :num_of_games, :players, :code
    
    def initialize
        player1_name = self.get_player_name(1)
        player2_name = self.get_player_name(2)
        
        player1_role = self.get_player_role(player1_name)
        player2_role = self.get_player_role(player2_name)
        if player1_role == player2_role
            puts "***You can't have the same role***"
            player1_role = self.get_player_role(player1_name)
            player2_role = self.get_player_role(player2_name)
        end

        @player1 = self.create_player(player1_name, player1_role)
        @player2 = self.create_player(player2_name, player2_role)

        @players = [@player1, @player2]

        puts "How many games will you play??"
        @num_of_games = gets.chomp.to_i
        
        # needs to be initilialized as an array so the clear in .new_board doesn't throw an error
        @board = Array.new
        @guess_number = 0
        @code = ""
        self.set_code
    end

    def get_player_name(player_num)
        puts "Player #{player_num}, what's your name? Enter 'CPU' to create a computer player"
        gets.chomp.upcase
    end

    def get_player_role(player_name)
        puts "#{player_name}, what's your role? (CM or CB)"
        role = gets.chomp.downcase
        unless role == "cm" || role == "cb"
            puts "***Role must be CM or CB***"
            role = self.get_player_role(player_name)
        end
        role
    end

    def create_player(player_name, player_role)
        if player_name == "CPU"
            Computer.new(player_role, self)
        else
            Human.new(player_name, player_role)
        end
    end

    def set_code
        if self.role?("cm").name == "CPU"
            new_code = ""
            4.times {new_code.insert(0, "#{Random.rand(6) + 1}")}
            @code = new_code
        else
            puts "#{self.role?("cm").name}, set your code"
            @code = gets.chomp
        end
        unless self.is_valid?(@code)
            self.set_code
            return 
        end

        @code = @code.split(//)

        self.new_board
        self.make_guess(self.role?("cb"))
    end

    def role?(role)
        temp = @players.select {|player| player.role == role}
        temp[0]
    end

    def is_valid?(input)
        if input.length != 4
            puts "***The code must be 4 digits***"
            return false
        end
        if input.split(//).all? {|digit| digit.to_i > 0 && digit.to_i < 7}
            true
        else
            puts "**Digits can only be between 0-6***"
            false
        end
    end

    def new_board
        @board.clear
        12.times {@board.push(["o", "o", "o", "o", "|", "0", "0", "0", "0"])}
        self.print_board
    end

    def print_board
        @board.each {|value| puts value.join("  ")}
    end

    def make_guess(guessing_player)
        if guessing_player.name == "CPU"
            guess = guessing_player.computer_guess
            puts "The computer guesses #{guess.join}!"
        else
            puts "#{guessing_player.name}, what do you think the code is?"
            guess = gets.chomp
            unless self.is_valid?(guess)
                self.make_guess(guessing_player)
                return
            end
            guess = guess.split(//)
        end
        
        self.give_hint(guess)

        if guess == @code
            puts "Congratulations #{guessing_player.name}, you got it!"
            self.announce_scores(self.role?("cm"))
            self.reset_game
            return
        else
            self.role?("cm").score += 1
        end

        self.end_round
    end

    def give_hint (guess)
        guess.each_index do |column|
            if guess[column] == @code[column]
                puts "Digit #{column + 1} is exactly right!"
                @board[@guess_number][column] = "b"
            elsif guess.any?(@code[column])
                puts "Digit #{column + 1} is right, but in the wrong place!"
                @board[@guess_number][column] = "w"
            else
                puts "Digit #{column + 1} isn't part of the code"
            end
            @board[@guess_number][column + 5] = guess[column]
        end
    end

    def end_round
        self.print_board
        @guess_number += 1
        if @guess_number > 11
            puts "Oh no, you're out of guesses! The code was #{guess.join}"
            self.role?("cm").score += 1
            self.announce_scores(self.role?("cm"))
            self.reset_game
        else
            puts "#{12 - @guess_number} guesses remaining"
            self.make_guess(self.role?("cb"))
        end
    end

    def announce_scores(codemaster)
        puts "The current score is #{codemaster.name}: #{codemaster.score} - #{self.role?("cb").name}: #{self.role?("cb").score}"
    end

    def reset_game 
        if @num_of_games > 1 # because you play one initially
            @num_of_games -= 1
            if @num_of_games == 1
                puts "#{num_of_games} game remaining!"
            else
                puts "#{num_of_games} games remaining!"
            end
            # switch roles
            old_p1 = @player1.role
            old_p2 = @player2.role
            @player1.role = old_p2
            @player2.role = old_p1
            @guess_number = 0
            self.new_board
            self.set_code
            # TODO: call the computer's reset function to put it back to defaults - including all hints

        else
            exit(0)
        end
    end
end

class Human
    
    attr_accessor :role, :name, :score

    private

    def initialize(name, role)
        @name = name
        @role = role
        @score = 0
    end
end

class Computer
    
    attr_accessor :role, :name, :score
    
    def computer_guess
        if @parent.guess_number == 0 # FIXME: @parent becomes a nil for some reason on 2nd game?
            @last_guess = %w[1 1 2 2]
            %w[1 1 2 2]
        else
            last_hint = @parent.board[@parent.guess_number - 1][0..3]
            # select answers that are still possible, by seeing if they'd give the same hint when the last guess is guessed against them
            @possible_answers = @possible_answers.select do |possible_answer|
                @all_hints[@last_guess][possible_answer] == last_hint
            end
            # make the current guess that which eliminates the most possible answers in the worst case
            current_guess = self.maximin
            @last_guess = current_guess
            current_guess
        end
    end

    private

    attr_accessor :all_guesses, :last_guess, :parent, :previous_guesses

    def initialize(role, parent)
        @name = "CPU"
        @role = role
        @score = 0
        if @role == "cb"
            # store all possible codes/guesses in an array
            @all_guesses = Array.new
            digits = %w[1 2 3 4 5 6]
            digits.repeated_permutation(4) {|permutation| @all_guesses.push(permutation)}
            # store all possible scores for each guess/code combination in a hash
            @all_hints = Hash.new {|h, k| h[k] = {}}
            @all_guesses.product(@all_guesses) do |guess, answer|
                @all_hints[guess][answer] = self.get_hint(guess, answer)
            end
            # necessary later
            @possible_answers = @all_guesses.clone
            @parent = parent
            @previous_guesses = [%w[1 1 2 2]]
        end
    end

    def get_hint(guess, maybe_code)
        hint = Array.new(4)
        guess.each_index do |column|
            if guess[column] == maybe_code[column]
                hint[column] = "b"
            elsif guess.any?(maybe_code[column])
                hint[column] = "w"
            else
                hint[column] = "o"
            end
        end
        hint
    end

    def maximin
        guesses_by_min_score = Array.new
        # retain only valid codes for increased speed
        @all_hints.each do |guess, scores_by_code|
            scores_by_code = scores_by_code.select {|potential_code, hint| @possible_answers.include?(potential_code)}
            @all_hints[guess] = scores_by_code
        end
        # find out how many possible answers each possible hint for this guess would eliminate, store the worst case number eliminated
        @all_hints.each do |guess, scores_by_code|
            lowest_score = nil
            scores_by_code.each do |code, hint|
                score = 0
                @possible_answers.each do |answer|
                    unless @all_hints[guess][answer] == hint
                        score += 1
                    end
                end
                if lowest_score == nil || lowest_score < score
                    lowest_score = score 
                end
            end
            guesses_by_min_score.push([guess, lowest_score])
        end
        # highest scores will be at the end of the array
        guesses_by_min_score.sort_by! {|guess_score| guess_score[1]}
        # Reduce to just the tied highest scores
        highest_score = guesses_by_min_score[guesses_by_min_score.length - 1][1]
        maximin_scores = guesses_by_min_score.select {|score_array| score_array[1] == highest_score}
        # eliminate previous guesses
        maximin_scores = self.eliminate_previous(maximin_scores, @previous_guesses)
        if maximin_scores.any? {|score_array| @possible_answers.include?(score_array[0])}
            # If there are any that are valid guesses, eliminate all others
            valid_scores = maximin_scores.select {|score_array| @possible_answers.include?(score_array[0])}
            # return the lowest valid guess
            valid_scores.sort_by! {|element| element[0]}
            @previous_guesses.push(valid_scores[0][0])
            valid_scores[0][0]
        else
            # return the lowest valid guess
            maximin_scores.sort_by! {|element| element[0]}
            @previous_guesses.push(maximin_scores[0][0])
            maximin_scores[0][0]
        end
    end

    def eliminate_previous(array_to_check, previous_guesses)
        a = array_to_check.select do |element|
            !(@previous_guesses.include?(element[0]))
        end
    end
end

test = Game.new
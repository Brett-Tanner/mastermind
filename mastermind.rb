# TODO: for the computer code, put it in the computer player class and call the exisiting game functions from there, so you have a reason to actually think about public and private functions. Maybe also move some of the exisiting functions into the human class if you think that makes sense after

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
        self.set_code
    end

    def get_player_name(player_num)
        puts "Player #{player_num}, what's your name? Enter 'CPU' to create a computer player"
        gets.chomp.upcase
    end

    def get_player_role(player_name)
        puts "#{player_name}, what's your role? (CM or CB)"
        gets.chomp.downcase
    end

    def create_player(player_name, player_role)
        if player_name == "CPU"
            Computer.new(player_role, self)
        else
            Human.new(player_name, player_role)
        end
    end

    def set_code
        puts "#{self.role?("cm").name}, set your code"
        @code = gets.chomp
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

    #TODO: add computer guessing
    def make_guess(guessing_player)
        if guessing_player.name == "CPU"
            guess = guessing_player.computer_guess
        else
            puts "#{guessing_player.name}, what do you think the code is?"
            guess = gets.chomp
            unless self.is_valid?(guess)
                self.make_guess(guessing_player)
                return
            end
        end
        
        guess = guess.split(//)

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
        @code.each_index do |column|
            if @code[column] == guess[column]
                puts "Digit #{column} is exactly right!"
                @board[@guess_number][column] = "b"
            elsif @code.any?(guess[column])
                puts "Digit #{column} is right, but in the wrong place!"
                @board[@guess_number][column] = "w"
            else
                puts "Digit #{column} isn't part of the code"
            end
            @board[@guess_number][column + 5] = guess[column]
        end
    end

    def end_round
        self.print_board
        @guess_number += 1
        if @guess_number > 11
            puts "Oh no, you're out of guesses! The code was #{@code.join}"
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
    
    attr_accessor :role, :name, :score, :guess_array, :last_guess
    
    def computer_guess
        if @parent.guess_number == 0
            @last_guess = %w[1 1 2 2]
            "1122"
        else
            @valid_guesses = self.eliminate_guesses
            current_guess = self.maximin
            @last_guess = current_guess
            current_guess
        end
    end

    private

    def initialize(role, parent)
        @name = "CPU"
        @role = role
        @score = 0
        if @role == "cb"
            @guess_array = Array.new
            digits = %w[1 2 3 4 5 6]
            digits.permutation(4) {|permutation| @guess_array.push(permutation)}
            @parent = parent
            @valid_guesses = Array.new
        end
    end

    def eliminate_guesses
        @guess_array.select {|guess| self.possible?(guess)}
    end

    def possible?(guess)
        last_hint = @parent.board[@parent.guess_number - 1][0..3]
        this_hint = Array.new(4)
        guess.each_index do |column|
            if guess[column] == @last_guess[column]
                this_hint[column] = "b"
            elsif guess.any?(@last_guess[column])
                this_hint[column] = "w"
            else
                this_hint[column] = "o"
            end
        end
        last_hint == this_hint
    end


    # (node, depth, maximizing player - boolean) node: where we are in game - eliminated possibilities, last guess, score. Depth: how far ahead we look (1 guess 1 score so 2, depth is stopping condition when it reaches 0). CB is minimizing player, cm is maximizing player

    # if node == 0 return minimum of maximum remaining possibilities (break ties with valid or invalid, then smallest number)
    def maximin
        
    end
end

test = Game.new
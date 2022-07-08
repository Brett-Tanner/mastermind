# TODO: persist score between each game, do stuff with number of rounds

    # codemaker module

        # chooses 4 colored pegs (if comp they're random)

        # gains a point each time the codebreaker guesses incorrectly, plus one more if they run out of turns

    # codebreaker module

        # tries to guess order/color (by placing colored pegs in 4 large holes)

        # checks against codemaker's choice (black small peg for color and position correct, white peg is the right color in the wrong place)

        # guess until all rows are full

class Game

    private

    attr_accessor :player1, :player2, :num_of_rounds, :board, :players, :code, :guess_number
    
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

        puts "Best of _?"
        @num_of_rounds = gets.chomp.to_i
        
        # needs to be initilialized as an array so the clear in .new_board doesn't throw an error
        @board = Array.new
        @guess_number = 0
        self.set_code
    end

    def get_player_name(player_num)
        puts "Player #{player_num}, what's your name? Enter 'CPU' to create a computer player"
        gets.chomp
    end

    def get_player_role(player_name)
        puts "#{player_name}, what's your role? (CM or CB)"
        gets.chomp.downcase
    end

    def create_player(player_name, player_role)
        if player_role == "CPU"
            Computer.new(player_role)
        else
            Human.new(player_name, player_role)
        end
    end

    def set_code
        @players.each do |player|
            if player.role == "cm"
                puts "#{player.name}, set your code"
                @code = gets.chomp
                unless self.is_valid?(@code)
                    self.set_code
                    return 
                end
            end
        end

        @code = @code.split(//)

        self.new_board
        if @player1.role == "cb"
            self.make_guess(@player1)
        else
            self.make_guess(@player2)
        end
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
        puts "#{guessing_player.name}, what do you think the code is?"
        guess = gets.chomp
        unless self.is_valid?(guess)
            self.make_guess(guessing_player)
            return
        end

        guess = guess.split(//)

        if guess == @code
            puts "Congratulations #{guessing_player.name}, you got it!"
            exit(0)
        end

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

        

        self.print_board
        puts "#{12 - @guess_number} guesses remaining"
        @guess_number += 1
        while @guess_number < 12
            self.make_guess(guessing_player)
        end
    end
end

class Human
    
    attr_accessor :role, :name

    private

    def initialize(name, role)
        @name = name
        @role = role
    end
end

class Computer
    
    attr_accessor :role, :name
    
    private

    def initialize(role)
        @name = "CPU"
        @role = role
    end
end

test = Game.new
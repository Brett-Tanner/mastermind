# TODO: persist score between each game, do stuff with number of rounds

class Game

    private

    @@BLANK_HINTS = ["o", "o", "o", "o", "|"]
    @@BLANK_ROW = ["0", "0", "0", "0"]

    attr_accessor :player1, :player2, :num_of_rounds, :board, :players, :code
    
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
        @board = []
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
                if @code.length == 4
                    @code = @code.to_i
                else
                    puts "***The code must be 4 digits***"
                    self.set_code
                    return
                end
            end
        end
        self.new_board
    end

    def new_board
        @board.clear
        12.times {@board.push([@@BLANK_HINTS, @@BLANK_ROW])}
        self.print_board
    end

    def print_board
        @board.each {|value| puts value.join("  ")}
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


# can you include and exclude modules through a method????

    # codemaker module

        # chooses 4 colored pegs (if comp they're random)

        # gains a point each time the codebreaker guesses incorrectly, plus one more if they run out of turns


    # codebreaker module

        # tries to guess order/color (by placing colored pegs in 4 large holes)


        # checks against codemaker's choice (black small peg for color and position correct, white peg is the right color in the wrong place)

        # guess until all rows are full

test = Game.new
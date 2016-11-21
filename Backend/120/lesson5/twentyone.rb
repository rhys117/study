module UI
  def clear_screen
    system('clear') || system('cls')
  end

  def ps(msg)
    puts "--> #{msg}"
  end

  def line_break
    puts ''
  end

  def line
    puts "----------------------------------"
  end

  def sleep_message(msg)
    if msg.length.positive?
      sleep 0.5
      ps msg
      sleep 1.5
    end
  end

  def joiner(array, char=', ', word='and')
    if array.size > 1
      last_part_string = " #{word} #{array.last}"
      first_part_string = array[0..-2].join(char)
      joined_string = first_part_string + last_part_string
    else
      joined_string = array[0].to_s
    end
    joined_string
  end
end

class Participant
  attr_accessor :cards
  attr_reader :name

  def initialize
    set_name
  end

  def set_name
    @name = 'Player'
  end

  def score
    score = cards.map(&:value).inject(:+)
    cards.select { |card| card.face == 'Ace' }.count.times do
      score -= 10 if score > 21
    end
    score
  end

  def bust?
    score > 21
  end
end

class Player < Participant
  include UI

  attr_reader :chips

  def initialize
    set_name
    @chips = Chips.new
  end

  def set_name
    name = ''

    loop do
      ps "What's your name?"
      name = gets.chomp.strip
      break unless name.empty?
      ps "Whoops! you must have a name!"
    end
    @name = name
  end
end

class Dealer < Participant
  def initialize
    @name = 'Dealer'
  end
end

class Deck
  attr_accessor :cards

  def initialize
    @cards = new_pack
  end

  def new_pack
    cards = []
    52.times do |num|
      cards << Card.new(num)
    end
    cards
  end

  def random_card!
    @cards.delete_at(rand(@cards.length))
  end

  def two_cards
    dealt_cards = []
    2.times { dealt_cards << random_card! }
    dealt_cards
  end

  def refresh
    @cards = new_pack
  end

  def hit(player)
    player.cards << random_card!
  end
end

class Card
  SUITES = %w(Diamonds Hearts Spades Clubs).freeze
  FACES = %w(2 3 4 5 6 7 8 9 10 Jack Queen King Ace).freeze
  DECK_VALUES = SUITES.product(FACES)

  attr_reader :suit, :face, :value

  def initialize(num)
    @card_index = num
    @suit = find_suit
    @face = find_face
    @value = find_value
  end

  def find_value
    case @face
    when "Ace"
      11
    when "Jack", "Queen", "King"
      10
    else
      @face.to_i
    end
  end

  def find_suit
    DECK_VALUES[@card_index][0]
  end

  def find_face
    DECK_VALUES[@card_index][1]
  end

  def to_s
    "#{@face} of #{@suit}"
  end
end

class Chips
  include UI
  attr_accessor :total, :bet

  INITIAL_CHIP_COUNT = 25

  def initialize
    @total = INITIAL_CHIP_COUNT
    @bet = 0
  end

  def set_bet_amount
    clear_screen
    line
    ps "You have #{@total} chips"
    loop do
      ps "How many would you like to bet?"
      @bet = gets.chomp.to_i
      break if chips_bet_valid?
      ps "Whoops! you must choose a valid amount. "\
         "You have #{@total} chips"
    end
    @total -= @bet
    clear_screen
  end

  def chips_bet_valid?
    return true if @bet <= @total && @bet.positive?
    false
  end

  def winnings
    @bet * 2
  end

  def to_s
    @total.to_s
  end

  def no_chips?
    @total.zero?
  end

  def reset
    @total = INITIAL_CHIP_COUNT
  end

  def update_total(winner)
    @total = case winner
             when :player
               @total + winnings
             when :dealer
               @total
             when :tie
               @total + @bet
             end
  end
end

class TwentyOneGame
  STOPPING_SCORE = 17

  include UI

  attr_accessor :human, :dealer, :deck

  def initialize
    clear_screen
    welcome_message
    @human = Player.new
    @dealer = Dealer.new
    @deck = Deck.new
  end

  def play
    loop do
      if human.chips.no_chips?
        break unless play_again?
        human.chips.reset
      end
      deal_and_player_turn
      dealer_turn unless human.bust?
      show_winner_and_update_result
      deck.refresh
    end
    goodbye_message
  end

  private

  def deal_and_player_turn
    human.chips.set_bet_amount
    deal_cards
    show_hand_with_hidden
    player_turn
  end

  def show_winner_and_update_result
    winner = who_won
    show_result(winner)
    human.chips.update_total(winner)
    sleep 2
  end

  def welcome_message
    line
    ps "Welcome to 21!"
    line
  end

  def goodbye_message
    ps "Thanks for playing 21!"
  end

  def deal_cards
    human.cards = deck.two_cards
    dealer.cards = deck.two_cards
  end

  def play_again?
    clear_screen
    line
    ps "Sorry! You're out of chips. The dealer has taken you for everything!!"
    answer = ''
    loop do
      ps "Would you like to play again? (y/n)"
      answer = gets.chomp.downcase.strip
      break if ['y', 'n', 'q'].include?(answer)
      ps "Sorry, must choose y for yes or n for no."
    end
    answer == 'y'
  end

  def human_hand_and_bet
    ps "#{human.name} has #{joiner(human.cards)}"
    ps "Score: #{human.score}"
    ps "Betting: #{human.chips.bet}"
    line
  end

  def show_hand_with_hidden
    human_hand_and_bet
    ps "Dealer has #{dealer.cards.first} and a hidden card"
    ps "Score: #{dealer.cards.first.value} + ?"
    line
  end

  def show_hands
    human_hand_and_bet
    ps "Dealer has #{joiner(dealer.cards)}"
    ps "Score: #{dealer.score}"
    line
  end

  def who_won
    if human.bust?
      :dealer
    elsif dealer.bust?
      :player
    elsif human.score > dealer.score
      :player
    elsif human.score == dealer.score
      :tie
    else
      :dealer
    end
  end

  def show_result(winner)
    human_name = human.name
    dealer_name = dealer.name

    if human.bust?
      ps "#{human_name} Busted! #{dealer_name} Wins!"
    elsif dealer.bust?
      ps "#{dealer_name} Busted! #{human_name} Wins!"
    elsif winner == :tie
      ps "It's a draw!"
    elsif winner == :player
      ps "#{human_name} Won!"
    else
      ps "#{dealer_name} Won!"
    end
  end

  def hit_or_stay
    answer = nil
    loop do
      ps "Would you like to (H)it or (S)tay. (Q)uit"
      answer = gets.chomp.downcase
      break if ['h', 's'].include?(answer)
      quit if answer == 'q'
      ps "Sorry must select either H for Hit or S for Stay"
    end
    answer
  end

  def quit
    goodbye_message
    exit
  end

  def player_turn
    loop do
      answer = hit_or_stay
      deck.hit(human) if answer == 'h'
      clear_screen
      show_hand_with_hidden
      break if answer == 's' || human.bust?
    end
  end

  def hit_until_stopping_score
    loop do
      clear_screen
      show_hands
      sleep 1
      if dealer.score < STOPPING_SCORE
        deck.hit(dealer)
        ps "Dealer Hits!"
        sleep 1
      end
      break if dealer.bust? || dealer.score >= STOPPING_SCORE
    end
  end

  def dealer_turn
    hit_until_stopping_score
    clear_screen
    show_hands
    ps "Dealer Holds"
    line
    sleep 1
  end
end

TwentyOneGame.new.play
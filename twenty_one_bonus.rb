# rubocop:disable  Metrics/MethodLength, Metrics/BlockLength, Style/MutableConstant, Style/FrozenStringLiteralComment, Style/PercentLiteralDelimiters, Style/RedundantReturn
SUIT = %w(H D S C)
VALUE = %w(2 3 4 5 6 7 8 9 10 J Q K A)
CARDS_WORTH_10 = %w(10 J Q K)
CARDS_WORTH_FACE = %w(2 3 4 5 6 7 8 9)
DEALER_POINT_MIN = 17
POINT_GOAL_MAX = 21
GRAND_WINNING_SCORE = 5

def initialize_deck!(deck)
  number_of_cards = 0
  suit_idx = 0

  while suit_idx < 4
    VALUE.size.times do |val_idx|
      deck[number_of_cards] = [SUIT[suit_idx], VALUE[val_idx]]
      number_of_cards += 1
    end
    suit_idx += 1
  end
  deck
end

def remove_card!(card, deck)
  deck.delete(card)
end

def deal_cards!(person_hand, deck)
  card1 = deck.sample
  person_hand[0] = card1
  remove_card!(card1, deck)
  card2 = deck.sample
  person_hand[1] = deck.sample
  remove_card!(card2, deck)
end

def cards_score(person_hand)
  person_points = 0
  values = person_hand.map { |card| card[1] }

  values.each do |value|
    if CARDS_WORTH_10.include?(value)
      person_points += 10
    elsif CARDS_WORTH_FACE.include?(value)
      person_points += value.to_i
    else # its an ace
      person_points += 11
    end
  end

  values.select { |value| value == 'A' }.count.times do
    person_points -= 10 if person_points > POINT_GOAL_MAX
  end

  person_points
end

def busted?(person_points)
  person_points > POINT_GOAL_MAX
end

def player_hit!(deck, players_hand)
  system 'clear'
  new_card = deck.sample
  remove_card!(deck, new_card)
  players_hand << new_card
  new_points = cards_score(players_hand)
  puts "You got a #{new_card} and now have #{new_points}"
  new_points
end

def dealer_hit!(deck, dealers_hand)
  new_card = deck.sample
  remove_card!(deck, new_card)
  dealers_hand << new_card
  new_points = cards_score(dealers_hand)
  puts "The dealer hit and got a #{new_card} and now has #{new_points}"
  new_points
end

def determine_winner(player_points, dealer_points)
  if busted?(dealer_points)
    'Player'
  elsif busted?(player_points)
    'Dealer'
  elsif dealer_points > player_points
    'Dealer'
  else
    'Player'
  end
end

def display_scores(player_points, dealer_points)
  puts "You have #{player_points}"
  puts "The dealer has #{dealer_points}"
end

def display_winner(winner)
  puts "#{winner} won the hand!!"
end

def end_of_round_display(player_points, dealer_points)
  display_scores(player_points, dealer_points)
  display_winner(determine_winner(player_points, dealer_points))
end

def play_again?
  puts 'Play again? (y or n)'
  answer = gets.chomp
  answer.start_with?('y')
end

def reset_hands!(players_hand, dealers_hand)
  players_hand.pop until players_hand.empty?

  dealers_hand.pop until dealers_hand.empty?
end

def detect_grand_winner(player_rounds_won, dealer_rounds_won)
  if player_rounds_won == GRAND_WINNING_SCORE
    'Player'
  elsif dealer_rounds_won == GRAND_WINNING_SCORE
    'Dealer'
  end
end

def display_grand_winner(winner)
  puts "#{winner} won #{GRAND_WINNING_SCORE} rounds and is the grand winner!!"
end

def reset_rounds_won
  return 0, 0
end

deck = []
players_hand = []
dealers_hand = []
player_rounds_won = 0
dealer_rounds_won = 0

loop do
  system 'clear'
  initialize_deck!(deck)
  reset_hands!(players_hand, dealers_hand)
  deal_cards!(players_hand, deck)
  deal_cards!(dealers_hand, deck)
  player_points = cards_score(players_hand)
  dealer_points = cards_score(dealers_hand)

  puts "Your cards are: #{players_hand} which add up to #{player_points}"
  puts "The dealer has #{dealers_hand[0]} and a mystery card"

  answer = nil
  loop do
    puts 'Hit or stay?'
    answer = gets.chomp
    break if answer == 'stay' || busted?(player_points)

    player_points = player_hit!(deck, players_hand)
    break if busted?(player_points)
  end

  system 'clear'

  if busted?(player_points)
    puts 'You busted!'
    end_of_round_display(player_points, dealer_points)
    dealer_rounds_won += 1
    if detect_grand_winner(player_rounds_won, dealer_rounds_won)
      display_grand_winner(detect_grand_winner(player_rounds_won, dealer_rounds_won))
      player_rounds_won, dealer_rounds_won = reset_rounds_won
    end
    play_again? ? next : break
  else
    puts 'You chose to stay!'
  end

  system 'clear'

  loop do
    break if dealer_points >= DEALER_POINT_MIN

    dealer_points = dealer_hit!(deck, dealers_hand)
  end

  if busted?(dealer_points)
    puts 'The dealer busted!'
    end_of_round_display(player_points, dealer_points)
    player_rounds_won += 1
    if detect_grand_winner(player_rounds_won, dealer_rounds_won)
      display_grand_winner(detect_grand_winner(player_rounds_won, dealer_rounds_won))
      player_rounds_won, dealer_rounds_won = reset_rounds_won
    end
    play_again? ? next : break
  else
    end_of_round_display(player_points, dealer_points)

    if determine_winner(player_points, dealer_points) == 'Player'
      player_rounds_won += 1
    elsif determine_winner(player_points, dealer_points) == 'Dealer'
      dealer_rounds_won += 1
    end

    if detect_grand_winner(player_rounds_won, dealer_rounds_won)
      display_grand_winner(detect_grand_winner(player_rounds_won, dealer_rounds_won))
      player_rounds_won, dealer_rounds_won = reset_rounds_won
    end

    break unless play_again?
  end
end

system 'clear'
puts 'Thanks for playing, bye!'
# rubocop:enable  Metrics/MethodLength, Metrics/BlockLength, Style/MutableConstant, Style/FrozenStringLiteralComment, Style/PercentLiteralDelimiters, Style/RedundantReturn

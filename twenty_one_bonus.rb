SUIT = %w(H D S C)
VALUE = %w(2 3 4 5 6 7 8 9 10 J Q K A)
CARDS_WORTH_10 = %w(10 J Q K)
CARDS_WORTH_FACE = %w(2 3 4 5 6 7 8 9)
DEALER_POINT_MIN = 17
POINT_GOAL_MAX = 21
GRAND_WINNING_SCORE = 5
RULES = "Rules:
- Each player is dealt 2 cards.
- You can see your 2 cards but only see one of the dealers cards.
- The goal is to get as close to #{POINT_GOAL_MAX} without going over.
- If you go over #{POINT_GOAL_MAX} that means you bust.
- If you bust and the dealer doesn't bust, then the dealer wins the round.
- If the dealer busts, you win the round!
- If neither player busts then the player closest to #{POINT_GOAL_MAX}
  wins the round, with ties favoring the player.
- The first player to win 5 rounds is the grand winner!"

def prompt(message)
  puts "=> #{message}"
end

def display_welcome_rules
  system 'clear'
  prompt 'Welcome to Blackjack!'
  prompt 'Can you beat the dealer?'
  prompt RULES
  answer = nil
  loop do
    prompt 'Enter "start" to begin:'
    answer = gets.chomp.downcase
    break if answer == 'start'
    prompt 'Invalid input'
  end
  system 'clear' if answer == 'start'
end

def display_card(card)
  puts '+-------+'
  puts "|#{card[0]}      |"
  puts '|       |'
  if card[1].size > 1
    puts "|  #{card[1]}   |"
  else
    puts "|   #{card[1]}   |"
  end
  puts '|       |'
  puts "|      #{card[0]}|"
  puts '+-------+'
end

def display_initial_hands(players_hand, dealers_hand, hand_totals)
  prompt 'Your cards are:'
  display_card(players_hand[0])
  display_card(players_hand[1])
  prompt "Which add up to #{hand_totals[:player_points]}"
  puts ""
  prompt 'The dealer has a mystery card and:'
  display_card(dealers_hand[0])
end

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
    person_points += if CARDS_WORTH_10.include?(value)
                       10
                     elsif CARDS_WORTH_FACE.include?(value)
                       value.to_i
                     else
                       11
                     end
  end

  values.select { |value| value == 'A' }.count.times do
    person_points -= 10 if person_points > POINT_GOAL_MAX
  end

  person_points
end

def prompt_hit_or_stay
  answer = nil
  loop do
    prompt 'Hit or stay? (enter "h" or "s")'
    answer = gets.chomp.downcase
    break if answer == 'h' || answer == 's'
    prompt 'Invalid input'
  end
  answer
end

def busted?(hand_totals, player)
  hand_totals[player] > POINT_GOAL_MAX
end

def player_hit!(deck, players_hand)
  prompt 'You hit and got this card:'
  new_card = deck.sample
  remove_card!(deck, new_card)
  players_hand << new_card
  new_points = cards_score(players_hand)
  display_card(new_card)
  prompt "You now have #{new_points}"
  new_points
end

def dealer_hit!(deck, dealers_hand)
  prompt 'The dealer hit and got this card:'
  new_card = deck.sample
  remove_card!(deck, new_card)
  dealers_hand << new_card
  new_points = cards_score(dealers_hand)
  display_card(new_card)
  prompt "Dealer now has #{new_points}"
  new_points
end

def determine_winner(hand_totals)
  if busted?(hand_totals, :dealer_points)
    'Player'
  elsif busted?(hand_totals, :player_points)
    'Dealer'
  elsif hand_totals[:dealer_points] > hand_totals[:player_points]
    'Dealer'
  else
    'Player'
  end
end

def display_winner(winner)
  prompt "#{winner} won the hand!!"
end

def display_scores(hand_totals)
  prompt "You have #{hand_totals[:player_points]}"
  prompt "The dealer has #{hand_totals[:dealer_points]}"
end

def display_hand_totals(hand_totals)
  display_scores(hand_totals)
  display_winner(determine_winner(hand_totals))
end

def display_round_scores(round_scores)
  prompt "You: #{round_scores[:player_rounds_won]}"
  prompt "Dealer: #{round_scores[:dealer_rounds_won]}"
  if detect_grand_winner(round_scores)
    display_grand_winner(detect_grand_winner(round_scores))
    reset_round_scores!(round_scores)
  end
end

def display_grand_winner(winner)
  prompt "#{winner} won #{GRAND_WINNING_SCORE} rounds and is the grand winner!!"
end

def detect_grand_winner(round_scores)
  if round_scores[:player_rounds_won] == GRAND_WINNING_SCORE
    'Player'
  elsif round_scores[:dealer_rounds_won] == GRAND_WINNING_SCORE
    'Dealer'
  end
end

def play_again?
  prompt 'Play again? (y or n)'
  answer = gets.chomp.downcase
  answer.start_with?('y')
end

def reset_hands!(players_hand, dealers_hand)
  players_hand.pop until players_hand.empty?

  dealers_hand.pop until dealers_hand.empty?
end

def reset_round_scores!(round_scores)
  round_scores[:player_rounds_won] = 0
  round_scores[:dealer_rounds_won] = 0
end

def reset_hand_totals!(hand_totals)
  hand_totals.each do |player, _|
    hand_totals[player] = 0
  end
end

deck = []
players_hand = []
dealers_hand = []
hand_totals = { player_points: 0, dealer_points: 0 }
round_scores = { player_rounds_won: 0, dealer_rounds_won: 0 }

display_welcome_rules
loop do
  system 'clear'
  initialize_deck!(deck)
  reset_hands!(players_hand, dealers_hand)
  reset_hand_totals!(hand_totals)

  deal_cards!(players_hand, deck)
  deal_cards!(dealers_hand, deck)
  hand_totals[:player_points] = cards_score(players_hand)
  hand_totals[:dealer_points] = cards_score(dealers_hand)

  display_initial_hands(players_hand, dealers_hand, hand_totals)

  loop do
    break if prompt_hit_or_stay == 's'
    hand_totals[:player_points] = player_hit!(deck, players_hand)
    break if busted?(hand_totals, :player_points)
  end

  if busted?(hand_totals, :player_points)
    prompt 'You busted!'
  else
    prompt 'You chose to stay!'
  end

  sleep(3)
  system 'clear'

  loop do
    break if hand_totals[:dealer_points] >= DEALER_POINT_MIN

    hand_totals[:dealer_points] = dealer_hit!(deck, dealers_hand)
  end

  if busted?(hand_totals, :dealer_points)
    prompt 'The dealer busted, so you win the round!'
  else
    display_hand_totals(hand_totals)
  end

  if determine_winner(hand_totals) == 'Player'
    round_scores[:player_rounds_won] += 1
  elsif determine_winner(hand_totals) == 'Dealer'
    round_scores[:dealer_rounds_won] += 1
  end

  display_round_scores(round_scores)
  break unless play_again?
end

system 'clear'
puts 'Thanks for playing, bye!'

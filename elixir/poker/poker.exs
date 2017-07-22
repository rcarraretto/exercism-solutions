defmodule Card do
  defstruct [:rank, :suit]

  def new(str) do
    {rank, suit} = String.split_at(str, -1)
    %Card{rank: rank_value(rank), suit: suit}
  end

  defp rank_value("A"),  do: 14
  defp rank_value("K"),  do: 13
  defp rank_value("Q"),  do: 12
  defp rank_value("J"),  do: 11
  defp rank_value(rank), do: String.to_integer(rank)
end

defmodule Hand do
  defstruct cards: [], score: 0

  def from_cards(cards) do
    {category, values} = HandCategory.for(cards)
    score = [category_rank(category), values]
    %Hand{cards: cards, score: score}
  end

  defp category_rank(:straight_flush),  do: 9
  defp category_rank(:four_of_a_kind),  do: 8
  defp category_rank(:full_house),      do: 7
  defp category_rank(:flush),           do: 6
  defp category_rank(:straight),        do: 5
  defp category_rank(:three_of_a_kind), do: 4
  defp category_rank(:two_pair),        do: 3
  defp category_rank(:one_pair),        do: 2
  defp category_rank(:high_card),       do: 1
end

defmodule Poker do

  def best_hand(hands) do
    hands
    |> Enum.map(&Hand.from_cards/1)
    |> Enum.sort_by(&(&1.score), &>=/2)
    |> Enum.chunk_by(&(&1.score))
    |> List.first()
    |> Enum.map(&(&1.cards))
  end
end

defmodule HandCategory do

  @five_high_straight [14, 5, 4, 3, 2]

  def for(hand) do
    cards    = hand_to_tuples(hand)
    groups   = group_by_rank(cards)
    category = categorize_groups(groups)
    case category do
      :no_groups -> for_distinct(cards)
      _ -> for_groups(category, groups)
    end
  end

  defp hand_to_tuples(hand) do
    hand |> Enum.map(&Card.new/1) |> Enum.sort(&>=/2)
  end

  defp group_by_rank(cards) do
    cards
    |> Enum.group_by(&(&1.rank))
    |> Enum.map(fn({_rank, cards}) -> {length(cards), cards} end)
    |> Enum.sort(&>=/2)
  end

  defp categorize_groups(groups) do
    case Enum.map(groups, &(elem(&1, 0))) do
      [4, 1]       -> :four_of_a_kind
      [3, 2]       -> :full_house
      [3, 1, 1]    -> :three_of_a_kind
      [2, 2, 1]    -> :two_pair
      [2, 1, 1, 1] -> :one_pair
      _            -> :no_groups
    end
  end

  defp for_groups(category, groups) do
    cards_by_group = Enum.map(groups, &(elem(&1, 1)))
    values = Enum.map(cards_by_group, &(group_value(&1)))
    {category, values}
  end

  defp for_distinct(cards) do
    values = values(cards)
    straight = is_sequence?(values)
    flush = same_suit?(cards)

    category = case [straight, flush] do
      [true, true]  -> :straight_flush
      [true, false] -> :straight
      [false, true] -> :flush
      _             -> :high_card
    end

    values = if straight do
      highest_sequence_value(values)
    else
      values
    end

    {category, values}
  end

  defp is_sequence?(@five_high_straight) do
    true
  end

  defp is_sequence?(values) do
    sequence = List.first(values)..List.last(values) |> Enum.to_list
    values == sequence
  end

  defp same_suit?(cards) do
    cards |> Enum.uniq_by(&(&1.suit)) |> length() == 1
  end

  defp highest_sequence_value(@five_high_straight), do: 5
  defp highest_sequence_value(values),              do: List.first(values)

  defp group_value([card | _cards]), do: card.rank
  defp values(cards), do: Enum.map(cards, &(&1.rank))
end

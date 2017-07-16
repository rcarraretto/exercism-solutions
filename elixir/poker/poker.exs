defmodule Poker do

  @category_ranks %{
    :straight_flush => 1,
    :four_of_a_kind => 2,
    :full_house => 3,
    :flush => 4,
    :straight => 5,
    :three_of_a_kind => 6,
    :two_pair => 7,
    :one_pair => 8,
    :high_card => 9,
  }

  def best_hand([hand]) do
    [hand]
  end

  def best_hand(hands) do
    hands
    |> Enum.map(&with_category/1)
    |> Enum.sort(&compare_categories/2)
    |> filter_bests()
    |> Enum.map(&(elem(&1, 0)))
  end

  defp with_category(hand) do
    category = categorize(hand)
    Tuple.insert_at(category, 0, hand)
  end

  defp compare_categories({_, category, values1}, {_, category, values2}) do
    compare_values(values1, values2)
  end

  defp compare_categories({_, category1, _}, {_, category2, _}) do
    @category_ranks[category1] <= @category_ranks[category2]
  end

  defp compare_values([], []) do
    true
  end

  defp compare_values([value | values1], [value | values2]) do
    compare_values(values1, values2)
  end

  defp compare_values([value1 | _], [value2 | _]) do
    value1 >= value2
  end

  defp filter_bests(categories) do
    best = hd(categories)
    categories
    |> Enum.take_while(fn(category) -> compare_categories(category, best) end)
  end

  def categorize(hand) do
    hand_t = init_hand(hand)
    groups = groups(hand_t)
    categorize_groups(hand_t, groups)
  end

  defp init_hand(hand) do
    hand
    |> hand_to_tuples()
    |> Enum.sort(&compare_cards/2)
  end

  defp hand_to_tuples(hand) do
    hand |> Enum.map(&card_to_tuple/1)
  end

  defp card_to_tuple(card) do
    Regex.run(~r/(.*)([CDHS])/, card, capture: :all_but_first) |> List.to_tuple
  end

  defp groups(hand_t) do
    hand_t
    |> Enum.group_by(fn({rank, _suit}) -> rank end)
    |> Enum.map(fn({_, cards}) -> {length(cards), cards} end)
    |> Enum.sort(fn({length1, _}, {length2, _}) -> length1 >= length2 end)
  end

  defp categorize_groups(_, [{4, quad}, {1, [kicker]}]) do
    quad_value = group_value(quad)
    kicker_value = to_value(kicker)
    { :four_of_a_kind, [quad_value, kicker_value] }
  end

  defp categorize_groups(_, [{3, triplet}, {2, pair}]) do
    triplet_value = group_value(triplet)
    pair_value = group_value(pair)
    { :full_house, [triplet_value, pair_value] }
  end

  defp categorize_groups(_, [{3, triplet}, {1, [card1]}, {1, [card2]}]) do
    triplet_value = group_value(triplet)

    remaining_values = [card1, card2]
    |> Enum.map(&to_value/1)
    |> Enum.sort(&(&1 >= &2))

    { :three_of_a_kind, [triplet_value | remaining_values] }
  end

  defp categorize_groups(_, [{2, pair1}, {2, pair2}, {1, [kicker]}]) do
    values = [pair1, pair2]
    |> Enum.map(&group_value/1)
    |> Enum.sort(&(&1 >= &2))

    kicker = to_value(kicker)

    { :two_pair, values ++ [kicker] }
  end

  defp categorize_groups(_, [{2, pair} | _]) do
    value = group_value(pair)
    { :one_pair, [value] }
  end

  defp categorize_groups(hand_t, _) do
    sorted_values = hand_t |> Enum.map(&to_value/1) |> Enum.sort
    is_same_suit = same_suit?(hand_t)
    is_sequence = is_sequence?(sorted_values)
    cond do
      is_same_suit and is_sequence -> as_straight(:straight_flush, sorted_values)
      is_same_suit -> { :flush, sorted_values |> Enum.reverse }
      is_sequence -> as_straight(:straight, sorted_values)
      true -> { :high_card, sorted_values |> Enum.reverse }
    end
  end

  defp same_suit?(hand_t) do
    hand_t
    |> Enum.group_by(fn({_, suit}) -> suit end)
    |> Map.keys()
    |> length() == 1
  end

  defp is_sequence?(sorted_values) do
    sequences = sequences(sorted_values)
    Enum.any?(sequences, &(&1 == sorted_values))
  end

  defp sequences([low, _, _, penultimate, 14]) do
    start_with_ace = low..penultimate |> Enum.to_list |> List.insert_at(-1, 14)
    end_with_ace = low..14 |> Enum.to_list
    [start_with_ace, end_with_ace]
  end

  defp sequences(sorted_values) do
    sequence = Enum.at(sorted_values, 0)..Enum.at(sorted_values, 4) |> Enum.to_list
    [sequence]
  end

  def as_straight(category, sorted_values) do
    high = case List.last(sorted_values) do
      14 -> if List.first(sorted_values) == 2, do: 5, else: 14
      high -> high
    end
    { category, [high] }
  end

  defp group_value(group) do
    group |> hd() |> elem(0) |> rank_value
  end

  defp compare_cards({rank1, _}, {rank2, _}) do
    rank_value(rank1) >= rank_value(rank2)
  end

  defp rank_value("J"), do: 11
  defp rank_value("Q"), do: 12
  defp rank_value("K"), do: 13
  defp rank_value("A"), do: 14
  defp rank_value(rank), do: String.to_integer(rank)

  defp to_value({rank, _}) do
    rank_value(rank)
  end
end

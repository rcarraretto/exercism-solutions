# Elixir v1.5.1
defmodule Bowling do
  defstruct active: nil, played: [], pending: []

  defmodule Frame do
    defstruct id: nil, type: :active, rolls: []
  end

  def start do
    active = %Frame{id: 1}
    pending = Enum.to_list(2..10) |> Enum.map(&(%Frame{id: &1}))
    %Bowling{active: active, pending: pending}
  end

  def roll(_game, roll) when roll < 0 do
    {:error, "Negative roll is invalid"}
  end

  def roll(_game, roll) when roll > 10 do
    {:error, "Pin count exceeds pins on the lane"}
  end

  def roll(game, roll) do
    frame = game.active
    case roll_in_frame(frame, roll) do
      :error        -> {:error, "Pin count exceeds pins on the lane"}
      updated_frame -> update_game(game, updated_frame)
    end
  end

  defp roll_in_frame(frame, 10) do
    %{frame | type: :strike, rolls: [10]}
  end

  defp roll_in_frame(frame = %Frame{rolls: [roll1]}, roll2) do
    rolls = [roll1, roll2]
    if Enum.sum(rolls) <= 10 do
      type = if Enum.sum(rolls) == 10, do: :spare, else: :open
      %{frame | type: type, rolls: rolls}
    else
      :error
    end
  end

  defp roll_in_frame(frame, roll1) do
    %{frame | rolls: [roll1]}
  end

  defp update_game(game, frame = %Frame{type: :active}) do
      %{game | active: frame}
  end

  defp update_game(game, frame = %Frame{id: 10}) do
    %{game |
      active: %Frame{id: :bonus},
      pending: [],
      played: [frame | game.played],
    }
  end

  defp update_game(game, frame = %Frame{id: :bonus}) do
    %{game |
      active: %Frame{id: :bonus},
      pending: [],
      played: [frame | game.played],
    }
  end

  defp update_game(game, frame) do
    %{game |
      active: hd(game.pending),
      pending: tl(game.pending),
      played: [frame | game.played],
    }
  end

  def score(game) do
    _score(Enum.reverse([game.active | game.played]), 0)
  end

  defp _score([], score) do
    score
  end

  defp _score([frame = %Frame{id: :bonus} | frames], score) do
    _score(frames, score + Enum.sum(frame.rolls))
  end

  defp _score([frame = %Frame{id: 10} | frames], score) do
    _score(frames, score + Enum.sum(frame.rolls))
  end

  defp _score([%Frame{type: :strike} | frames], score) do
    next_rolls = frames
    |> Enum.map(&(&1.rolls))
    |> List.flatten
    |> Enum.take(2)
    frame_score = 10 + Enum.sum(next_rolls)
    _score(frames, score + frame_score)
  end

  defp _score([frame, next | frames], score) do
    frame_score = Enum.sum(frame.rolls)
    frame_score = case frame_score do
      10 -> frame_score + hd(next.rolls)
      _  -> frame_score
    end
    _score([next | frames], score + frame_score)
  end
end

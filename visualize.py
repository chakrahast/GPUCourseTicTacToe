def parse_boards(filename):
    boards = []
    current = []

    with open(filename) as f:
        for line in f:
            line = line.strip()

            if line == "-----":
                if current:
                    boards.append(current)
                    current = []
            elif line and not line.startswith("Player"):
                current.append(line.split())

    return boards


def format_row(row):
    return " | ".join(row)


def center_text(text, width):
    padding = width - len(text)
    left = padding // 2
    right = padding - left
    return " " * left + text + " " * right


def render_chunk(boards, start_idx, chunk_size, cell_width, gap):
    chunk = boards[start_idx:start_idx + chunk_size]

    # HEADER
    header = ""
    for i in range(len(chunk)):
        label = "Move {}".format(start_idx + i + 1)
        header += center_text(label, cell_width) + " " * gap
    print(header)
    print("")

    # BOARD ROWS
    for row_idx in range(len(chunk[0])):
        line = ""
        for board in chunk:
            row_str = format_row(board[row_idx])
            line += center_text(row_str, cell_width) + " " * gap
        print(line)

    # PLAYER LINE
    player_line = ""
    for i in range(len(chunk)):
        move_num = start_idx + i
        if move_num % 2 == 0:
            player = "GPU1 (X)"
        else:
            player = "GPU2 (O)"
        player_line += center_text(player, cell_width) + " " * gap

    print("")
    print(player_line)

    # SEPARATOR
    total_width = (cell_width + gap) * len(chunk)
    print("")
    print("-" * total_width)
    print("")


def show():
    boards = parse_boards("output.txt")

    print("")
    print("=== TIC TAC TOE GAME (HORIZONTAL VIEW) ===")
    print("")

    cell_width = 15
    gap = 4
    chunk_size = 6

    total = len(boards)

    for start in range(0, total, chunk_size):
        render_chunk(boards, start, chunk_size, cell_width, gap)

    # RESULT
    with open("output.txt") as f:
        for line in f:
            if line.startswith("Player"):
                print(line.strip())


if __name__ == "__main__":
    show()
import sys


if __name__ == "__main__":
    if len(sys.argv) != 3:
        raise ValueError("Need a filename and #points_per_day")
    file_name = sys.argv[1]
    points_per_day = int(sys.argv[2])
    file_lines = []
    with open(file_name, 'r') as f:
        for i, line in enumerate(f.readlines()):
            string_to_add = str(i//points_per_day)
            point = line.strip().split(",")[:2]
            file_lines.append(','.join(point + [string_to_add + '\n']))

    with open(file_name, 'w') as f:
        f.writelines(file_lines)
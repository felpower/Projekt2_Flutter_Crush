# Adjusting the level generation to ensure xDim and yDim are between 7 and 16, and their difference is no more than 2
import json
import random


def generate_levels(num_new_levels, max_dim, min_dim, types, colors):
	new_levels = []
	for i in range(1, num_new_levels + 1):
		level_type = types[(i - 1) % len(types)]  # Rotate through level types

		# Calculate dimensions, ensuring they are within the specified range and difference
		x_dim = min(max(min_dim + ((i - 1) // len(types)), min_dim), max_dim)
		y_dim = min(max(x_dim - 2, min_dim), max_dim)  # Ensure yDim is within 2 of xDim, but also within bounds

		# Choose between 1-4 colors randomly for the obstacleTypes
		obstacle_types = random.sample(colors, random.randint(1, 4))
		num_obstacles = random.randint(5, 30)
		new_level = {
			"level": i,
			"type": level_type,
			"xDim": x_dim,
			"yDim": y_dim,
			"numMoves": 20 + 5 * ((i - 1) // len(types)),
			"score1": 1000 + 1000 * ((i - 1) // len(types)),
			"score2": 1500 + 1000 * ((i - 1) // len(types)),
			"score3": 2000 + 1000 * ((i - 1) // len(types)),
			"targetScore": 2000 + 1000 * ((i - 1) // len(types)),
			"timeInSeconds": 60 + 10 * ((i - 1) // len(types)),
			"numOfObstacles": num_obstacles,
			"obstacleTypes": obstacle_types
		}
		new_levels.append(new_level)
	return new_levels


# Generating 50 new levels with the corrected specifications#
num_levels_to_generate = 501
max_dimension = 10
min_dimension = 6
level_types = ["Timer", "Colors", "Moves", "Obstacle"]
obstacle_colors = ["Blue", "Purple", "Pink", "Green", "Yellow", "Red"]
adjusted_levels = generate_levels(num_levels_to_generate, max_dimension, min_dimension, level_types,
                                  obstacle_colors)

# Convert to JSON and save to a file
adjusted_json_data = json.dumps({"levels": adjusted_levels}, indent=4)
adjusted_file_path = "unityLevels_generated.json"
with open(adjusted_file_path, "w") as file:
	file.write(adjusted_json_data)

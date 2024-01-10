function debug_init() {
	state_grass = new WFCState(1, oGrass);
	state_sand = new WFCState(2, oSand);
	state_water = new WFCState(3, oWater);

	state_grass.add_compatible_state(
	state_sand,
	state_grass,
	);
	state_sand.add_compatible_state(
	state_grass,
	state_sand,
	state_water,
	);
	state_water.add_compatible_state( 
	state_water,
	state_sand,
	);
	
	dungeon = new Dungeon(0, 0, 10);
	dungeon.add_tile_states_dynamically(state_water, state_sand, state_grass);
	
	show_debug_message("Debug init ran succesfully.");
};

function WFCState(_int_rep, _object, _weight = 1) constructor {
	weight = _weight;
	object = _object;
	int_rep = _int_rep;
	compatible_states = ds_list_create()
	
	static add_compatible_state = function() {
		for(var _i = 0; _i < argument_count; _i++) {
			ds_list_add(compatible_states, argument[_i]);
		}
	}
}

function DungeonCell(_xpos, _ypos, _max_index) constructor {
	max_index = _mad_index
	_x = _xpos;
	_y = _ypos;
	possible_states = ds_list_create();
	neighbours = ds_list_create();
	entropy = 0;
	state = noone;
	assigned = false;
	
	static update_entropy = function(_uniform = true) {
		if _uniform {
			entropy = calculate_uniform_entropy(possible_states);
		} else {
			entropy = calculate_non_uniform_entropy(possible_states)	
		}
	}
	
	static append_state = function(_state) {
		ds_list_add(possible_states, _state);
	};
	
	for(var _i = 3; _i < argument_count; _i++)
	{
		append_state(argument[_i]);
		update_entropy();
	};
	
	static set_possible_states = function(_list) {
		possible_states = _list;
	}
	
	static update_compatible_states = function(_given_state) {
		var _original_entropy = entropy;
		for(var _i = 0; _i < ds_list_size(possible_states); _i++)
		{
			if (ds_list_find_index(_given_state.compatible_states, possible_states[_i]) == -1) {
				ds_list_delete(possible_states, _i);
			}
		}
		update_entropy();
		
	}
	
	static update_neighbour_entropy = function() {
		for(var _i = 0; _i < ds_list_size(neighbours); _i++) {
			neighbours[_i].update_compatible_states(state);
		}
	}
	
	static update_state = function(_state) {
		state = _state;
	}


	static pick_random_state = function() {
		ds_list_shuffle(possible_states);
		update_state(possible_states[0]);
	};
	
	// Allows for dynamic addition of neighbours. :D
	static add_neighbours = function(_neighbour) {
		ds_list_add(neighbours, _neighbour);
	};
}

function Dungeon(_xpos, _ypos, _size) constructor {
	_x = _xpos;
	_y = _ypos;
	dungeon = ds_grid_create(_size, _size);
	default_possible_states = ds_list_create();
	size = _size;
	
	static begin_wfc = function(_x_start, _y_start) {
		
	}
	
	static generate = function() {
		for(var _i = 0; _i < size; _i++) {
			for(var _j = 0; _j < size; _j++) {
				var _cell = new DungeonCell(_i, _j, size);
				_cell.set_possible_states = default_possible_states;
				_cell._x = _i;
				_cell._y = _j;
				ds_grid_set(dungeon, _i, _j, _cell);
			}
		}
		var _x_start = floor(random(size));
		var _y_start = floor(random(size));
		
		begin_wfc(_x_start, _y_start);
	}
	
	static draw_test_entropy =  function() {
		for(var _i = 0; _i < size; _i++) {
			for(var _j = 0; _j < size; _j++) {
				var _cell = ds_grid_get(dungeon, _i, _j);
				draw_text(_cell._x, _cell._y, _cell._entropy);
			}
		}
	}
	
	static add_tile_states_dynamically = function() {
		
		for(var _i = 0; _i < argument_count; _i++) {
			ds_list_add(default_possible_states, argument[_i]);
		}
	}

}

function calculate_uniform_entropy(_list) {
		return log2(power(ds_list_size(_list), 2));
}

function calculate_non_uniform_entropy(_list) {
	var _entropy = 0;
	for(var _i = 0; _i < ds_list_size(_list); _i++) {
		_entropy += (1/_list[i].weight) * log2(1/_list[i].weight);
	};
	return _entropy;
}

debug_init();
extends Control

func _ready():
	_clear_and_create_checkboxes()

func _clear_and_create_checkboxes():
	for child in $HSplitContainer/Board/GridContainer.get_children():
		child.queue_free()
	
	var n_boxes = $HSplitContainer/Controls/NBoxes.value
	for i in range(n_boxes * n_boxes):
		$HSplitContainer/Board/GridContainer.add_child(CheckBox.new())
	$HSplitContainer/Board/GridContainer.columns = n_boxes

func _on_save_pressed():
	var save_path = $HSplitContainer/Controls/Path.text
	if save_path == "":
		return
		
	var button_matrix = []
	var matrix_line = []
	var i = 0
	for child in $HSplitContainer/Board/GridContainer.get_children():
		matrix_line.append(child.button_pressed)
		if i == $HSplitContainer/Controls/NBoxes.value:
			button_matrix.append(matrix_line)
			i = 0
			matrix_line = []
		i += 1
		
	var json_str = JSON.stringify(button_matrix, "\t")
	FileAccess.open(save_path, FileAccess.WRITE).store_string(json_str)

func _on_n_boxes_value_changed(_value):
	_clear_and_create_checkboxes()

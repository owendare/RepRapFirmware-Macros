if state.currentTool != -1
	M291 P{"Z offset of  " ^ tools[(state.currentTool)].name ^ " is  " ^ tools[state.currentTool].offsets[2]} R"Offset" S1 T5
else
	M291 P"No tool selected" R"Offset" S1 T3
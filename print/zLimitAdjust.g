;zLimitAdjust.g
; called from tpost#.g of all tools to adjust Z min limit in cases where tools have different offsets

M208 S1 Z0 ; set limit to zero to reset if either all tools are being docked, or there is no offset required

if state.nextTool != -1 ; we are changing tools, so may need to adjust
	if tools[state.nextTool].offsets[2]) > 0 ; next tool offset is > 0 so Z min limit must be < 0
		M208 S1 Z{0 - tools[state.nextTool].offsets[2]} 
	elif
		if tools[state.nextTool].offsets[2]) < 0 ; next tool offset is < 0 so Z min limit must be > 0
			M208 S1 Z{abs(tools[state.nextTool].offsets[2])}

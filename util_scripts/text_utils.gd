class_name TextUtils
extends RefCounted

static var _indent_regex: RegEx = RegEx.create_from_string("^[ \t]*")

static func dedent(text: String) -> String:
	if text.is_empty():
		return ""
	
	var lines := text.split("\n")
	var indents := []
	
	# Collect indentation levels.
	for i in lines.size():
		var result := _indent_regex.search(lines[i])
		if result:
			if result.get_end() != lines[i].length():
				indents.append(result.get_string())
			else:
				lines[i] = ""
	
	# Find common prefix among indentations.
	var common_indent := ""
	if indents.size() > 0:
		common_indent = indents.pop_back()
		for indent in indents:
			var l := mini(common_indent.length(), indent.length())
			var i := 0
			while i < l and common_indent[i] == indent[i]:
				i += 1
			common_indent = common_indent.substr(0, i)
	
	# Remove common indent from each line.
	for i in lines.size():
		lines[i] = lines[i].trim_prefix(common_indent)
	
	while not lines.is_empty() and lines[0] == "":
		lines.remove_at(0)
	
	while not lines.is_empty() and lines[-1] == "":
		lines.remove_at(lines.size() - 1)
	
	return "\n".join(lines)

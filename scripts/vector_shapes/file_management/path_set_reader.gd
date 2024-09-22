class_name PathSetReader
extends Control

enum ParseNoteType {INFO, WARNING, ERROR, NESTED}
const MAXIMUM_SHAPES = 30


static func read_file(filepath: String, _size:= Vector2.ZERO) -> ParseResult:
    if !filepath.ends_with(".svg"):
        printerr("Error: tried to read a file that wasn't an svg")
        return ParseResult.make_empty("tried to read a file of the wrong type")

    var parser: XMLParser = XMLParser.new()
    var _open_result = parser.open(filepath)

    var svg_element
    while parser.read() != ERR_FILE_EOF:
        if parser.get_node_type() == parser.NODE_ELEMENT and parser.get_node_name() == "svg":
            svg_element = read_element(parser)

    var parse_result = parse_path_set(svg_element)
    if filepath.ends_with('-l.svg'):
        parse_result.path_set.mirror_horizontally()
        parse_result.append_info_note('mirrored paths')
    return parse_result


static func read_element(parser: XMLParser) -> Dictionary:
    var element = {}
    element.tag = parser.get_node_name()
    var children = []

    for i in range(parser.get_attribute_count()):
        element[parser.get_attribute_name(i)] = parser.get_attribute_value(i)

    if parser.is_empty():
        return element

    while !has_reached_end(parser):
        if parser.get_node_type() == XMLParser.NODE_ELEMENT:
            children.append(read_element(parser))

    if children.size() > 0:
        element.children = children
    return element

static func has_reached_end(parser: XMLParser) -> bool:
    if parser.read() == ERR_FILE_EOF:
        return true
    if parser.get_node_type() == parser.NODE_ELEMENT_END:
        return true
    return false


static func parse_path_set(svg_element: Dictionary) -> ParseResult:
    var parse_result = ParseResult.new()
    _parse_element(svg_element, parse_result)

    var path_scale = 1.0
    var offset = Vector2.ZERO

    var width = 0
    var height = 0
    var scaling_length = 0
    if "width" in svg_element:
        width = float(svg_element.width)
    if "height" in svg_element:
        height = float(svg_element.height)

    if "viewBox" in svg_element:
        var number_strings = svg_element.viewBox.split(" ")
        var viewbox_params = []
        for string in number_strings:
            viewbox_params.append(float(string))

        offset = Vector2(viewbox_params[0], viewbox_params[1])
        width = viewbox_params[2]
        height = viewbox_params[3]

    if width > height:
        scaling_length = width
    else:
        scaling_length = height
    
    if scaling_length != 0:
        path_scale = 40 / scaling_length
        offset = -Vector2(width, height) / 2

    if offset != Vector2.ZERO:
        parse_result.path_set.translate(offset)
    if path_scale != 1.0:
        parse_result.path_set.scale(path_scale)
        
    return parse_result

# TODO: add group names to child elements
static func _parse_element(xml_element: Dictionary, parse_result: ParseResult) -> void:
    if parse_result.path_set.paths.size() >= MAXIMUM_SHAPES:
        parse_result.maximum_shapes_read = true
        return

    if "inkscape:label" in xml_element:
        if xml_element["inkscape:label"] == "pathed text":
            parse_result.append_info_note("ignored pathed text")
            return

    if "tag" in xml_element:
        match xml_element.tag:
            "rect":
                parse_result.append_path(SVGShapeParser.parse_rect(xml_element))

            "circle":
                if "id" in xml_element and xml_element.id == "character_base":
                    parse_body(xml_element, parse_result.path_set)
                    parse_result.body_elements_read += 1
                else:
                    parse_result.append_path(SVGShapeParser.parse_circle(xml_element))

            "ellipse":
                parse_result.append_path(SVGShapeParser.parse_ellipse(xml_element))

            "line":
                parse_result.append_path(SVGShapeParser.parse_line(xml_element))

            "polyline":
                parse_result.append_path(SVGShapeParser.parse_polyline(xml_element))

            "polygon":
                parse_result.append_path(SVGShapeParser.parse_polyline(xml_element))

            "path":
                var path_id = "path"
                if "id" in xml_element:
                    path_id = xml_element.id
                var path_note = NestedParseNote.new(path_id)
                parse_result.append_path(SVGPathParser.parse_path(xml_element, path_note))
                
                if path_note.has_content():
                    parse_result.parse_notes.append(path_note)
            "svg":
                pass
            "g":
                pass
            "defs":
                pass
            "inkscape:path_effect":
                parse_result.append_warning_note("unsupported tag: %s" % xml_element.tag)
                return
            "clipPath":
                # TODO: only include clipPath elements if they are referenced elsewhere
                return
            _:
                parse_result.append_warning_note("unsupported tag: %s" % xml_element.tag)

    if "clip-path" in xml_element:
        parse_result.append_error_note("clipping is insupported")

    if "children" in xml_element:
        for child in xml_element.children:
            _parse_element(child, parse_result)


static func parse_body(xml: Dictionary, path_set: PathSet) -> void:
    if "fill" in xml:
        path_set.fill_colour = FileUtilities.get_colour(xml.fill)
    if "stroke" in xml:
        path_set.stroke_colour = FileUtilities.get_colour(xml.stroke)
    if "stroke-width" in xml:
        path_set.stroke_width = float(xml["stroke-width"])
    if "r" in xml:
        path_set.body_radius = float(xml["r"])


static func print_xml_node(xml: Dictionary, indent: String):
    print(indent, "{")
    var base_indent = indent
    indent += "\t"
    if "id" in xml:
        print(indent, "id: ", xml["id"])
    for key in xml:
        if key != "children" and key != "id":
            print(indent, key, ": ", xml[key])
    if "children" in xml:
        print(indent, "children:")
        for child in xml["children"]:
            print_xml_node(child, indent)
    print(base_indent, "},")


class ParseResult:
    var path_set := PathSet.new()
    var parse_notes := []
    var body_elements_read := 0
    var maximum_shapes_read := false

    static func make_empty(error_message: String) -> ParseResult:
        var result = ParseResult.new()
        result._append_parse_message(error_message, ParseNoteType.ERROR)
        return result

    
    func append_path(path: ColouredPath):
        path_set.append(path)


    func append_info_note(message: String):
        _append_parse_note(message, ParseNoteType.INFO)
    func append_warning_note(message: String):
        _append_parse_note(message, ParseNoteType.WARNING)
    func append_error_note(message: String):
        _append_parse_note(message, ParseNoteType.ERROR)

    func _append_parse_note(message: String, type):
        parse_notes.append(ParseNote.new(message, type))
    

class ParseNote:
    var type: int
    var text: String

    func _init(p_text: String = "", p_type: int = 0):
        type = p_type
        text = p_text


class NestedParseNote extends ParseNote:
    var child_notes := []

    func _init(p_text: String = "", p_type: int = ParseNoteType.NESTED):
        type = p_type
        text = p_text
        child_notes = []

    func has_content() -> bool:
        return child_notes.size() > 0

    func append_info_note(p_text: String):
        append_note(p_text, ParseNoteType.INFO)
    func append_warning_note(p_text: String):
        append_note(p_text, ParseNoteType.WARNING)
    func append_error_note(p_text: String):
        append_note(p_text, ParseNoteType.ERROR)

    func append_note(p_text: String, p_type: int = 0):
        child_notes.append(ParseNote.new(p_text, p_type))

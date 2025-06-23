
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as flutter_quill;
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';


class BodyWidget extends StatefulWidget {
  const BodyWidget({super.key});

  @override
  State<BodyWidget> createState() => _BodyWidgetState();
}

class _BodyWidgetState extends State<BodyWidget> {
   
  bool _showToolbar = false;
   

 //manages notepad text  content
 final flutter_quill.QuillController _Controller = flutter_quill.QuillController.basic();
  // ignore: unused_field
  String _currentFilePath = '';
 
 
  Future<void> _saveFile() async {
    
    if (await Permission.storage.request().isGranted) {
      // ignore: unused_local_variable
      final directory = await getApplicationDocumentsDirectory();

      String? filePath = await FilePicker.platform.saveFile(
        dialogTitle: "Saving you file",
        fileName: 'note_${DateTime.now().millisecondsSinceEpoch}.txt',
        allowedExtensions: ['txt'],
        type: FileType.custom
      );

      if (filePath !=null)
      {
        final file = File(filePath);
        String content = jsonEncode(_Controller.document.toDelta());
        await file.writeAsString(content);
        setState(() {
          _currentFilePath = filePath;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File saved successfully')
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Permission denied to save file')
        ),
      );
    }
  }
 
  Future<void> _openFile() async {
    if (await Permission.storage.request().isGranted) {
      final filePath = await FilePicker.platform.pickFiles(
        dialogTitle: "Opening you file",
        type: FileType.custom,
        allowedExtensions: ['txt'],
      );
      if (filePath != null) {
        final file = File(filePath.paths as String);
        final content = await file.readAsString();
        setState(() {
         _Controller.document = flutter_quill.Document.fromJson(jsonDecode(content));
         _currentFilePath = filePath.paths as String;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File opened successfully')
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Permission denied to open file')
        ),
      );
    }
  }
 
 void  _newFile(){
   setState(() {
     _Controller.clear();
     _currentFilePath = '';
    }
  );
 }
 
 
Widget _buildCustomToolbar() {
  // These should be outside the build method in a real app, but for demo, it's fine here.
  final List<String> fonts = ['Roboto', 'Courier'];
  String selectedFont = 'Roboto';
  final TextEditingController _fontSizeController = TextEditingController();

  return StatefulBuilder(
    builder: (context, setToolbarState) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Container(
          padding: const EdgeInsets.all(8),
          color: Colors.grey[200],
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.format_bold),
                onPressed: () => _Controller.formatSelection(Attribute.bold),
              ),
              IconButton(
                icon: const Icon(Icons.format_italic),
                onPressed: () => _Controller.formatSelection(Attribute.italic),
              ),
              IconButton(
                icon: const Icon(Icons.format_underline),
                onPressed: () => _Controller.formatSelection(Attribute.underline),
              ),
              IconButton(
                icon: const Icon(Icons.color_lens),
                onPressed: _showColorPicker,
              ),
              IconButton(
                icon: const Icon(Icons.format_list_bulleted),
                onPressed: () => _Controller.formatSelection(Attribute.ul),
              ),
              IconButton(
                icon: const Icon(Icons.format_list_numbered),
                onPressed: () => _Controller.formatSelection(Attribute.ol),
              ),
              IconButton(
                icon: const Icon(Icons.format_align_left),
                onPressed: () => _Controller.formatSelection(Attribute.leftAlignment),
              ),
              IconButton(
                icon: const Icon(Icons.format_align_center),
                onPressed: () => _Controller.formatSelection(Attribute.centerAlignment),
              ),
              IconButton(
                icon: const Icon(Icons.format_align_right),
                onPressed: () => _Controller.formatSelection(Attribute.rightAlignment),
              ),
              IconButton(
                icon: const Icon(Icons.search),
                tooltip: 'Search Text',
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      final TextEditingController _searchController = TextEditingController();
                      return AlertDialog(
                        title: Text('Search Text'),
                        content: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(hintText: 'Enter text to search'),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              _searchAndHighlight(_searchController.text);
                              Navigator.of(context).pop();
                            },
                            child: Text('Search'),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.category),
                tooltip: 'Insert Shape',
                onPressed: _showShapeDialog,
              ),
              IconButton(
                icon: const Icon(Icons.text_increase),
                tooltip: 'Increase Font Size',
                onPressed: () => _changeFontSize(increase: true),
              ),
              IconButton(
                icon: const Icon(Icons.text_decrease),
                tooltip: 'Decrease Font Size',
                onPressed: () => _changeFontSize(increase: false),
              ),
              SizedBox(
                width: 50,
                child: TextField(
                  controller: _fontSizeController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Size',
                    contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 8),
                  ),
                  onSubmitted: (value) {
                    double? size = double.tryParse(value);
                    if (size != null && size >= 8) {
                      _applyFontSizeToAll(size);
                    }
                  },
                ),
              ),
              SizedBox(width: 8),
              DropdownButton<String>(
                value: selectedFont,
                items: fonts.map((font) {
                  return DropdownMenuItem(
                    value: font,
                    child: Text(font),
                  );
                }).toList(),
                onChanged: (font) {
                  if (font != null) {
                    setToolbarState(() => selectedFont = font);
                    _applyFontFamilyToAll(font);
                  }
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}

void _applyFontSizeToAll(double size) {
  final doc = _Controller.document;
  _Controller.formatText(0, doc.length - 1, Attribute.fromKeyValue('size', size.toString()));
}

// Apply font family to all text in the document
void _applyFontFamilyToAll(String font) {
  final doc = _Controller.document;
  _Controller.formatText(0, doc.length - 1, Attribute.fromKeyValue('font', font));
}

void _searchAndHighlight(String text) {
  if (text.isEmpty) return;
  final doc = _Controller.document;
  final plainText = doc.toPlainText();
  final index = plainText.indexOf(text);
  if (index != -1) {
    _Controller.updateSelection(
      TextSelection(baseOffset: index, extentOffset: index + text.length),
      ChangeSource.local,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Found "$text"')),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Text not found')),
    );
  }
}

void _showShapeDialog() {
  showDialog(
    context: context,
    builder: (context) => SimpleDialog(
      title: Text('Insert Shape'),
      children: [
        SimpleDialogOption(
          child: Text('Rectangle ▭'),
          onPressed: () {
            _insertShape('▭');
            Navigator.pop(context);
          },
        ),
        SimpleDialogOption(
          child: Text('Circle ◯'),
          onPressed: () {
            _insertShape('◯');
            Navigator.pop(context);
          },
        ),
        SimpleDialogOption(
          child: Text('Triangle △'),
          onPressed: () {
            _insertShape('△');
            Navigator.pop(context);
          },
        ),
      ],
    ),
  );
}

void _insertShape(String shape) {
  final selection = _Controller.selection;
  _Controller.replaceText(
    selection.baseOffset,
    selection.extentOffset - selection.baseOffset,
    shape,
    TextSelection.collapsed(offset: selection.baseOffset + shape.length),
  );
}

void _changeFontSize({required bool increase}) {
  final selection = _Controller.selection;
  if (selection.isCollapsed) return;
  // Get current font size or default to 16
  final attrs = _Controller.getSelectionStyle().attributes;
  double currentSize = 16;
  if (attrs.containsKey('size')) {
    currentSize = double.tryParse(attrs['size']!.value.toString()) ?? 16;
  }
  double newSize = increase ? currentSize + 2 : currentSize - 2;
  if (newSize < 8) newSize = 8;
  _Controller.formatSelection(Attribute.fromKeyValue('size', newSize.toString()));
}

void _showColorPicker() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Pick a color'),
      content: SingleChildScrollView(
        child: BlockPicker(
          pickerColor: Colors.black,
          onColorChanged: (color) {
            // Convert to CSS hex string (e.g. "#RRGGBB")
            final hex = '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}';
            _Controller.formatSelection(Attribute.fromKeyValue('color', hex));
            Navigator.pop(context);
          },
        ),
      ),
    ),
  );
}
 

 @override
   void dispose(){
     _Controller.dispose();
     super.dispose();
 }


 @override
Widget build(BuildContext context) {
  return Center(
    child: Column(
      children: [
        Container(
          color: const Color.fromARGB(255, 100, 198, 255),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              TextButton(
                onPressed: _saveFile, 
                child: Text('Save')
              ),
              TextButton(
                onPressed: _openFile,
                child: Text('Open')
              ),
              TextButton(
                onPressed: () => { 
                  showDialog(
                    context: context, 
                    barrierDismissible: false,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('Create New File', textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleSmall,),
                        content: Text('Save Previous File Before Creating new One', style:TextStyle(fontSize: 13.0),),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text('Close'),
                          ),
                          TextButton(
                            onPressed: () {
                              _newFile();
                              Navigator.of(context).pop();
                            },
                            child: Text("Create"),
                          )
                        ],
                      );
                    } 
                  ),
                }, 
                child: Text('New File'),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _showToolbar = !_showToolbar;
                  });
                },
                child: Row(
                  children: [
                    Icon(_showToolbar ? Icons.keyboard_arrow_up : Icons.edit),
                    SizedBox(width: 4),
                    Text('Edit')
                  ],
                ),
              ),
            ],
          ),
        ),
        if (_showToolbar) _buildCustomToolbar(), // <-- Show toolbar if true
        SizedBox(height: 5,),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: flutter_quill.QuillEditor(
              controller: _Controller,
              focusNode: FocusNode(),
              scrollController: ScrollController(),
              config: flutter_quill.QuillEditorConfig(
                scrollable : true,
                autoFocus: false,
                expands: true,
                padding: EdgeInsetsGeometry.zero,
                placeholder: "enter text here",
              ),
            ),
          ),
        ),
      ],
    ),
  );
}}
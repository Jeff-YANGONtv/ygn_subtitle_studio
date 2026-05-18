import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:file_picker/file_picker.dart';
import '../subtitle_sync/subtitle_sync.dart';

class SubtitleStudioScreen extends StatefulWidget {
  const SubtitleStudioScreen({super.key});

  @override
  State<SubtitleStudioScreen> createState() => _SubtitleStudioScreenState();
}

class _SubtitleStudioScreenState extends State<SubtitleStudioScreen> {
  List<SubtitleEntry> _subtitles = [];
  String _fileName = '';
  // ignore: prefer_final_fields
  bool _isUploading = false;
  // ignore: prefer_final_fields
  double _uploadProgress = 0;
  int _selectedSubtitleIndex = -1;

  void _saveLocally() {
    if (_subtitles.isEmpty) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Saved locally')),
    );
  }

  void _sendToTeamDrive() {
    if (_subtitles.isEmpty) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sent to Team Drive')),
    );
  }

  void _viewVersionHistory() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Version history')),
    );
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['srt'],
    );
    if (result != null && result.files.single.path != null) {
      final file = result.files.first;
      setState(() {
        _fileName = file.name;
      });
      try {
        final content = await File(file.xFile.path).readAsString();
        setState(() {
          _subtitles = SubtitleSync.parseSrt(content);
        });
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error reading file: $e')),
          );
        }
      }
    }
  }

  void _shiftSubtitles(Duration offset) {
    setState(() {
      _subtitles = SubtitleSync.shiftTiming(_subtitles, offset);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('YGN Subtitle Studio'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file),
            tooltip: 'Import SRT',
            onPressed: _pickFile,
          ),
        ],
      ),
      body: _subtitles.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.subtitles, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No subtitles loaded',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Import an SRT file to get started',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[500],
                        ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                if (_isUploading)
                  LinearProgressIndicator(value: _uploadProgress),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Text(
                        _fileName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      Text('${_subtitles.length} entries'),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _subtitles.length,
                    itemBuilder: (context, index) {
                      final entry = _subtitles[index];
                      final isSelected = index == _selectedSubtitleIndex;
                      return ListTile(
                        selected: isSelected,
                        selectedTileColor: Colors.teal.withValues(alpha: 0.1),
                        leading: CircleAvatar(
                          backgroundColor: isSelected
                              ? Colors.teal
                              : Colors.grey[300],
                          foregroundColor:
                              isSelected ? Colors.white : Colors.black87,
                          child: Text('${entry.index}'),
                        ),
                        title: Text(entry.text),
                        subtitle: Text(
                          '${_formatDuration(entry.start)} --> ${_formatDuration(entry.end)}',
                        ),
                        onTap: () {
                          setState(() {
                            _selectedSubtitleIndex =
                                _selectedSubtitleIndex == index ? -1 : index;
                          });
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
      floatingActionButton: SpeedDial(
        icon: Icons.menu,
        activeIcon: Icons.close,
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.save),
            label: 'Save Locally',
            onTap: _saveLocally,
          ),
          SpeedDialChild(
            child: const Icon(Icons.cloud_upload),
            label: 'Send to Team Drive',
            onTap: _sendToTeamDrive,
          ),
          SpeedDialChild(
            child: const Icon(Icons.history),
            label: 'Version History',
            onTap: _viewVersionHistory,
          ),
          SpeedDialChild(
            child: const Icon(Icons.fast_rewind),
            label: 'Shift -1s',
            onTap: () => _shiftSubtitles(const Duration(seconds: -1)),
          ),
          SpeedDialChild(
            child: const Icon(Icons.fast_forward),
            label: 'Shift +1s',
            onTap: () => _shiftSubtitles(const Duration(seconds: 1)),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    final ms = (d.inMilliseconds % 1000).toString().padLeft(3, '0');
    return '$h:$m:$s,$ms';
  }
}

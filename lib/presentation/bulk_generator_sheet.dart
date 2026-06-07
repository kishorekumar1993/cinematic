import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cinematic/model/animation_archieve.dart';
import 'package:cinematic/model/screen_config.dart';
import 'package:cinematic/model/template_registry.dart';

class BulkGeneratorSheet extends StatefulWidget {
  const BulkGeneratorSheet({super.key});

  @override
  State<BulkGeneratorSheet> createState() => _BulkGeneratorSheetState();
}

class _BulkGeneratorSheetState extends State<BulkGeneratorSheet> {
  int _activeTab = 0; // 0: Topics List, 1: CSV Paste
  final TextEditingController _topicsController = TextEditingController(
    text: "Chola Empire\nRoman Empire\nPandya Kingdom\nAncient Egypt\nSpace Exploration"
  );
  
  final TextEditingController _csvController = TextEditingController(
    text: "Topic,Template,ScenesCount\n"
         "Deep Sea Creatures,documentary_six,3\n"
         "The French Revolution,history_reveal,3\n"
         "Tesla vs Edison,dual_prime,2"
  );

  bool _isGenerating = false;
  List<AnimaticArchive> _generatedArchives = [];
  int? _selectedBatchIndex;

  // Pre-configured rich script presets for standard topics
  final Map<String, List<Map<String, dynamic>>> _scriptPresets = {
    'chola empire': [
      {
        'title': 'The Ocean Conquerors',
        'subtitle': 'Maritime Supremacy',
        'hook': 'The empire that ruled the seas...',
        'body': 'The Cholas maintained a powerful merchant navy that dominated the Bay of Bengal, securing spice trade routes to China, Malaya, and Sumatra.',
        'keyPoints': ['Rajaraja Chola I', 'Trade to China', 'Bay of Bengal supremacy'],
        'imageUrl': 'https://images.pexels.com/photos/208573/pexels-photo-208573.jpeg?auto=compress&cs=tinysrgb&w=800',
        'templateId': 'documentary_six',
      },
      {
        'title': 'Brihadeeswarar Temple',
        'subtitle': 'Architectural Marvel',
        'hook': 'Built without a binding materials.',
        'body': 'Constructed entirely of granite, the main vimana tower stands at 216 feet. The kumbam capstone weighs over 80 tons and was raised via a 4-mile ramp.',
        'keyPoints': ['Thanjavur Temple', '80-Ton Capstone', 'Granite construction'],
        'imageUrl': 'https://images.pexels.com/photos/1007427/pexels-photo-1007427.jpeg?auto=compress&cs=tinysrgb&w=800',
        'templateId': 'history_reveal',
      },
      {
        'title': 'The Gangaikonda Conqueror',
        'subtitle': 'Rajendra Chola I',
        'hook': 'Extending the dynasty north.',
        'body': 'Rajendra Chola I marched to the river Ganges, built a new capital, and sent massive fleets that captured the Sri Lankan and Srivijayan empires.',
        'keyPoints': ['Srivijaya Raid', 'Gangaikonda Cholapuram', 'Empire of expansion'],
        'imageUrl': 'https://images.pexels.com/photos/4148864/pexels-photo-4148864.jpeg?auto=compress&cs=tinysrgb&w=800',
        'templateId': 'documentary_five',
      }
    ],
    'roman empire': [
      {
        'title': 'All Roads Lead to Rome',
        'subtitle': 'Imperial Logistics',
        'hook': 'Building 50,000 miles of stone highway.',
        'body': 'A network of paved, guarded roads connected distant provinces to Rome, securing continuous commerce and allowing legion troops to march rapidly.',
        'keyPoints': ['Stone paved roads', 'Legion mobility', 'Postal Courier network'],
        'imageUrl': 'https://images.pexels.com/photos/208573/pexels-photo-208573.jpeg?auto=compress&cs=tinysrgb&w=800',
        'templateId': 'documentary_six',
      },
      {
        'title': 'The Colosseum Marvel',
        'subtitle': 'Arena of Gladiators',
        'hook': 'Where empires came to watch.',
        'body': 'Built by the Flavian emperors, the stadium sat 50,000 spectators. It featured trap doors, lifts, and could be flooded to host mock naval battles.',
        'keyPoints': ['Flavian Amphitheatre', 'Gladiator Games', 'Mock sea battles'],
        'imageUrl': 'https://images.pexels.com/photos/531602/pexels-photo-531602.jpeg?auto=compress&cs=tinysrgb&w=800',
        'templateId': 'history_reveal',
      },
      {
        'title': 'The Golden Pax Romana',
        'subtitle': 'Two Centuries of Peace',
        'hook': 'Initiated by Augustus Caesar.',
        'body': 'A golden era of architecture, poetry, and commerce where Rome reigned supreme and secure from internal rebellions.',
        'keyPoints': ['Augustus Caesar', 'Golden Age', 'Relative stability'],
        'imageUrl': 'https://images.pexels.com/photos/1007427/pexels-photo-1007427.jpeg?auto=compress&cs=tinysrgb&w=800',
        'templateId': 'documentary_seven',
      }
    ],
    'pandya kingdom': [
      {
        'title': 'The Pearl Fishery Coast',
        'subtitle': 'Wealth of the Oceans',
        'hook': 'Ancient pearl trade with Rome and China.',
        'body': 'The Pandyas ruled over the Gulf of Mannar pearl fishery. Premium pearls were exported directly to Roman aristocrats and Chinese royalty.',
        'keyPoints': ['Gulf of Mannar pearls', 'Greek trade logs', 'Ancient maritime routes'],
        'imageUrl': 'https://images.pexels.com/photos/3394939/pexels-photo-3394939.jpeg?auto=compress&cs=tinysrgb&w=800',
        'templateId': 'documentary_six',
      },
      {
        'title': 'Meenakshi Amman Temple',
        'subtitle': 'Citadel of Artistry',
        'hook': 'The heart of historic Madurai.',
        'body': 'The temple towers are layered with thousands of colorful mythological figures. Constructed around the active layout of Madurai, resembling a lotus.',
        'keyPoints': ['14 Gopurams', 'Lotus-shaped City', 'Goddess Meenakshi'],
        'imageUrl': 'https://images.pexels.com/photos/4148864/pexels-photo-4148864.jpeg?auto=compress&cs=tinysrgb&w=800',
        'templateId': 'history_reveal',
      }
    ],
    'tesla vs edison': [
      {
        'title': 'Battle of the Currents',
        'subtitle': 'Alternating vs Direct Current',
        'hook': 'Who would light the future?',
        'templateId': 'dual_prime',
        'leftTitle': 'Nikola Tesla (AC)',
        'leftSubtitle': 'Alternating Current',
        'leftBody': 'High voltage transmission over long distances, efficient transformers, and polyphase motor designs.',
        'leftKeyPoints': ['Long range transmission', 'Transformer scaling', 'Westinghouse support'],
        'leftImageUrl': 'https://images.pexels.com/photos/374693/pexels-photo-374693.jpeg?auto=compress&cs=tinysrgb&w=400',
        'rightTitle': 'Thomas Edison (DC)',
        'rightSubtitle': 'Direct Current',
        'rightBody': 'Low voltage transmission, safer locally but required power plants every mile. Heavily lobbied against AC safety.',
        'rightKeyPoints': ['Low voltage safety', 'Local power grids', 'Established lobby'],
        'rightImageUrl': 'https://images.pexels.com/photos/4148864/pexels-photo-4148864.jpeg?auto=compress&cs=tinysrgb&w=400',
        'closureLine': 'Ultimately, Tesla\'s AC system powered the modern industrial grid.'
      }
    ]
  };

  void _generate() async {
    setState(() {
      _isGenerating = true;
    });

    // Simulate server side AI prompt/conversion delay
    await Future.delayed(const Duration(seconds: 2));

    List<String> items = [];
    if (_activeTab == 0) {
      items = _topicsController.text
          .split('\n')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    } else {
      final lines = _csvController.text
          .split('\n')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
      // Skip header row
      if (lines.length > 1) {
        for (int i = 1; i < lines.length; i++) {
          final parts = lines[i].split(',');
          if (parts.isNotEmpty) {
            items.add(parts[0].trim());
          }
        }
      }
    }

    final List<AnimaticArchive> batch = [];

    for (var topic in items) {
      final key = topic.toLowerCase();
      List<SceneConfig> scenes = [];

      if (_scriptPresets.containsKey(key)) {
        final sceneData = _scriptPresets[key]!;
        for (int i = 0; i < sceneData.length; i++) {
          final s = sceneData[i];
          scenes.add(SceneConfig(
            id: '${key}_scene_$i',
            templateId: s['templateId'] as String? ?? 'documentary_six',
            title: s['title'] as String? ?? '',
            subtitle: s['subtitle'] as String? ?? '',
            hook: s['hook'] as String? ?? '',
            body: s['body'] as String? ?? '',
            keyPoints: List<String>.from(s['keyPoints'] ?? []),
            imageUrl: s['imageUrl'] as String? ?? '',
            durationSeconds: 8,
            effect: 'zoom_in',
            transitionOut: 'fade',
            textEffect: 'fade',
            voiceTone: 'Narrative voice',
            musicStyle: 'Cinematic pads',
            animationInstructions: '',
            closureLine: s['closureLine'] as String? ?? '',
            leftTitle: s['leftTitle'] as String? ?? '',
            leftSubtitle: s['leftSubtitle'] as String? ?? '',
            leftBody: s['leftBody'] as String? ?? '',
            leftKeyPoints: List<String>.from(s['leftKeyPoints'] ?? []),
            leftImageUrl: s['leftImageUrl'] as String? ?? '',
            rightTitle: s['rightTitle'] as String? ?? '',
            rightSubtitle: s['rightSubtitle'] as String? ?? '',
            rightBody: s['rightBody'] as String? ?? '',
            rightKeyPoints: List<String>.from(s['rightKeyPoints'] ?? []),
            rightImageUrl: s['rightImageUrl'] as String? ?? '',
          ));
        }
      } else {
        // Fallback dynamic generator (for custom user-entered topics)
        scenes = [
          SceneConfig(
            id: '${key}_scene_0',
            templateId: 'documentary_six',
            title: '$topic: Part 1',
            subtitle: 'The Genesis',
            hook: 'Discover the hidden secrets of $topic.',
            body: 'A deep dive investigation into $topic, uncovering ancient mysteries, legacy lessons, and modern implications.',
            keyPoints: ['Core Facts', 'Key figures', 'Discovery notes'],
            imageUrl: 'https://images.pexels.com/photos/1181675/pexels-photo-1181675.jpeg?auto=compress&cs=tinysrgb&w=800',
            durationSeconds: 8,
            effect: 'zoom_in',
            transitionOut: 'fade',
            textEffect: 'fade',
            voiceTone: 'Deep voiceover',
            musicStyle: 'Ambient drone',
            animationInstructions: '',
            closureLine: 'This is the beginning of the journey.',
          ),
          SceneConfig(
            id: '${key}_scene_1',
            templateId: 'history_reveal',
            title: 'Critical Turning Point',
            subtitle: 'Historical Impact',
            hook: 'What changed everything?',
            body: 'An in-depth explanation of how $topic impacted history, reshaped societies, and influenced global events.',
            keyPoints: ['Turning point', 'Global impact', 'Lessons learned'],
            imageUrl: 'https://images.pexels.com/photos/160107/pexels-photo-160107.jpeg?auto=compress&cs=tinysrgb&w=800',
            durationSeconds: 8,
            effect: 'pan_right',
            transitionOut: 'fade',
            textEffect: 'slide_up',
            voiceTone: 'Serious tone',
            musicStyle: 'Drums accent',
            animationInstructions: '',
            closureLine: 'A legacy that stands tall today.',
          ),
        ];
      }

      batch.add(AnimaticArchive(
        version: '1.0.0',
        title: '$topic AI Script',
        createdAt: DateTime.now(),
        scenes: scenes,
      ));
    }

    setState(() {
      _isGenerating = false;
      _generatedArchives = batch;
      _selectedBatchIndex = batch.isNotEmpty ? 0 : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20, 20, 20, 20 + MediaQuery.of(context).viewInsets.bottom
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pull Handle
              Center(
                child: Container(
                  width: 48,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Bulk AI Video Generator',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Generate 100+ videos instantly from topics or CSV',
                        style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha:0.6)),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white54),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              
              // Tabs Header
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () => setState(() => _activeTab = 0),
                    icon: const Icon(Icons.list_alt, size: 16),
                    label: const Text('Topics List'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _activeTab == 0 ? theme.colorScheme.primary : Colors.white10,
                      foregroundColor: _activeTab == 0 ? Colors.black : Colors.white70,
                      elevation: 0,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () => setState(() => _activeTab = 1),
                    icon: const Icon(Icons.cloud_upload_outlined, size: 16),
                    label: const Text('Paste CSV'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _activeTab == 1 ? theme.colorScheme.primary : Colors.white10,
                      foregroundColor: _activeTab == 1 ? Colors.black : Colors.white70,
                      elevation: 0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Inputs Area
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    if (_activeTab == 0)
                      TextField(
                        controller: _topicsController,
                        maxLines: 6,
                        decoration: InputDecoration(
                          labelText: 'Topics list (one per line)',
                          hintText: 'Enter topic names (e.g. Roman Empire)',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      )
                    else
                      TextField(
                        controller: _csvController,
                        maxLines: 6,
                        decoration: InputDecoration(
                          labelText: 'Paste CSV values',
                          hintText: 'Topic,Template,ScenesCount\nChola Dynasty,documentary_six,3',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    const SizedBox(height: 14),
                    
                    // Generate Trigger
                    _isGenerating
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Column(
                                children: [
                                  CircularProgressIndicator(),
                                  SizedBox(height: 10),
                                  Text('AI Script Generator is processing topics...', style: TextStyle(color: Colors.cyanAccent)),
                                ],
                              ),
                            ),
                          )
                        : FilledButton.icon(
                            onPressed: _generate,
                            icon: const Icon(Icons.auto_awesome),
                            label: const Text('AI Script Generator'),
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.cyanAccent.shade700,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),

                    // Generated Batches Section
                    if (_generatedArchives.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Text(
                        'Generated Videos Batch (${_generatedArchives.length})',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white70),
                      ),
                      const SizedBox(height: 8),
                      // Batch Grid
                      Container(
                        height: 120,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: Colors.white.withValues(alpha:0.04),
                          border: Border.all(color: Colors.white.withValues(alpha:0.08)),
                        ),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.all(8),
                          itemCount: _generatedArchives.length,
                          itemBuilder: (context, idx) {
                            final arch = _generatedArchives[idx];
                            final isSel = idx == _selectedBatchIndex;
                            return GestureDetector(
                              onTap: () => setState(() => _selectedBatchIndex = idx),
                              child: Container(
                                width: 140,
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isSel ? theme.colorScheme.primary : Colors.white24,
                                    width: isSel ? 2 : 1,
                                  ),
                                  color: isSel ? theme.colorScheme.primary.withValues(alpha:0.08) : Colors.black26,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      arch.title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: isSel ? theme.colorScheme.primary : Colors.white70,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${arch.scenes.length} Scenes',
                                      style: const TextStyle(fontSize: 10, color: Colors.white38),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      
                      // Detailed scene lists for selected generated batch
                      if (_selectedBatchIndex != null) ...[
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Script preview: ${_generatedArchives[_selectedBatchIndex!].title}',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.cyanAccent),
                            ),
                            FilledButton.icon(
                              onPressed: () {
                                Navigator.pop(context, _generatedArchives[_selectedBatchIndex!]);
                              },
                              icon: const Icon(Icons.check),
                              label: const Text('Load into Workspace'),
                              style: FilledButton.styleFrom(
                                backgroundColor: theme.colorScheme.primary,
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Column(
                          children: _generatedArchives[_selectedBatchIndex!].scenes.map((scene) {
                            final temp = TemplateRegistry.get(scene.templateId) ?? TemplateRegistry.get('documentary_six')!;
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                                color: Colors.white.withValues(alpha:0.02),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.movie_creation_outlined, color: theme.colorScheme.primary, size: 20),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(scene.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Template: ${temp.name} • ${scene.body.isNotEmpty ? scene.body : 'comparison layout'}',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontSize: 11, color: Colors.white38),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

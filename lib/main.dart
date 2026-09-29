import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
 
  WidgetsFlutterBinding.ensureInitialized();
  

  await Firebase.initializeApp();
  
  runApp(const FoodTaskListApp());
}

class FoodTaskListApp extends StatelessWidget {
  const FoodTaskListApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Labexam2 App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF5F7FA), 
        primaryColor: const Color(0xFF0F5B78), 
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0F5B78),
          primary: const Color(0xFF0F5B78),
        ),
        useMaterial3: true,
      ),
      home: const TaskListScreen(studentLastName: 'Bernal'), 
    );
  }
}
class TaskListScreen extends StatefulWidget {
  final String studentLastName;

  const TaskListScreen({super.key, required this.studentLastName});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {

  final TextEditingController _taskController = TextEditingController();

  final CollectionReference _tasksCollection =
      FirebaseFirestore.instance.collection('tasks');

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  
  //CREATE

  Future<void> _addTask() async {
    final String text = _taskController.text.trim();

    
    if (text.isEmpty) {
      _showSnackBar('Please enter a valid task description.', isError: true);
      return;
    }

    try {
      await _tasksCollection.add({
        'title': text,
        'createdAt': FieldValue.serverTimestamp(),
      });

      _taskController.clear();
      _showSnackBar('Task added successfully!');
    } catch (e) {
      _showSnackBar('Failed to add task: $e', isError: true);
    }
  }


  // UPDATE

  Future<void> _updateTask(String docId, String currentTitle) async {
    final TextEditingController editController =
        TextEditingController(text: currentTitle);

    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          title: const Text(
            'Edit Task',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: editController,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Update task details...',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F5B78),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onPressed: () async {
                final String updatedText = editController.text.trim();

                if (updatedText.isEmpty) {
                  _showSnackBar('Task title cannot be empty.', isError: true);
                  return;
                }

                Navigator.of(dialogContext).pop(); // Close dialog

                try {
                  await _tasksCollection.doc(docId).update({
                    'title': updatedText,
                  });
                  _showSnackBar('Task updated successfully!');
                } catch (e) {
                  _showSnackBar('Failed to update task: $e', isError: true);
                }
              },
              child: const Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }


  //DELETE

  Future<void> _deleteTask(String docId) async {
    // Optional Confirmation Dialog before deleting
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          title: const Text('Delete Task'),
          content: const Text('Are you sure you want to delete this task?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        await _tasksCollection.doc(docId).delete();
        _showSnackBar('Task deleted successfully!');
      } catch (e) {
        _showSnackBar('Failed to delete task: $e', isError: true);
      }
    }
  }

  // Helper method for SnackBar notifications
  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : const Color(0xFF0F5B78),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
             
              Text(
                'Labexam2_${widget.studentLastName}',
                style: const TextStyle(
                  fontSize: 26.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20.0),

              // Add Task Input Row 
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF2F5), 
                        borderRadius: BorderRadius.circular(14.0),
                      ),
                      child: TextField(
                        controller: _taskController,
                        decoration: const InputDecoration(
                          hintText: 'Add a new task...',
                          hintStyle: TextStyle(color: Colors.black38),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 16.0,
                          ),
                        ),
                        onSubmitted: (_) => _addTask(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12.0),
                 
                  SizedBox(
                    height: 52.0,
                    width: 52.0,
                    child: ElevatedButton(
                      onPressed: _addTask,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F5B78), // Teal color
                        padding: EdgeInsets.zero,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.0),
                        ),
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 28.0,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20.0),

           
              // READ: 
           
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _tasksCollection
                      .orderBy('createdAt', descending: false)
                      .snapshots(),
                  builder: (context, snapshot) {
                  
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFF0F5B78),
                          ),
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text('Error loading tasks: ${snapshot.error}'),
                      );
                    }

                  
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text(
                          'No tasks found. Add one above!',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      );
                    }

                    final tasks = snapshot.data!.docs;

                    return ListView.builder(
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        final taskDoc = tasks[index];
                        final String docId = taskDoc.id;
                        final Map<String, dynamic> data =
                            taskDoc.data() as Map<String, dynamic>;
                        final String taskTitle = data['title'] ?? '';

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12.0),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 14.0,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC), // Card background color
                            borderRadius: BorderRadius.circular(14.0),
                            border: Border.all(
                              color: const Color(0xFFECEFF1),
                              width: 1.0,
                            ),
                          ),
                          child: Row(
                            children: [
                              // Task Title Display
                              Expanded(
                                child: Text(
                                  taskTitle,
                                  style: const TextStyle(
                                    fontSize: 16.0,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                              
                              IconButton(
                                icon: const Icon(
                                  Icons.edit_outlined,
                                  color: Color(0xFF64748B), // Slate edit icon
                                  size: 22.0,
                                ),
                                onPressed: () => _updateTask(docId, taskTitle),
                                constraints: const BoxConstraints(),
                                padding: const EdgeInsets.all(6.0),
                              ),
                              const SizedBox(width: 8.0),
                              // Delete Trash Icon Button
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Color(0xFFDC2626), // Red delete icon
                                  size: 22.0,
                                ),
                                onPressed: () => _deleteTask(docId),
                                constraints: const BoxConstraints(),
                                padding: const EdgeInsets.all(6.0),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
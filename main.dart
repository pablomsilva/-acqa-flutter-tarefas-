import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MeuAppTarefas());
}

class Task {
  String id;
  String title;
  bool isDone;
  DateTime date;

  Task({
    required this.id,
    required this.title,
    this.isDone = false,
    required this.date,
  });
}

class MeuAppTarefas extends StatelessWidget {
  const MeuAppTarefas({super.key});

  @override
  Widget build(BuildContext meuctxt) {
    return MaterialApp(
      title: 'Gerenciador de Tarefas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00B894),
          primary: const Color(0xFF00B894),
          secondary: const Color(0xFF55EFC4),
        ),
        scaffoldBackgroundColor: const Color(0xFFF2FBF7),
      ),
      home: const AuthScreen(),
    );
  }
}

// -----------------------------------------------------------------------------
// TELA DE LOGIN / CADASTRO
// -----------------------------------------------------------------------------
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _submitAuth() {
    if (_emailController.text.trim().isEmpty || _passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, preencha todos os campos.')),
      );
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF00B894), Color(0xFF00896C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              elevation: 12,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              child: Padding(
                padding: const EdgeInsets.all(28.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: Color(0xFFE3F9F1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.task_alt_rounded,
                        size: 48,
                        color: Color(0xFF00A884),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Bem Vindo, Pablo!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E2D28),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'MEU RA: 1202451-1',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF00896C),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      isLogin ? 'Acesse sua conta' : 'Criar Conta',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E2D28),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'E-mail',
                        prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF00A884)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Senha',
                        prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF00A884)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00B894),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 4,
                        ),
                        onPressed: _submitAuth,
                        child: Text(
                          isLogin ? 'Entrar' : 'Cadastrar',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          isLogin = !isLogin;
                        });
                      },
                      child: Text(
                        isLogin ? 'Não é cadastrado? Cadastre-se' : 'Já possui conta? Faça Login',
                        style: const TextStyle(color: Color(0xFF00896C), fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// TELA PRINCIPAL (CALENDÁRIO E TAREFAS)
// -----------------------------------------------------------------------------
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  final List<Task> _allTasks = [];

  // Regra de ordenação: Pendentes primeiro, Concluídas depois; ambas em ordem alfabética.
  List<Task> get _tasksForSelectedDay {
    final dayTasks = _allTasks.where((task) {
      return isSameDay(task.date, _selectedDay);
    }).toList();

    dayTasks.sort((a, b) {
      if (a.isDone == b.isDone) {
        return a.title.toLowerCase().compareTo(b.title.toLowerCase());
      }
      return a.isDone ? 1 : -1;
    });

    return dayTasks;
  }

  void _addTask(String title) {
    if (title.trim().isEmpty) return;
    setState(() {
      _allTasks.add(
        Task(
          id: DateTime.now().toString(),
          title: title.trim(),
          date: _selectedDay,
        ),
      );
    });
  }

  void _toggleTaskStatus(String id) {
    setState(() {
      final task = _allTasks.firstWhere((t) => t.id == id);
      task.isDone = !task.isDone;
    });
  }

  void _removeTask(String id) {
    setState(() {
      _allTasks.removeWhere((t) => t.id == id);
    });
  }

  void _showAddTaskDialog() {
    final titleController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Nova Tarefa'),
        content: TextField(
          controller: titleController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Digite o nome da tarefa...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar', style: TextStyle(color: Color(0xFF00896C))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00B894),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              _addTask(titleController.text);
              Navigator.of(ctx).pop();
            },
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tasksToDisplay = _tasksForSelectedDay;
    final formattedDate = DateFormat('dd/MM/yyyy').format(_selectedDay);

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          children: [
            Text('Bem Vindo, Pablo!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Text('RA: 1202451-1', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
          ],
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF00B894),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const AuthScreen()),
              );
            },
          )
        ],
      ),
      body: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                )
              ],
            ),
            child: TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              calendarStyle: const CalendarStyle(
                selectedDecoration: BoxDecoration(
                  color: Color(0xFF00B894),
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: Color(0xFF55EFC4),
                  shape: BoxShape.circle,
                ),
                todayTextStyle: TextStyle(
                  color: Color(0xFF1E2D28),
                  fontWeight: FontWeight.bold,
                ),
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Dia $formattedDate',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E2D28)),
                ),
                Text(
                  '${tasksToDisplay.length} tarefa(s)',
                  style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: tasksToDisplay.isEmpty
                ? const Center(
                    child: Text(
                      'Nenhuma tarefa registrada para este dia.',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: tasksToDisplay.length,
                    itemBuilder: (ctx, index) {
                      final item = tasksToDisplay[index];
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: ListTile(
                          leading: Checkbox(
                            activeColor: const Color(0xFF00B894),
                            value: item.isDone,
                            onChanged: (_) => _toggleTaskStatus(item.id),
                          ),
                          title: Text(
                            item.title,
                            style: TextStyle(
                              fontSize: 16,
                              decoration: item.isDone ? TextDecoration.lineThrough : TextDecoration.none,
                              color: item.isDone ? Colors.grey : const Color(0xFF1E2D28),
                            ),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                            onPressed: () => _removeTask(item.id),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddTaskDialog,
        backgroundColor: const Color(0xFF00B894),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Adicionar tarefa', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

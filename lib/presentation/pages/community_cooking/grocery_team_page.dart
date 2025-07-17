import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../domain/entities/grocery_team.dart';
import '../../core/theme/app_theme.dart';

class GroceryTeamPage extends StatefulWidget {
  const GroceryTeamPage({super.key});

  @override
  State<GroceryTeamPage> createState() => _GroceryTeamPageState();
}

class _GroceryTeamPageState extends State<GroceryTeamPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grocery Teams'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Current Week', icon: Icon(Icons.shopping_cart)),
            Tab(text: 'Schedule', icon: Icon(Icons.schedule)),
            Tab(text: 'History', icon: Icon(Icons.history)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showTeamSettings(context),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          CurrentWeekView(),
          ScheduleView(),
          HistoryView(),
        ],
      ),
    );
  }

  void _showTeamSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const TeamSettingsDialog(),
    );
  }
}

class CurrentWeekView extends StatelessWidget {
  const CurrentWeekView({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Replace with actual data from BLoC
    final currentTeam = GroceryTeam(
      id: '1',
      apartmentId: 'apt1',
      name: 'Team Alpha',
      memberIds: ['user1', 'user2'],
      weekStartDate: DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1)),
      weekEndDate: DateTime.now().add(Duration(days: 7 - DateTime.now().weekday)),
      budgetLimit: 150.0,
      totalSpent: 87.50,
      expenses: [],
      status: GroceryTeamStatus.active,
      createdAt: DateTime.now(),
    );

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Current team card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.group,
                      color: AppTheme.primaryGreen,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      currentTeam.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.paidGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'ACTIVE',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.paidGreen,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Week: ${_formatDate(currentTeam.weekStartDate)} - ${_formatDate(currentTeam.weekEndDate)}',
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 16),
                
                // Budget progress
                Row(
                  children: [
                    const Text(
                      'Budget Progress',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const Spacer(),
                    Text(
                      '\$${currentTeam.totalSpent.toStringAsFixed(2)} / \$${currentTeam.budgetLimit.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: currentTeam.isOverBudget 
                            ? AppTheme.unpaidRed 
                            : AppTheme.primaryGreen,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: currentTeam.budgetUsagePercentage / 100,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    currentTeam.isOverBudget 
                        ? AppTheme.unpaidRed 
                        : AppTheme.primaryGreen,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  currentTeam.isOverBudget 
                      ? 'Over budget by \$${(currentTeam.totalSpent - currentTeam.budgetLimit).toStringAsFixed(2)}'
                      : 'Remaining: \$${currentTeam.remainingBudget.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: currentTeam.isOverBudget 
                        ? AppTheme.unpaidRed 
                        : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Team members
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Team Members',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ...currentTeam.memberIds.map((memberId) => ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.lightGreen,
                    child: Text(
                      'U${currentTeam.memberIds.indexOf(memberId) + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text('User $memberId'), // TODO: Replace with actual user name
                  subtitle: const Text('Team Member'),
                  trailing: IconButton(
                    icon: const Icon(Icons.message),
                    onPressed: () {
                      // TODO: Open chat with team member
                    },
                  ),
                )).toList(),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Quick actions
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _showAddExpenseDialog(context),
                icon: const Icon(Icons.add_shopping_cart),
                label: const Text('Add Expense'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _showExpenseHistory(context),
                icon: const Icon(Icons.receipt_long),
                label: const Text('View Expenses'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Recent expenses
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Recent Expenses',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                // TODO: Replace with actual expense data
                _buildExpenseItem(
                  store: 'Walmart',
                  amount: 45.30,
                  date: DateTime.now().subtract(const Duration(days: 1)),
                  purchasedBy: 'John Doe',
                  items: ['Milk', 'Bread', 'Eggs', 'Vegetables'],
                ),
                _buildExpenseItem(
                  store: 'Target',
                  amount: 32.20,
                  date: DateTime.now().subtract(const Duration(days: 2)),
                  purchasedBy: 'Jane Smith',
                  items: ['Fruits', 'Snacks', 'Cleaning supplies'],
                ),
                const SizedBox(height: 8),
                Center(
                  child: TextButton(
                    onPressed: () => _showExpenseHistory(context),
                    child: const Text('View All Expenses'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExpenseItem({
    required String store,
    required double amount,
    required DateTime date,
    required String purchasedBy,
    required List<String> items,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.store,
                size: 16,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 4),
              Text(
                store,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              const Spacer(),
              Text(
                '\$${amount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'By $purchasedBy • ${_formatDate(date)}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            items.join(', '),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  void _showAddExpenseDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddExpenseDialog(),
    );
  }

  void _showExpenseHistory(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ExpenseHistoryPage(),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class ScheduleView extends StatelessWidget {
  const ScheduleView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Current rotation info
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.rotate_right,
                      color: AppTheme.primaryGreen,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Rotation Schedule',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => _showEditRotationDialog(context),
                      child: const Text('Edit'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Teams rotate every 2 weeks',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text(
                  'Budget: \$150 per team per week',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Upcoming schedule
        const Text(
          'Upcoming Schedule',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        
        // TODO: Replace with actual schedule data
        _buildScheduleItem(
          weekStart: DateTime.now(),
          teamName: 'Team Alpha',
          members: ['John Doe', 'Jane Smith'],
          isActive: true,
        ),
        _buildScheduleItem(
          weekStart: DateTime.now().add(const Duration(days: 7)),
          teamName: 'Team Beta',
          members: ['Bob Wilson', 'Alice Brown'],
          isActive: false,
        ),
        _buildScheduleItem(
          weekStart: DateTime.now().add(const Duration(days: 14)),
          teamName: 'Team Gamma',
          members: ['Charlie Davis', 'Diana Evans'],
          isActive: false,
        ),
        _buildScheduleItem(
          weekStart: DateTime.now().add(const Duration(days: 21)),
          teamName: 'Team Alpha',
          members: ['John Doe', 'Jane Smith'],
          isActive: false,
        ),
      ],
    );
  }

  Widget _buildScheduleItem({
    required DateTime weekStart,
    required String teamName,
    required List<String> members,
    required bool isActive,
  }) {
    final weekEnd = weekStart.add(const Duration(days: 6));
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isActive ? AppTheme.primaryGreen.withOpacity(0.1) : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  teamName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (isActive)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.paidGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'CURRENT',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.paidGreen,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${_formatDate(weekStart)} - ${_formatDate(weekEnd)}',
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Members: ${members.join(', ')}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditRotationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const EditRotationDialog(),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}';
  }
}

class HistoryView extends StatelessWidget {
  const HistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Summary stats
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Monthly Summary',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem('Total Spent', '\$1,245', Icons.attach_money),
                    _buildStatItem('Avg/Week', '\$311', Icons.trending_up),
                    _buildStatItem('Teams', '4', Icons.group),
                  ],
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Past teams
        const Text(
          'Past Teams',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        
        // TODO: Replace with actual history data
        _buildHistoryItem(
          teamName: 'Team Beta',
          weekStart: DateTime.now().subtract(const Duration(days: 7)),
          totalSpent: 142.75,
          budgetLimit: 150.0,
          status: GroceryTeamStatus.completed,
        ),
        _buildHistoryItem(
          teamName: 'Team Gamma',
          weekStart: DateTime.now().subtract(const Duration(days: 14)),
          totalSpent: 168.30,
          budgetLimit: 150.0,
          status: GroceryTeamStatus.completed,
        ),
        _buildHistoryItem(
          teamName: 'Team Alpha',
          weekStart: DateTime.now().subtract(const Duration(days: 21)),
          totalSpent: 135.20,
          budgetLimit: 150.0,
          status: GroceryTeamStatus.completed,
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primaryGreen),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryItem({
    required String teamName,
    required DateTime weekStart,
    required double totalSpent,
    required double budgetLimit,
    required GroceryTeamStatus status,
  }) {
    final weekEnd = weekStart.add(const Duration(days: 6));
    final isOverBudget = totalSpent > budgetLimit;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  teamName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status.name.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(status),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${_formatDate(weekStart)} - ${_formatDate(weekEnd)}',
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  'Spent: \$${totalSpent.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: isOverBudget ? AppTheme.unpaidRed : AppTheme.primaryGreen,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  'Budget: \$${budgetLimit.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
                const Spacer(),
                if (isOverBudget)
                  Text(
                    'Over by \$${(totalSpent - budgetLimit).toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.unpaidRed,
                    ),
                  )
                else
                  Text(
                    'Under by \$${(budgetLimit - totalSpent).toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.paidGreen,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(GroceryTeamStatus status) {
    switch (status) {
      case GroceryTeamStatus.active:
        return AppTheme.paidGreen;
      case GroceryTeamStatus.completed:
        return AppTheme.primaryGreen;
      case GroceryTeamStatus.cancelled:
        return AppTheme.unpaidRed;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}';
  }
}

class AddExpenseDialog extends StatefulWidget {
  const AddExpenseDialog({super.key});

  @override
  State<AddExpenseDialog> createState() => _AddExpenseDialogState();
}

class _AddExpenseDialogState extends State<AddExpenseDialog> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _storeController = TextEditingController();
  final _itemsController = TextEditingController();
  final _notesController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _storeController.dispose();
    _itemsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Grocery Expense'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Weekly grocery shopping',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  hintText: '0.00',
                  prefixText: '\$',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Please enter a valid amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _storeController,
                decoration: const InputDecoration(
                  labelText: 'Store',
                  hintText: 'Walmart, Target, etc.',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the store name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Purchase Date',
                    border: OutlineInputBorder(),
                  ),
                  child: Text(_formatDate(_selectedDate)),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _itemsController,
                decoration: const InputDecoration(
                  labelText: 'Items (comma separated)',
                  hintText: 'Milk, Bread, Eggs, Vegetables',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveExpense,
          child: const Text('Add Expense'),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  void _saveExpense() {
    if (_formKey.currentState!.validate()) {
      // TODO: Save expense through BLoC
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Expense added successfully'),
          backgroundColor: AppTheme.paidGreen,
        ),
      );
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class ExpenseHistoryPage extends StatelessWidget {
  const ExpenseHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense History'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // TODO: Replace with actual expense data
          _buildExpenseCard(
            description: 'Weekly grocery shopping',
            amount: 45.30,
            store: 'Walmart',
            date: DateTime.now().subtract(const Duration(days: 1)),
            purchasedBy: 'John Doe',
            items: ['Milk', 'Bread', 'Eggs', 'Vegetables', 'Fruits'],
          ),
          _buildExpenseCard(
            description: 'Snacks and beverages',
            amount: 32.20,
            store: 'Target',
            date: DateTime.now().subtract(const Duration(days: 2)),
            purchasedBy: 'Jane Smith',
            items: ['Chips', 'Soda', 'Cookies', 'Juice'],
          ),
          _buildExpenseCard(
            description: 'Cleaning supplies',
            amount: 18.75,
            store: 'CVS',
            date: DateTime.now().subtract(const Duration(days: 3)),
            purchasedBy: 'John Doe',
            items: ['Detergent', 'Paper towels', 'Dish soap'],
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseCard({
    required String description,
    required double amount,
    required String store,
    required DateTime date,
    required String purchasedBy,
    required List<String> items,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    description,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  '\$${amount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryGreen,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.store, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(store, style: TextStyle(color: Colors.grey[600])),
                const SizedBox(width: 16),
                Icon(Icons.person, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(purchasedBy, style: TextStyle(color: Colors.grey[600])),
                const Spacer(),
                Text(
                  _formatDate(date),
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Items:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: items.map((item) => Chip(
                label: Text(
                  item,
                  style: const TextStyle(fontSize: 12),
                ),
                backgroundColor: AppTheme.cardBackground,
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class TeamSettingsDialog extends StatefulWidget {
  const TeamSettingsDialog({super.key});

  @override
  State<TeamSettingsDialog> createState() => _TeamSettingsDialogState();
}

class _TeamSettingsDialogState extends State<TeamSettingsDialog> {
  double _weeklyBudget = 150.0;
  int _rotationWeeks = 2;
  int _teamSize = 2;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Team Settings'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text('Weekly Budget'),
            subtitle: Text('\$${_weeklyBudget.toStringAsFixed(0)} per team'),
            trailing: SizedBox(
              width: 100,
              child: Slider(
                value: _weeklyBudget,
                min: 50,
                max: 300,
                divisions: 25,
                onChanged: (value) {
                  setState(() {
                    _weeklyBudget = value;
                  });
                },
              ),
            ),
          ),
          ListTile(
            title: const Text('Rotation Period'),
            subtitle: Text('$_rotationWeeks weeks per team'),
            trailing: SizedBox(
              width: 100,
              child: Slider(
                value: _rotationWeeks.toDouble(),
                min: 1,
                max: 4,
                divisions: 3,
                onChanged: (value) {
                  setState(() {
                    _rotationWeeks = value.round();
                  });
                },
              ),
            ),
          ),
          ListTile(
            title: const Text('Team Size'),
            subtitle: Text('$_teamSize members per team'),
            trailing: SizedBox(
              width: 100,
              child: Slider(
                value: _teamSize.toDouble(),
                min: 1,
                max: 4,
                divisions: 3,
                onChanged: (value) {
                  setState(() {
                    _teamSize = value.round();
                  });
                },
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            // TODO: Save settings through BLoC
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Settings updated successfully'),
                backgroundColor: AppTheme.paidGreen,
              ),
            );
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class EditRotationDialog extends StatefulWidget {
  const EditRotationDialog({super.key});

  @override
  State<EditRotationDialog> createState() => _EditRotationDialogState();
}

class _EditRotationDialogState extends State<EditRotationDialog> {
  // TODO: Implement rotation editing logic
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Rotation'),
      content: const Text('Rotation editing feature coming soon!'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
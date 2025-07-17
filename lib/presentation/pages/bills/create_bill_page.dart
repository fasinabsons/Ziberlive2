import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/bill.dart';
import '../../../core/constants/app_constants.dart';
import 'cubit/bill_cubit.dart';

class CreateBillPage extends StatefulWidget {
  final Bill? billToEdit;

  const CreateBillPage({super.key, this.billToEdit});

  @override
  State<CreateBillPage> createState() => _CreateBillPageState();
}

class _CreateBillPageState extends State<CreateBillPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _dueDateController = TextEditingController();

  BillType _selectedType = BillType.electricity;
  DateTime _selectedDueDate = DateTime.now().add(const Duration(days: 7));
  bool _isRecurring = false;
  RecurrenceType _recurrenceType = RecurrenceType.monthly;
  int _recurrenceInterval = 1;
  List<String> _selectedUsers = [];
  bool _useTemplate = false;
  String? _selectedTemplate;

  final List<BillTemplate> _templates = [
    BillTemplate(
      name: 'Monthly Electricity',
      type: BillType.electricity,
      isRecurring: true,
      recurrenceType: RecurrenceType.monthly,
    ),
    BillTemplate(
      name: 'Monthly Internet',
      type: BillType.internet,
      isRecurring: true,
      recurrenceType: RecurrenceType.monthly,
    ),
    BillTemplate(
      name: 'Weekly Community Cooking',
      type: BillType.communityCooking,
      isRecurring: true,
      recurrenceType: RecurrenceType.weekly,
    ),
    BillTemplate(
      name: 'Monthly Rent',
      type: BillType.rent,
      isRecurring: true,
      recurrenceType: RecurrenceType.monthly,
    ),
  ];

  @override
  void initState() {
    super.initState();
    if (widget.billToEdit != null) {
      _populateFieldsForEdit();
    }
    _dueDateController.text = _formatDate(_selectedDueDate);
  }

  void _populateFieldsForEdit() {
    final bill = widget.billToEdit!;
    _nameController.text = bill.name;
    _amountController.text = bill.amount.toString();
    _selectedType = bill.type;
    _selectedDueDate = bill.dueDate;
    _isRecurring = bill.isRecurring;
    if (bill.recurrencePattern != null) {
      _recurrenceType = bill.recurrencePattern!.type;
      _recurrenceInterval = bill.recurrencePattern!.interval;
    }
    _selectedUsers = List.from(bill.splitUserIds);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _dueDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.billToEdit != null ? 'Edit Bill' : 'Create Bill'),
        actions: [
          if (_useTemplate)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                setState(() {
                  _useTemplate = false;
                  _selectedTemplate = null;
                  _clearForm();
                });
              },
            ),
        ],
      ),
      body: BlocListener<BillCubit, BillState>(
        listener: (context, state) {
          if (state is BillCreated || state is BillUpdated) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  widget.billToEdit != null
                      ? 'Bill updated successfully'
                      : 'Bill created successfully',
                ),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is BillError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (!_useTemplate) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.bookmark_outline),
                            const SizedBox(width: 8),
                            const Text(
                              'Use Template',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const Spacer(),
                            Switch(
                              value: _useTemplate,
                              onChanged: (value) {
                                setState(() {
                                  _useTemplate = value;
                                  if (!value) {
                                    _selectedTemplate = null;
                                    _clearForm();
                                  }
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              if (_useTemplate) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Select Template',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        ...._templates.map((template) => RadioListTile<String>(
                              title: Text(template.name),
                              subtitle: Text(
                                '${template.type.name} • ${template.isRecurring ? "Recurring ${template.recurrenceType?.name}" : "One-time"}',
                              ),
                              value: template.name,
                              groupValue: _selectedTemplate,
                              onChanged: (value) {
                                setState(() {
                                  _selectedTemplate = value;
                                  _applyTemplate(template);
                                });
                              },
                            )),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Bill Details',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Bill Name',
                          hintText: 'e.g., Monthly Electricity',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.receipt),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a bill name';
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
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.attach_money),
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
                      DropdownButtonFormField<BillType>(
                        value: _selectedType,
                        decoration: const InputDecoration(
                          labelText: 'Bill Type',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.category),
                        ),
                        items: BillType.values.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(_getBillTypeDisplayName(type)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedType = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _dueDateController,
                        decoration: const InputDecoration(
                          labelText: 'Due Date',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        readOnly: true,
                        onTap: _selectDueDate,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Recurring Bill',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                          Switch(
                            value: _isRecurring,
                            onChanged: (value) {
                              setState(() {
                                _isRecurring = value;
                              });
                            },
                          ),
                        ],
                      ),
                      if (_isRecurring) ...[
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<RecurrenceType>(
                                value: _recurrenceType,
                                decoration: const InputDecoration(
                                  labelText: 'Frequency',
                                  border: OutlineInputBorder(),
                                ),
                                items: RecurrenceType.values.map((type) {
                                  return DropdownMenuItem(
                                    value: type,
                                    child: Text(type.name.toUpperCase()),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _recurrenceType = value!;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            SizedBox(
                              width: 100,
                              child: TextFormField(
                                initialValue: _recurrenceInterval.toString(),
                                decoration: const InputDecoration(
                                  labelText: 'Every',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                onChanged: (value) {
                                  _recurrenceInterval = int.tryParse(value) ?? 1;
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              BlocBuilder<BillCubit, BillState>(
                builder: (context, state) {
                  return ElevatedButton(
                    onPressed: state is BillLoading ? null : _saveBill,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: state is BillLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            widget.billToEdit != null ? 'Update Bill' : 'Create Bill',
                            style: const TextStyle(fontSize: 16),
                          ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _clearForm() {
    _nameController.clear();
    _amountController.clear();
    _selectedType = BillType.electricity;
    _selectedDueDate = DateTime.now().add(const Duration(days: 7));
    _dueDateController.text = _formatDate(_selectedDueDate);
    _isRecurring = false;
    _recurrenceType = RecurrenceType.monthly;
    _recurrenceInterval = 1;
  }

  void _applyTemplate(BillTemplate template) {
    setState(() {
      _nameController.text = template.name;
      _selectedType = template.type;
      _isRecurring = template.isRecurring;
      if (template.recurrenceType != null) {
        _recurrenceType = template.recurrenceType!;
      }
    });
  }

  Future<void> _selectDueDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() {
        _selectedDueDate = date;
        _dueDateController.text = _formatDate(date);
      });
    }
  }

  void _saveBill() {
    if (_formKey.currentState!.validate()) {
      final amount = double.parse(_amountController.text);
      
      RecurrencePattern? recurrencePattern;
      if (_isRecurring) {
        recurrencePattern = RecurrencePattern(
          type: _recurrenceType,
          interval: _recurrenceInterval,
        );
      }

      if (widget.billToEdit != null) {
        // Update existing bill
        final updatedBill = widget.billToEdit!.copyWith(
          name: _nameController.text,
          amount: amount,
          type: _selectedType,
          dueDate: _selectedDueDate,
          isRecurring: _isRecurring,
          recurrencePattern: recurrencePattern,
        );
        context.read<BillCubit>().updateBill(updatedBill);
      } else {
        // Create new bill
        context.read<BillCubit>().createBill(
          name: _nameController.text,
          amount: amount,
          type: _selectedType,
          dueDate: _selectedDueDate,
          isRecurring: _isRecurring,
          recurrencePattern: recurrencePattern,
        );
      }
    }
  }

  String _getBillTypeDisplayName(BillType type) {
    switch (type) {
      case BillType.rent:
        return 'Rent';
      case BillType.electricity:
        return 'Electricity';
      case BillType.internet:
        return 'Internet';
      case BillType.water:
        return 'Water';
      case BillType.communityCooking:
        return 'Community Cooking';
      case BillType.custom:
        return 'Custom';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class BillTemplate {
  final String name;
  final BillType type;
  final bool isRecurring;
  final RecurrenceType? recurrenceType;

  BillTemplate({
    required this.name,
    required this.type,
    required this.isRecurring,
    this.recurrenceType,
  });
}
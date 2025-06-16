import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../models/todo_item.dart';

class TodoItemWidget extends StatelessWidget {
  final TodoItem todo;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  final ValueChanged<bool> onToggleComplete;

  const TodoItemWidget({
    super.key,
    required this.todo,
    this.onDelete,
    this.onEdit,
    required this.onToggleComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Slidable(
        startActionPane: onEdit != null
            ? ActionPane(
                motion: const ScrollMotion(),
                children: [
                  SlidableAction(
                    onPressed: (_) => onEdit!(),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    icon: Icons.edit,
                    label: 'Edit',
                  ),
                ],
              )
            : null,
        endActionPane: onDelete != null
            ? ActionPane(
                motion: const ScrollMotion(),
                children: [
                  SlidableAction(
                    onPressed: (_) => onDelete!(),
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    icon: Icons.delete,
                    label: 'Delete',
                  ),
                ],
              )
            : null,
        child: ListTile(
          leading: Checkbox(
            value: todo.isCompleted,
            onChanged: (value) => onToggleComplete(value ?? false),
          ),
          title: Text(
            todo.title,
            style: TextStyle(
              decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
              color: todo.isCompleted ? Colors.grey : null,
            ),
          ),
          subtitle: todo.description.isNotEmpty
              ? Text(
                  todo.description,
                  style: TextStyle(
                    color: todo.isCompleted ? Colors.grey : null,
                  ),
                )
              : null,
          trailing: onEdit != null
              ? IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: onEdit,
                  tooltip: 'Edit',
                )
              : null,
        ),
      ),
    );
  }
}

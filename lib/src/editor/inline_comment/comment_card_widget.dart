import 'package:flutter/material.dart';
import 'inline_comment.dart';
import 'inline_comment_controller.dart';

/// A card widget that displays a single [InlineComment].
///
/// Shows the author name, relative time, comment content, and action buttons
/// (resolve / delete). The card is visually elevated when [isFocused] is true.
class CommentCard extends StatelessWidget {
  const CommentCard({
    super.key,
    required this.comment,
    required this.controller,
    this.isFocused = false,
    this.onFocusChanged,
  });

  final InlineComment comment;
  final InlineCommentController controller;
  final bool isFocused;
  final ValueChanged<bool>? onFocusChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onFocusChanged?.call(true),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.symmetric(vertical: 2),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          border: Border.all(
            color: isFocused
                ? Theme.of(context).colorScheme.primary
                : Colors.transparent,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(6),
          boxShadow: isFocused
              ? [
                  BoxShadow(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.15),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(context),
              const SizedBox(height: 4),
              Text(
                comment.content,
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: isFocused ? null : 3,
                overflow: isFocused ? null : TextOverflow.ellipsis,
              ),
              if (isFocused) ...[
                const SizedBox(height: 8),
                _buildActions(context),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            comment.authorName,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(
          _formatRelativeTime(comment.createdAt),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
        ),
        if (comment.isResolved) ...[
          const SizedBox(width: 4),
          Icon(
            Icons.check_circle_outline,
            size: 12,
            color: Theme.of(context).colorScheme.primary,
          ),
        ],
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (!comment.isResolved)
          TextButton.icon(
            onPressed: () async {
              await controller.onCommentDeleted(comment.id);
              controller.removeComment(comment.id);
            },
            icon: const Icon(Icons.delete_outline, size: 14),
            label: const Text('删除'),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
      ],
    );
  }

  String _formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'just now';
  }
}

import 'package:flutter/material.dart';

class FindMenuWidget extends StatefulWidget {
  const FindMenuWidget({
    super.key,
    required this.dismiss,
  });

  final VoidCallback dismiss;

  @override
  State<FindMenuWidget> createState() => _FindMenuWidgetState();
}

class _FindMenuWidgetState extends State<FindMenuWidget> {
  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.all(6.0),
          child: SizedBox(
            width: 200,
            height: 50,
            child: TextField(
              autofocus: true,
              controller: controller,
              maxLines: 1,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter text to search',
              ),
            ),
          ),
        ),
        IconButton(
          onPressed: () {
            debugPrint('search button clicked');
          },
          icon: const Icon(Icons.search),
        ),
        IconButton(
          onPressed: widget.dismiss,
          icon: const Icon(Icons.cancel_outlined),
        ),
      ],
    );
  }
}

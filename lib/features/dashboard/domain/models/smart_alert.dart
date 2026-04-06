enum AlertType { warning, success, info }

class SmartAlert {
  final String title;
  final String message;
  final AlertType type;

  const SmartAlert({
    required this.title,
    required this.message,
    required this.type,
  });
}

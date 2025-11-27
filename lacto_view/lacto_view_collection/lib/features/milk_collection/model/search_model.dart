class Search {
  final DateTime initial;
  final DateTime finaly;
  final List<String> producersName;
  final List<String> collectorsName;
  final List<String> propertysName;

  Search({
    required this.initial,
    required this.finaly,
    required this.producersName,
    required this.collectorsName,
    required this.propertysName,
  });

  factory Search.fromJson(Map<String, dynamic> json) {
    return Search(
      initial: json['id'],
      finaly: json['finaly'],
      producersName: List<String>.from(json['producersName'] ?? []),
      collectorsName: List<String>.from(json['collectosName'] ?? []),
      propertysName: List<String>.from(json['propertysName'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'inital': initial,
      'finaly': finaly,
      'producersName': producersName,
      'collectorsName': collectorsName,
      'propertysName': propertysName,
    };
  }
}

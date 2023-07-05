enum SnapshotErrorType { network, backend, data }

class SnapshotError {
  final String message;
  late SnapshotErrorType type;
  late bool temporary;

  SnapshotError(this.type, this.message, this.temporary);

  SnapshotError.network(this.message, this.temporary) {
    type = SnapshotErrorType.network;
    temporary = true;
  }

  SnapshotError.backend(this.message, this.temporary) {
    type = SnapshotErrorType.backend;
  }

  SnapshotError.data(this.message) {
    type = SnapshotErrorType.data;
    temporary = false;
  }

  factory SnapshotError.fromMap(Map<String, dynamic> json) {
    return SnapshotError(
      json['type'] as SnapshotErrorType,
      json['message'] as String,
      json['temporary'] as bool,
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type,
        'message': message,
        'temporary': temporary,
      };
}

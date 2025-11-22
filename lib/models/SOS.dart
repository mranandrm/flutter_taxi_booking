class SosModel {
  final int? id;
  final int? regionId;
  final String? title;
  final String? contactNumber;
  final int? status;
  final int? addedBy;

  SosModel({
    this.id,
    this.regionId,
    this.title,
    this.contactNumber,
    this.status,
    this.addedBy,
  });

  factory SosModel.fromJson(Map<String, dynamic> json) {
    return SosModel(
      id: _toInt(json['id']),
      regionId: _toInt(json['region_id']),
      title: json['title'],
      contactNumber: json['contact_number'],
      status: _toInt(json['status']),
      addedBy: _toInt(json['added_by']),
    );
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }
}

class FlutterWidgetData {
  final bool start;
  final String message;

  FlutterWidgetData(
    this.start,
    this.message,
  );

  FlutterWidgetData.fromJson(Map<String, dynamic> json)
      : message = json['message'],
        start = json['start'];

  Map<String, dynamic> toJson() => {'message': message, 'start': start};
}

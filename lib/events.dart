class MyEvent {

  String id;
  String type;
  String title;
  String location;
  DateTime date;
  String duration;
  String price;
  String placesNumber;
  DateTime end;
  String createdBy;
  String time;
  String adress;

  static final String columnCreatedBy = "createdBy";
  static final String columnDate = "date";
  static final String columnDuration = "duration";
  static final String columnLocation = "location";
  static final String columnNbPlaces = "nbPlaces";
  static final String columnNom = "nom";
  static final String columnPrice = "price";
  static final String columnTime = "time";
  static final String columnType = "type";
  static final String columnAdress = "adress";
  static final String columnId = "id";


  MyEvent({this.id, this.createdBy, this.date, this.duration, this.location, this.placesNumber, this.title, this.price, this.type, this.time, this.adress});


}
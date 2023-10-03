abstract class Model {
  Map<String, dynamic> toJson();
}

abstract class ModelFactory {
  Model fromJson(Map<Object?, Object?> map);
}

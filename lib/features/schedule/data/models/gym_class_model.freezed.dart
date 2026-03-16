// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'gym_class_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GymClassModel {

 String get id; String get name; String get description; String get trainerId; String get category; ClassLevel get classLevel;@TimestampConverter() DateTime get startTime; int get durationMinutes; int get capacity; List<String> get registeredUserIds;
/// Create a copy of GymClassModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GymClassModelCopyWith<GymClassModel> get copyWith => _$GymClassModelCopyWithImpl<GymClassModel>(this as GymClassModel, _$identity);

  /// Serializes this GymClassModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GymClassModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.trainerId, trainerId) || other.trainerId == trainerId)&&(identical(other.category, category) || other.category == category)&&(identical(other.classLevel, classLevel) || other.classLevel == classLevel)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.durationMinutes, durationMinutes) || other.durationMinutes == durationMinutes)&&(identical(other.capacity, capacity) || other.capacity == capacity)&&const DeepCollectionEquality().equals(other.registeredUserIds, registeredUserIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,trainerId,category,classLevel,startTime,durationMinutes,capacity,const DeepCollectionEquality().hash(registeredUserIds));

@override
String toString() {
  return 'GymClassModel(id: $id, name: $name, description: $description, trainerId: $trainerId, category: $category, classLevel: $classLevel, startTime: $startTime, durationMinutes: $durationMinutes, capacity: $capacity, registeredUserIds: $registeredUserIds)';
}


}

/// @nodoc
abstract mixin class $GymClassModelCopyWith<$Res>  {
  factory $GymClassModelCopyWith(GymClassModel value, $Res Function(GymClassModel) _then) = _$GymClassModelCopyWithImpl;
@useResult
$Res call({
 String id, String name, String description, String trainerId, String category, ClassLevel classLevel,@TimestampConverter() DateTime startTime, int durationMinutes, int capacity, List<String> registeredUserIds
});




}
/// @nodoc
class _$GymClassModelCopyWithImpl<$Res>
    implements $GymClassModelCopyWith<$Res> {
  _$GymClassModelCopyWithImpl(this._self, this._then);

  final GymClassModel _self;
  final $Res Function(GymClassModel) _then;

/// Create a copy of GymClassModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? description = null,Object? trainerId = null,Object? category = null,Object? classLevel = null,Object? startTime = null,Object? durationMinutes = null,Object? capacity = null,Object? registeredUserIds = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,trainerId: null == trainerId ? _self.trainerId : trainerId // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,classLevel: null == classLevel ? _self.classLevel : classLevel // ignore: cast_nullable_to_non_nullable
as ClassLevel,startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as DateTime,durationMinutes: null == durationMinutes ? _self.durationMinutes : durationMinutes // ignore: cast_nullable_to_non_nullable
as int,capacity: null == capacity ? _self.capacity : capacity // ignore: cast_nullable_to_non_nullable
as int,registeredUserIds: null == registeredUserIds ? _self.registeredUserIds : registeredUserIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [GymClassModel].
extension GymClassModelPatterns on GymClassModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GymClassModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GymClassModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GymClassModel value)  $default,){
final _that = this;
switch (_that) {
case _GymClassModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GymClassModel value)?  $default,){
final _that = this;
switch (_that) {
case _GymClassModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String description,  String trainerId,  String category,  ClassLevel classLevel, @TimestampConverter()  DateTime startTime,  int durationMinutes,  int capacity,  List<String> registeredUserIds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GymClassModel() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.trainerId,_that.category,_that.classLevel,_that.startTime,_that.durationMinutes,_that.capacity,_that.registeredUserIds);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String description,  String trainerId,  String category,  ClassLevel classLevel, @TimestampConverter()  DateTime startTime,  int durationMinutes,  int capacity,  List<String> registeredUserIds)  $default,) {final _that = this;
switch (_that) {
case _GymClassModel():
return $default(_that.id,_that.name,_that.description,_that.trainerId,_that.category,_that.classLevel,_that.startTime,_that.durationMinutes,_that.capacity,_that.registeredUserIds);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String description,  String trainerId,  String category,  ClassLevel classLevel, @TimestampConverter()  DateTime startTime,  int durationMinutes,  int capacity,  List<String> registeredUserIds)?  $default,) {final _that = this;
switch (_that) {
case _GymClassModel() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.trainerId,_that.category,_that.classLevel,_that.startTime,_that.durationMinutes,_that.capacity,_that.registeredUserIds);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GymClassModel extends GymClassModel {
  const _GymClassModel({required this.id, required this.name, required this.description, required this.trainerId, required this.category, required this.classLevel, @TimestampConverter() required this.startTime, required this.durationMinutes, required this.capacity, final  List<String> registeredUserIds = const []}): _registeredUserIds = registeredUserIds,super._();
  factory _GymClassModel.fromJson(Map<String, dynamic> json) => _$GymClassModelFromJson(json);

@override final  String id;
@override final  String name;
@override final  String description;
@override final  String trainerId;
@override final  String category;
@override final  ClassLevel classLevel;
@override@TimestampConverter() final  DateTime startTime;
@override final  int durationMinutes;
@override final  int capacity;
 final  List<String> _registeredUserIds;
@override@JsonKey() List<String> get registeredUserIds {
  if (_registeredUserIds is EqualUnmodifiableListView) return _registeredUserIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_registeredUserIds);
}


/// Create a copy of GymClassModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GymClassModelCopyWith<_GymClassModel> get copyWith => __$GymClassModelCopyWithImpl<_GymClassModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GymClassModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GymClassModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.trainerId, trainerId) || other.trainerId == trainerId)&&(identical(other.category, category) || other.category == category)&&(identical(other.classLevel, classLevel) || other.classLevel == classLevel)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.durationMinutes, durationMinutes) || other.durationMinutes == durationMinutes)&&(identical(other.capacity, capacity) || other.capacity == capacity)&&const DeepCollectionEquality().equals(other._registeredUserIds, _registeredUserIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,trainerId,category,classLevel,startTime,durationMinutes,capacity,const DeepCollectionEquality().hash(_registeredUserIds));

@override
String toString() {
  return 'GymClassModel(id: $id, name: $name, description: $description, trainerId: $trainerId, category: $category, classLevel: $classLevel, startTime: $startTime, durationMinutes: $durationMinutes, capacity: $capacity, registeredUserIds: $registeredUserIds)';
}


}

/// @nodoc
abstract mixin class _$GymClassModelCopyWith<$Res> implements $GymClassModelCopyWith<$Res> {
  factory _$GymClassModelCopyWith(_GymClassModel value, $Res Function(_GymClassModel) _then) = __$GymClassModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String description, String trainerId, String category, ClassLevel classLevel,@TimestampConverter() DateTime startTime, int durationMinutes, int capacity, List<String> registeredUserIds
});




}
/// @nodoc
class __$GymClassModelCopyWithImpl<$Res>
    implements _$GymClassModelCopyWith<$Res> {
  __$GymClassModelCopyWithImpl(this._self, this._then);

  final _GymClassModel _self;
  final $Res Function(_GymClassModel) _then;

/// Create a copy of GymClassModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? description = null,Object? trainerId = null,Object? category = null,Object? classLevel = null,Object? startTime = null,Object? durationMinutes = null,Object? capacity = null,Object? registeredUserIds = null,}) {
  return _then(_GymClassModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,trainerId: null == trainerId ? _self.trainerId : trainerId // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,classLevel: null == classLevel ? _self.classLevel : classLevel // ignore: cast_nullable_to_non_nullable
as ClassLevel,startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as DateTime,durationMinutes: null == durationMinutes ? _self.durationMinutes : durationMinutes // ignore: cast_nullable_to_non_nullable
as int,capacity: null == capacity ? _self.capacity : capacity // ignore: cast_nullable_to_non_nullable
as int,registeredUserIds: null == registeredUserIds ? _self._registeredUserIds : registeredUserIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on

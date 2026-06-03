// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'route_tracking.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$RouteTrackingState {
  LatLng get userPosition => throw _privateConstructorUsedError;
  List<LatLng> get routePoints => throw _privateConstructorUsedError;
  List<IntermediatePoint> get intermediatePoints =>
      throw _privateConstructorUsedError;
  RouteProgress get progress => throw _privateConstructorUsedError;
  bool get isTracking => throw _privateConstructorUsedError;
  DateTime? get startedAt => throw _privateConstructorUsedError;

  /// Create a copy of RouteTrackingState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RouteTrackingStateCopyWith<RouteTrackingState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RouteTrackingStateCopyWith<$Res> {
  factory $RouteTrackingStateCopyWith(
    RouteTrackingState value,
    $Res Function(RouteTrackingState) then,
  ) = _$RouteTrackingStateCopyWithImpl<$Res, RouteTrackingState>;
  @useResult
  $Res call({
    LatLng userPosition,
    List<LatLng> routePoints,
    List<IntermediatePoint> intermediatePoints,
    RouteProgress progress,
    bool isTracking,
    DateTime? startedAt,
  });

  $RouteProgressCopyWith<$Res> get progress;
}

/// @nodoc
class _$RouteTrackingStateCopyWithImpl<$Res, $Val extends RouteTrackingState>
    implements $RouteTrackingStateCopyWith<$Res> {
  _$RouteTrackingStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RouteTrackingState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userPosition = null,
    Object? routePoints = null,
    Object? intermediatePoints = null,
    Object? progress = null,
    Object? isTracking = null,
    Object? startedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            userPosition: null == userPosition
                ? _value.userPosition
                : userPosition // ignore: cast_nullable_to_non_nullable
                      as LatLng,
            routePoints: null == routePoints
                ? _value.routePoints
                : routePoints // ignore: cast_nullable_to_non_nullable
                      as List<LatLng>,
            intermediatePoints: null == intermediatePoints
                ? _value.intermediatePoints
                : intermediatePoints // ignore: cast_nullable_to_non_nullable
                      as List<IntermediatePoint>,
            progress: null == progress
                ? _value.progress
                : progress // ignore: cast_nullable_to_non_nullable
                      as RouteProgress,
            isTracking: null == isTracking
                ? _value.isTracking
                : isTracking // ignore: cast_nullable_to_non_nullable
                      as bool,
            startedAt: freezed == startedAt
                ? _value.startedAt
                : startedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }

  /// Create a copy of RouteTrackingState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $RouteProgressCopyWith<$Res> get progress {
    return $RouteProgressCopyWith<$Res>(_value.progress, (value) {
      return _then(_value.copyWith(progress: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$RouteTrackingStateImplCopyWith<$Res>
    implements $RouteTrackingStateCopyWith<$Res> {
  factory _$$RouteTrackingStateImplCopyWith(
    _$RouteTrackingStateImpl value,
    $Res Function(_$RouteTrackingStateImpl) then,
  ) = __$$RouteTrackingStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    LatLng userPosition,
    List<LatLng> routePoints,
    List<IntermediatePoint> intermediatePoints,
    RouteProgress progress,
    bool isTracking,
    DateTime? startedAt,
  });

  @override
  $RouteProgressCopyWith<$Res> get progress;
}

/// @nodoc
class __$$RouteTrackingStateImplCopyWithImpl<$Res>
    extends _$RouteTrackingStateCopyWithImpl<$Res, _$RouteTrackingStateImpl>
    implements _$$RouteTrackingStateImplCopyWith<$Res> {
  __$$RouteTrackingStateImplCopyWithImpl(
    _$RouteTrackingStateImpl _value,
    $Res Function(_$RouteTrackingStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RouteTrackingState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userPosition = null,
    Object? routePoints = null,
    Object? intermediatePoints = null,
    Object? progress = null,
    Object? isTracking = null,
    Object? startedAt = freezed,
  }) {
    return _then(
      _$RouteTrackingStateImpl(
        userPosition: null == userPosition
            ? _value.userPosition
            : userPosition // ignore: cast_nullable_to_non_nullable
                  as LatLng,
        routePoints: null == routePoints
            ? _value._routePoints
            : routePoints // ignore: cast_nullable_to_non_nullable
                  as List<LatLng>,
        intermediatePoints: null == intermediatePoints
            ? _value._intermediatePoints
            : intermediatePoints // ignore: cast_nullable_to_non_nullable
                  as List<IntermediatePoint>,
        progress: null == progress
            ? _value.progress
            : progress // ignore: cast_nullable_to_non_nullable
                  as RouteProgress,
        isTracking: null == isTracking
            ? _value.isTracking
            : isTracking // ignore: cast_nullable_to_non_nullable
                  as bool,
        startedAt: freezed == startedAt
            ? _value.startedAt
            : startedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc

class _$RouteTrackingStateImpl implements _RouteTrackingState {
  const _$RouteTrackingStateImpl({
    required this.userPosition,
    required final List<LatLng> routePoints,
    required final List<IntermediatePoint> intermediatePoints,
    required this.progress,
    required this.isTracking,
    required this.startedAt,
  }) : _routePoints = routePoints,
       _intermediatePoints = intermediatePoints;

  @override
  final LatLng userPosition;
  final List<LatLng> _routePoints;
  @override
  List<LatLng> get routePoints {
    if (_routePoints is EqualUnmodifiableListView) return _routePoints;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_routePoints);
  }

  final List<IntermediatePoint> _intermediatePoints;
  @override
  List<IntermediatePoint> get intermediatePoints {
    if (_intermediatePoints is EqualUnmodifiableListView)
      return _intermediatePoints;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_intermediatePoints);
  }

  @override
  final RouteProgress progress;
  @override
  final bool isTracking;
  @override
  final DateTime? startedAt;

  @override
  String toString() {
    return 'RouteTrackingState(userPosition: $userPosition, routePoints: $routePoints, intermediatePoints: $intermediatePoints, progress: $progress, isTracking: $isTracking, startedAt: $startedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RouteTrackingStateImpl &&
            (identical(other.userPosition, userPosition) ||
                other.userPosition == userPosition) &&
            const DeepCollectionEquality().equals(
              other._routePoints,
              _routePoints,
            ) &&
            const DeepCollectionEquality().equals(
              other._intermediatePoints,
              _intermediatePoints,
            ) &&
            (identical(other.progress, progress) ||
                other.progress == progress) &&
            (identical(other.isTracking, isTracking) ||
                other.isTracking == isTracking) &&
            (identical(other.startedAt, startedAt) ||
                other.startedAt == startedAt));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    userPosition,
    const DeepCollectionEquality().hash(_routePoints),
    const DeepCollectionEquality().hash(_intermediatePoints),
    progress,
    isTracking,
    startedAt,
  );

  /// Create a copy of RouteTrackingState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RouteTrackingStateImplCopyWith<_$RouteTrackingStateImpl> get copyWith =>
      __$$RouteTrackingStateImplCopyWithImpl<_$RouteTrackingStateImpl>(
        this,
        _$identity,
      );
}

abstract class _RouteTrackingState implements RouteTrackingState {
  const factory _RouteTrackingState({
    required final LatLng userPosition,
    required final List<LatLng> routePoints,
    required final List<IntermediatePoint> intermediatePoints,
    required final RouteProgress progress,
    required final bool isTracking,
    required final DateTime? startedAt,
  }) = _$RouteTrackingStateImpl;

  @override
  LatLng get userPosition;
  @override
  List<LatLng> get routePoints;
  @override
  List<IntermediatePoint> get intermediatePoints;
  @override
  RouteProgress get progress;
  @override
  bool get isTracking;
  @override
  DateTime? get startedAt;

  /// Create a copy of RouteTrackingState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RouteTrackingStateImplCopyWith<_$RouteTrackingStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$IntermediatePoint {
  int get index => throw _privateConstructorUsedError;
  LatLng get coordinates => throw _privateConstructorUsedError;
  String get label => throw _privateConstructorUsedError;
  WeatherSnapshot get weather => throw _privateConstructorUsedError;
  double get distanceFromStart => throw _privateConstructorUsedError;
  Duration get estimatedTimeToReach => throw _privateConstructorUsedError;

  /// Create a copy of IntermediatePoint
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $IntermediatePointCopyWith<IntermediatePoint> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $IntermediatePointCopyWith<$Res> {
  factory $IntermediatePointCopyWith(
    IntermediatePoint value,
    $Res Function(IntermediatePoint) then,
  ) = _$IntermediatePointCopyWithImpl<$Res, IntermediatePoint>;
  @useResult
  $Res call({
    int index,
    LatLng coordinates,
    String label,
    WeatherSnapshot weather,
    double distanceFromStart,
    Duration estimatedTimeToReach,
  });

  $WeatherSnapshotCopyWith<$Res> get weather;
}

/// @nodoc
class _$IntermediatePointCopyWithImpl<$Res, $Val extends IntermediatePoint>
    implements $IntermediatePointCopyWith<$Res> {
  _$IntermediatePointCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of IntermediatePoint
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? index = null,
    Object? coordinates = null,
    Object? label = null,
    Object? weather = null,
    Object? distanceFromStart = null,
    Object? estimatedTimeToReach = null,
  }) {
    return _then(
      _value.copyWith(
            index: null == index
                ? _value.index
                : index // ignore: cast_nullable_to_non_nullable
                      as int,
            coordinates: null == coordinates
                ? _value.coordinates
                : coordinates // ignore: cast_nullable_to_non_nullable
                      as LatLng,
            label: null == label
                ? _value.label
                : label // ignore: cast_nullable_to_non_nullable
                      as String,
            weather: null == weather
                ? _value.weather
                : weather // ignore: cast_nullable_to_non_nullable
                      as WeatherSnapshot,
            distanceFromStart: null == distanceFromStart
                ? _value.distanceFromStart
                : distanceFromStart // ignore: cast_nullable_to_non_nullable
                      as double,
            estimatedTimeToReach: null == estimatedTimeToReach
                ? _value.estimatedTimeToReach
                : estimatedTimeToReach // ignore: cast_nullable_to_non_nullable
                      as Duration,
          )
          as $Val,
    );
  }

  /// Create a copy of IntermediatePoint
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $WeatherSnapshotCopyWith<$Res> get weather {
    return $WeatherSnapshotCopyWith<$Res>(_value.weather, (value) {
      return _then(_value.copyWith(weather: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$IntermediatePointImplCopyWith<$Res>
    implements $IntermediatePointCopyWith<$Res> {
  factory _$$IntermediatePointImplCopyWith(
    _$IntermediatePointImpl value,
    $Res Function(_$IntermediatePointImpl) then,
  ) = __$$IntermediatePointImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int index,
    LatLng coordinates,
    String label,
    WeatherSnapshot weather,
    double distanceFromStart,
    Duration estimatedTimeToReach,
  });

  @override
  $WeatherSnapshotCopyWith<$Res> get weather;
}

/// @nodoc
class __$$IntermediatePointImplCopyWithImpl<$Res>
    extends _$IntermediatePointCopyWithImpl<$Res, _$IntermediatePointImpl>
    implements _$$IntermediatePointImplCopyWith<$Res> {
  __$$IntermediatePointImplCopyWithImpl(
    _$IntermediatePointImpl _value,
    $Res Function(_$IntermediatePointImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of IntermediatePoint
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? index = null,
    Object? coordinates = null,
    Object? label = null,
    Object? weather = null,
    Object? distanceFromStart = null,
    Object? estimatedTimeToReach = null,
  }) {
    return _then(
      _$IntermediatePointImpl(
        index: null == index
            ? _value.index
            : index // ignore: cast_nullable_to_non_nullable
                  as int,
        coordinates: null == coordinates
            ? _value.coordinates
            : coordinates // ignore: cast_nullable_to_non_nullable
                  as LatLng,
        label: null == label
            ? _value.label
            : label // ignore: cast_nullable_to_non_nullable
                  as String,
        weather: null == weather
            ? _value.weather
            : weather // ignore: cast_nullable_to_non_nullable
                  as WeatherSnapshot,
        distanceFromStart: null == distanceFromStart
            ? _value.distanceFromStart
            : distanceFromStart // ignore: cast_nullable_to_non_nullable
                  as double,
        estimatedTimeToReach: null == estimatedTimeToReach
            ? _value.estimatedTimeToReach
            : estimatedTimeToReach // ignore: cast_nullable_to_non_nullable
                  as Duration,
      ),
    );
  }
}

/// @nodoc

class _$IntermediatePointImpl implements _IntermediatePoint {
  const _$IntermediatePointImpl({
    required this.index,
    required this.coordinates,
    required this.label,
    required this.weather,
    required this.distanceFromStart,
    required this.estimatedTimeToReach,
  });

  @override
  final int index;
  @override
  final LatLng coordinates;
  @override
  final String label;
  @override
  final WeatherSnapshot weather;
  @override
  final double distanceFromStart;
  @override
  final Duration estimatedTimeToReach;

  @override
  String toString() {
    return 'IntermediatePoint(index: $index, coordinates: $coordinates, label: $label, weather: $weather, distanceFromStart: $distanceFromStart, estimatedTimeToReach: $estimatedTimeToReach)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$IntermediatePointImpl &&
            (identical(other.index, index) || other.index == index) &&
            (identical(other.coordinates, coordinates) ||
                other.coordinates == coordinates) &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.weather, weather) || other.weather == weather) &&
            (identical(other.distanceFromStart, distanceFromStart) ||
                other.distanceFromStart == distanceFromStart) &&
            (identical(other.estimatedTimeToReach, estimatedTimeToReach) ||
                other.estimatedTimeToReach == estimatedTimeToReach));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    index,
    coordinates,
    label,
    weather,
    distanceFromStart,
    estimatedTimeToReach,
  );

  /// Create a copy of IntermediatePoint
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$IntermediatePointImplCopyWith<_$IntermediatePointImpl> get copyWith =>
      __$$IntermediatePointImplCopyWithImpl<_$IntermediatePointImpl>(
        this,
        _$identity,
      );
}

abstract class _IntermediatePoint implements IntermediatePoint {
  const factory _IntermediatePoint({
    required final int index,
    required final LatLng coordinates,
    required final String label,
    required final WeatherSnapshot weather,
    required final double distanceFromStart,
    required final Duration estimatedTimeToReach,
  }) = _$IntermediatePointImpl;

  @override
  int get index;
  @override
  LatLng get coordinates;
  @override
  String get label;
  @override
  WeatherSnapshot get weather;
  @override
  double get distanceFromStart;
  @override
  Duration get estimatedTimeToReach;

  /// Create a copy of IntermediatePoint
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$IntermediatePointImplCopyWith<_$IntermediatePointImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$WeatherSnapshot {
  double get temperature => throw _privateConstructorUsedError;
  int get humidity => throw _privateConstructorUsedError;
  double get windSpeed => throw _privateConstructorUsedError;
  int get rainChance => throw _privateConstructorUsedError;
  String get condition => throw _privateConstructorUsedError;
  DateTime get fetchedAt => throw _privateConstructorUsedError;

  /// Create a copy of WeatherSnapshot
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WeatherSnapshotCopyWith<WeatherSnapshot> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WeatherSnapshotCopyWith<$Res> {
  factory $WeatherSnapshotCopyWith(
    WeatherSnapshot value,
    $Res Function(WeatherSnapshot) then,
  ) = _$WeatherSnapshotCopyWithImpl<$Res, WeatherSnapshot>;
  @useResult
  $Res call({
    double temperature,
    int humidity,
    double windSpeed,
    int rainChance,
    String condition,
    DateTime fetchedAt,
  });
}

/// @nodoc
class _$WeatherSnapshotCopyWithImpl<$Res, $Val extends WeatherSnapshot>
    implements $WeatherSnapshotCopyWith<$Res> {
  _$WeatherSnapshotCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WeatherSnapshot
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? temperature = null,
    Object? humidity = null,
    Object? windSpeed = null,
    Object? rainChance = null,
    Object? condition = null,
    Object? fetchedAt = null,
  }) {
    return _then(
      _value.copyWith(
            temperature: null == temperature
                ? _value.temperature
                : temperature // ignore: cast_nullable_to_non_nullable
                      as double,
            humidity: null == humidity
                ? _value.humidity
                : humidity // ignore: cast_nullable_to_non_nullable
                      as int,
            windSpeed: null == windSpeed
                ? _value.windSpeed
                : windSpeed // ignore: cast_nullable_to_non_nullable
                      as double,
            rainChance: null == rainChance
                ? _value.rainChance
                : rainChance // ignore: cast_nullable_to_non_nullable
                      as int,
            condition: null == condition
                ? _value.condition
                : condition // ignore: cast_nullable_to_non_nullable
                      as String,
            fetchedAt: null == fetchedAt
                ? _value.fetchedAt
                : fetchedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$WeatherSnapshotImplCopyWith<$Res>
    implements $WeatherSnapshotCopyWith<$Res> {
  factory _$$WeatherSnapshotImplCopyWith(
    _$WeatherSnapshotImpl value,
    $Res Function(_$WeatherSnapshotImpl) then,
  ) = __$$WeatherSnapshotImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    double temperature,
    int humidity,
    double windSpeed,
    int rainChance,
    String condition,
    DateTime fetchedAt,
  });
}

/// @nodoc
class __$$WeatherSnapshotImplCopyWithImpl<$Res>
    extends _$WeatherSnapshotCopyWithImpl<$Res, _$WeatherSnapshotImpl>
    implements _$$WeatherSnapshotImplCopyWith<$Res> {
  __$$WeatherSnapshotImplCopyWithImpl(
    _$WeatherSnapshotImpl _value,
    $Res Function(_$WeatherSnapshotImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WeatherSnapshot
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? temperature = null,
    Object? humidity = null,
    Object? windSpeed = null,
    Object? rainChance = null,
    Object? condition = null,
    Object? fetchedAt = null,
  }) {
    return _then(
      _$WeatherSnapshotImpl(
        temperature: null == temperature
            ? _value.temperature
            : temperature // ignore: cast_nullable_to_non_nullable
                  as double,
        humidity: null == humidity
            ? _value.humidity
            : humidity // ignore: cast_nullable_to_non_nullable
                  as int,
        windSpeed: null == windSpeed
            ? _value.windSpeed
            : windSpeed // ignore: cast_nullable_to_non_nullable
                  as double,
        rainChance: null == rainChance
            ? _value.rainChance
            : rainChance // ignore: cast_nullable_to_non_nullable
                  as int,
        condition: null == condition
            ? _value.condition
            : condition // ignore: cast_nullable_to_non_nullable
                  as String,
        fetchedAt: null == fetchedAt
            ? _value.fetchedAt
            : fetchedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc

class _$WeatherSnapshotImpl implements _WeatherSnapshot {
  const _$WeatherSnapshotImpl({
    required this.temperature,
    required this.humidity,
    required this.windSpeed,
    required this.rainChance,
    required this.condition,
    required this.fetchedAt,
  });

  @override
  final double temperature;
  @override
  final int humidity;
  @override
  final double windSpeed;
  @override
  final int rainChance;
  @override
  final String condition;
  @override
  final DateTime fetchedAt;

  @override
  String toString() {
    return 'WeatherSnapshot(temperature: $temperature, humidity: $humidity, windSpeed: $windSpeed, rainChance: $rainChance, condition: $condition, fetchedAt: $fetchedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WeatherSnapshotImpl &&
            (identical(other.temperature, temperature) ||
                other.temperature == temperature) &&
            (identical(other.humidity, humidity) ||
                other.humidity == humidity) &&
            (identical(other.windSpeed, windSpeed) ||
                other.windSpeed == windSpeed) &&
            (identical(other.rainChance, rainChance) ||
                other.rainChance == rainChance) &&
            (identical(other.condition, condition) ||
                other.condition == condition) &&
            (identical(other.fetchedAt, fetchedAt) ||
                other.fetchedAt == fetchedAt));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    temperature,
    humidity,
    windSpeed,
    rainChance,
    condition,
    fetchedAt,
  );

  /// Create a copy of WeatherSnapshot
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WeatherSnapshotImplCopyWith<_$WeatherSnapshotImpl> get copyWith =>
      __$$WeatherSnapshotImplCopyWithImpl<_$WeatherSnapshotImpl>(
        this,
        _$identity,
      );
}

abstract class _WeatherSnapshot implements WeatherSnapshot {
  const factory _WeatherSnapshot({
    required final double temperature,
    required final int humidity,
    required final double windSpeed,
    required final int rainChance,
    required final String condition,
    required final DateTime fetchedAt,
  }) = _$WeatherSnapshotImpl;

  @override
  double get temperature;
  @override
  int get humidity;
  @override
  double get windSpeed;
  @override
  int get rainChance;
  @override
  String get condition;
  @override
  DateTime get fetchedAt;

  /// Create a copy of WeatherSnapshot
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WeatherSnapshotImplCopyWith<_$WeatherSnapshotImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$RouteProgress {
  double get percentComplete => throw _privateConstructorUsedError;
  Duration get timeElapsed => throw _privateConstructorUsedError;
  Duration get estimatedTimeRemaining => throw _privateConstructorUsedError;
  double get distanceTravelledKm => throw _privateConstructorUsedError;
  double get totalDistanceKm => throw _privateConstructorUsedError;
  int get nextIntermediatePointIndex => throw _privateConstructorUsedError;

  /// Create a copy of RouteProgress
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RouteProgressCopyWith<RouteProgress> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RouteProgressCopyWith<$Res> {
  factory $RouteProgressCopyWith(
    RouteProgress value,
    $Res Function(RouteProgress) then,
  ) = _$RouteProgressCopyWithImpl<$Res, RouteProgress>;
  @useResult
  $Res call({
    double percentComplete,
    Duration timeElapsed,
    Duration estimatedTimeRemaining,
    double distanceTravelledKm,
    double totalDistanceKm,
    int nextIntermediatePointIndex,
  });
}

/// @nodoc
class _$RouteProgressCopyWithImpl<$Res, $Val extends RouteProgress>
    implements $RouteProgressCopyWith<$Res> {
  _$RouteProgressCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RouteProgress
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? percentComplete = null,
    Object? timeElapsed = null,
    Object? estimatedTimeRemaining = null,
    Object? distanceTravelledKm = null,
    Object? totalDistanceKm = null,
    Object? nextIntermediatePointIndex = null,
  }) {
    return _then(
      _value.copyWith(
            percentComplete: null == percentComplete
                ? _value.percentComplete
                : percentComplete // ignore: cast_nullable_to_non_nullable
                      as double,
            timeElapsed: null == timeElapsed
                ? _value.timeElapsed
                : timeElapsed // ignore: cast_nullable_to_non_nullable
                      as Duration,
            estimatedTimeRemaining: null == estimatedTimeRemaining
                ? _value.estimatedTimeRemaining
                : estimatedTimeRemaining // ignore: cast_nullable_to_non_nullable
                      as Duration,
            distanceTravelledKm: null == distanceTravelledKm
                ? _value.distanceTravelledKm
                : distanceTravelledKm // ignore: cast_nullable_to_non_nullable
                      as double,
            totalDistanceKm: null == totalDistanceKm
                ? _value.totalDistanceKm
                : totalDistanceKm // ignore: cast_nullable_to_non_nullable
                      as double,
            nextIntermediatePointIndex: null == nextIntermediatePointIndex
                ? _value.nextIntermediatePointIndex
                : nextIntermediatePointIndex // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RouteProgressImplCopyWith<$Res>
    implements $RouteProgressCopyWith<$Res> {
  factory _$$RouteProgressImplCopyWith(
    _$RouteProgressImpl value,
    $Res Function(_$RouteProgressImpl) then,
  ) = __$$RouteProgressImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    double percentComplete,
    Duration timeElapsed,
    Duration estimatedTimeRemaining,
    double distanceTravelledKm,
    double totalDistanceKm,
    int nextIntermediatePointIndex,
  });
}

/// @nodoc
class __$$RouteProgressImplCopyWithImpl<$Res>
    extends _$RouteProgressCopyWithImpl<$Res, _$RouteProgressImpl>
    implements _$$RouteProgressImplCopyWith<$Res> {
  __$$RouteProgressImplCopyWithImpl(
    _$RouteProgressImpl _value,
    $Res Function(_$RouteProgressImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RouteProgress
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? percentComplete = null,
    Object? timeElapsed = null,
    Object? estimatedTimeRemaining = null,
    Object? distanceTravelledKm = null,
    Object? totalDistanceKm = null,
    Object? nextIntermediatePointIndex = null,
  }) {
    return _then(
      _$RouteProgressImpl(
        percentComplete: null == percentComplete
            ? _value.percentComplete
            : percentComplete // ignore: cast_nullable_to_non_nullable
                  as double,
        timeElapsed: null == timeElapsed
            ? _value.timeElapsed
            : timeElapsed // ignore: cast_nullable_to_non_nullable
                  as Duration,
        estimatedTimeRemaining: null == estimatedTimeRemaining
            ? _value.estimatedTimeRemaining
            : estimatedTimeRemaining // ignore: cast_nullable_to_non_nullable
                  as Duration,
        distanceTravelledKm: null == distanceTravelledKm
            ? _value.distanceTravelledKm
            : distanceTravelledKm // ignore: cast_nullable_to_non_nullable
                  as double,
        totalDistanceKm: null == totalDistanceKm
            ? _value.totalDistanceKm
            : totalDistanceKm // ignore: cast_nullable_to_non_nullable
                  as double,
        nextIntermediatePointIndex: null == nextIntermediatePointIndex
            ? _value.nextIntermediatePointIndex
            : nextIntermediatePointIndex // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc

class _$RouteProgressImpl implements _RouteProgress {
  const _$RouteProgressImpl({
    required this.percentComplete,
    required this.timeElapsed,
    required this.estimatedTimeRemaining,
    required this.distanceTravelledKm,
    required this.totalDistanceKm,
    required this.nextIntermediatePointIndex,
  });

  @override
  final double percentComplete;
  @override
  final Duration timeElapsed;
  @override
  final Duration estimatedTimeRemaining;
  @override
  final double distanceTravelledKm;
  @override
  final double totalDistanceKm;
  @override
  final int nextIntermediatePointIndex;

  @override
  String toString() {
    return 'RouteProgress(percentComplete: $percentComplete, timeElapsed: $timeElapsed, estimatedTimeRemaining: $estimatedTimeRemaining, distanceTravelledKm: $distanceTravelledKm, totalDistanceKm: $totalDistanceKm, nextIntermediatePointIndex: $nextIntermediatePointIndex)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RouteProgressImpl &&
            (identical(other.percentComplete, percentComplete) ||
                other.percentComplete == percentComplete) &&
            (identical(other.timeElapsed, timeElapsed) ||
                other.timeElapsed == timeElapsed) &&
            (identical(other.estimatedTimeRemaining, estimatedTimeRemaining) ||
                other.estimatedTimeRemaining == estimatedTimeRemaining) &&
            (identical(other.distanceTravelledKm, distanceTravelledKm) ||
                other.distanceTravelledKm == distanceTravelledKm) &&
            (identical(other.totalDistanceKm, totalDistanceKm) ||
                other.totalDistanceKm == totalDistanceKm) &&
            (identical(
                  other.nextIntermediatePointIndex,
                  nextIntermediatePointIndex,
                ) ||
                other.nextIntermediatePointIndex ==
                    nextIntermediatePointIndex));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    percentComplete,
    timeElapsed,
    estimatedTimeRemaining,
    distanceTravelledKm,
    totalDistanceKm,
    nextIntermediatePointIndex,
  );

  /// Create a copy of RouteProgress
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RouteProgressImplCopyWith<_$RouteProgressImpl> get copyWith =>
      __$$RouteProgressImplCopyWithImpl<_$RouteProgressImpl>(this, _$identity);
}

abstract class _RouteProgress implements RouteProgress {
  const factory _RouteProgress({
    required final double percentComplete,
    required final Duration timeElapsed,
    required final Duration estimatedTimeRemaining,
    required final double distanceTravelledKm,
    required final double totalDistanceKm,
    required final int nextIntermediatePointIndex,
  }) = _$RouteProgressImpl;

  @override
  double get percentComplete;
  @override
  Duration get timeElapsed;
  @override
  Duration get estimatedTimeRemaining;
  @override
  double get distanceTravelledKm;
  @override
  double get totalDistanceKm;
  @override
  int get nextIntermediatePointIndex;

  /// Create a copy of RouteProgress
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RouteProgressImplCopyWith<_$RouteProgressImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

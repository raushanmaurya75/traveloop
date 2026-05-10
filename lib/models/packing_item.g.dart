// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'packing_item.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetPackingItemCollection on Isar {
  IsarCollection<PackingItem> get packingItems => this.collection();
}

const PackingItemSchema = CollectionSchema(
  name: r'PackingItem',
  id: -5854102336506157692,
  properties: {
    r'isPacked': PropertySchema(
      id: 0,
      name: r'isPacked',
      type: IsarType.bool,
    ),
    r'name': PropertySchema(
      id: 1,
      name: r'name',
      type: IsarType.string,
    ),
    r'tripId': PropertySchema(
      id: 2,
      name: r'tripId',
      type: IsarType.long,
    )
  },
  estimateSize: _packingItemEstimateSize,
  serialize: _packingItemSerialize,
  deserialize: _packingItemDeserialize,
  deserializeProp: _packingItemDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _packingItemGetId,
  getLinks: _packingItemGetLinks,
  attach: _packingItemAttach,
  version: '3.1.0+1',
);

int _packingItemEstimateSize(
  PackingItem object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.name.length * 3;
  return bytesCount;
}

void _packingItemSerialize(
  PackingItem object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeBool(offsets[0], object.isPacked);
  writer.writeString(offsets[1], object.name);
  writer.writeLong(offsets[2], object.tripId);
}

PackingItem _packingItemDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PackingItem();
  object.id = id;
  object.isPacked = reader.readBool(offsets[0]);
  object.name = reader.readString(offsets[1]);
  object.tripId = reader.readLong(offsets[2]);
  return object;
}

P _packingItemDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readBool(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _packingItemGetId(PackingItem object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _packingItemGetLinks(PackingItem object) {
  return [];
}

void _packingItemAttach(
    IsarCollection<dynamic> col, Id id, PackingItem object) {
  object.id = id;
}

extension PackingItemQueryWhereSort
    on QueryBuilder<PackingItem, PackingItem, QWhere> {
  QueryBuilder<PackingItem, PackingItem, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension PackingItemQueryWhere
    on QueryBuilder<PackingItem, PackingItem, QWhereClause> {
  QueryBuilder<PackingItem, PackingItem, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<PackingItem, PackingItem, QAfterWhereClause> idNotEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<PackingItem, PackingItem, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<PackingItem, PackingItem, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<PackingItem, PackingItem, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension PackingItemQueryFilter
    on QueryBuilder<PackingItem, PackingItem, QFilterCondition> {
  QueryBuilder<PackingItem, PackingItem, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<PackingItem, PackingItem, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<PackingItem, PackingItem, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<PackingItem, PackingItem, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PackingItem, PackingItem, QAfterFilterCondition> isPackedEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isPacked',
        value: value,
      ));
    });
  }

  QueryBuilder<PackingItem, PackingItem, QAfterFilterCondition> nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PackingItem, PackingItem, QAfterFilterCondition> nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PackingItem, PackingItem, QAfterFilterCondition> nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PackingItem, PackingItem, QAfterFilterCondition> nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'name',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PackingItem, PackingItem, QAfterFilterCondition> nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PackingItem, PackingItem, QAfterFilterCondition> nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PackingItem, PackingItem, QAfterFilterCondition> nameContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PackingItem, PackingItem, QAfterFilterCondition> nameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PackingItem, PackingItem, QAfterFilterCondition> nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<PackingItem, PackingItem, QAfterFilterCondition>
      nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<PackingItem, PackingItem, QAfterFilterCondition> tripIdEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tripId',
        value: value,
      ));
    });
  }

  QueryBuilder<PackingItem, PackingItem, QAfterFilterCondition>
      tripIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'tripId',
        value: value,
      ));
    });
  }

  QueryBuilder<PackingItem, PackingItem, QAfterFilterCondition> tripIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'tripId',
        value: value,
      ));
    });
  }

  QueryBuilder<PackingItem, PackingItem, QAfterFilterCondition> tripIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'tripId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension PackingItemQueryObject
    on QueryBuilder<PackingItem, PackingItem, QFilterCondition> {}

extension PackingItemQueryLinks
    on QueryBuilder<PackingItem, PackingItem, QFilterCondition> {}

extension PackingItemQuerySortBy
    on QueryBuilder<PackingItem, PackingItem, QSortBy> {
  QueryBuilder<PackingItem, PackingItem, QAfterSortBy> sortByIsPacked() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPacked', Sort.asc);
    });
  }

  QueryBuilder<PackingItem, PackingItem, QAfterSortBy> sortByIsPackedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPacked', Sort.desc);
    });
  }

  QueryBuilder<PackingItem, PackingItem, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<PackingItem, PackingItem, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<PackingItem, PackingItem, QAfterSortBy> sortByTripId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tripId', Sort.asc);
    });
  }

  QueryBuilder<PackingItem, PackingItem, QAfterSortBy> sortByTripIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tripId', Sort.desc);
    });
  }
}

extension PackingItemQuerySortThenBy
    on QueryBuilder<PackingItem, PackingItem, QSortThenBy> {
  QueryBuilder<PackingItem, PackingItem, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<PackingItem, PackingItem, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<PackingItem, PackingItem, QAfterSortBy> thenByIsPacked() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPacked', Sort.asc);
    });
  }

  QueryBuilder<PackingItem, PackingItem, QAfterSortBy> thenByIsPackedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPacked', Sort.desc);
    });
  }

  QueryBuilder<PackingItem, PackingItem, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<PackingItem, PackingItem, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<PackingItem, PackingItem, QAfterSortBy> thenByTripId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tripId', Sort.asc);
    });
  }

  QueryBuilder<PackingItem, PackingItem, QAfterSortBy> thenByTripIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tripId', Sort.desc);
    });
  }
}

extension PackingItemQueryWhereDistinct
    on QueryBuilder<PackingItem, PackingItem, QDistinct> {
  QueryBuilder<PackingItem, PackingItem, QDistinct> distinctByIsPacked() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isPacked');
    });
  }

  QueryBuilder<PackingItem, PackingItem, QDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PackingItem, PackingItem, QDistinct> distinctByTripId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tripId');
    });
  }
}

extension PackingItemQueryProperty
    on QueryBuilder<PackingItem, PackingItem, QQueryProperty> {
  QueryBuilder<PackingItem, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<PackingItem, bool, QQueryOperations> isPackedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isPacked');
    });
  }

  QueryBuilder<PackingItem, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<PackingItem, int, QQueryOperations> tripIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tripId');
    });
  }
}

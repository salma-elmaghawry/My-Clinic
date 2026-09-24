import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_clinic/core/bloc/base_bloc.dart';
import 'package:my_clinic/core/helpers/id_generator.dart';
import 'package:my_clinic/features/prescription/domain/entities/drug.dart';
import 'package:my_clinic/features/prescription/domain/entities/drug_category.dart';
import 'package:my_clinic/features/prescription/repository/drugs_repository.dart';

class DrugDatabaseState extends BaseState {
  final List<Drug> drugs;
  final String query;
  final DrugCategory? category;

  const DrugDatabaseState({
    super.status,
    super.message,
    this.drugs = const [],
    this.query = '',
    this.category,
  });

  List<Drug> get visibleDrugs {
    final q = query.trim().toLowerCase();
    return drugs.where((d) {
      if (category != null && d.category != category) return false;
      if (q.isEmpty) return true;
      return d.name.toLowerCase().contains(q) ||
          d.genericName.toLowerCase().contains(q);
    }).toList();
  }

  /// Only categories that actually have drugs, for the filter chips.
  List<DrugCategory> get availableCategories => DrugCategory.values
      .where((c) => drugs.any((d) => d.category == c))
      .toList();

  DrugDatabaseState copyWith({
    Status? status,
    String? message,
    List<Drug>? drugs,
    String? query,
    DrugCategory? category,
    bool clearCategory = false,
  }) {
    return DrugDatabaseState(
      status: status ?? this.status,
      message: message ?? this.message,
      drugs: drugs ?? this.drugs,
      query: query ?? this.query,
      category: clearCategory ? null : (category ?? this.category),
    );
  }

  @override
  List<Object?> get props => [status, message, drugs, query, category];
}

class DrugDatabaseCubit extends Cubit<DrugDatabaseState> {
  final DrugsRepository _repository;

  DrugDatabaseCubit(this._repository) : super(const DrugDatabaseState());

  Future<void> load() async {
    emit(state.copyWith(status: Status.loading));
    final result = await _repository.getDrugs();
    if (isClosed) return;
    result.fold(
      (f) => emit(state.copyWith(status: Status.failure, message: f.message)),
      (drugs) => emit(state.copyWith(status: Status.success, drugs: drugs)),
    );
  }

  void setQuery(String query) => emit(state.copyWith(query: query));

  void setCategory(DrugCategory? category) => emit(
    category == null
        ? state.copyWith(clearCategory: true)
        : state.copyWith(category: category),
  );

  Future<void> addCustomDrug({
    required String name,
    required String genericName,
    required String commonDose,
    required DrugCategory category,
    required String defaultFrequency,
    required String defaultWhenToTake,
  }) async {
    String? orNull(String s) => s.trim().isEmpty ? null : s.trim();
    await _repository.addCustomDrug(
      Drug(
        id: generateId(),
        name: name.trim(),
        genericName: genericName.trim(),
        commonDose: commonDose.trim(),
        category: category,
        defaultFrequency: orNull(defaultFrequency),
        defaultWhenToTake: orNull(defaultWhenToTake),
        isCustom: true,
      ),
    );
    await load();
  }

  Future<void> deleteCustomDrug(Drug drug) async {
    if (!drug.isCustom) return;
    await _repository.deleteCustomDrug(drug.id);
    await load();
  }
}

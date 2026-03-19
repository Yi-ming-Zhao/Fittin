import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fittin_v2/src/application/auth_provider.dart';
import 'package:fittin_v2/src/application/active_session_provider.dart';
import 'package:fittin_v2/src/data/database_repository.dart';
import 'package:fittin_v2/src/domain/models/training_plan.dart';

final localPlanRepositoryProvider = Provider<LocalPlanRepository>((ref) {
  return LocalPlanRepository(
    repository: ref.watch(databaseRepositoryProvider),
    ownerUserId: ref.watch(currentUserIdProvider),
  );
});

class LocalPlanRepository {
  LocalPlanRepository({
    required DatabaseRepository repository,
    required String? ownerUserId,
  }) : _repository = repository,
       _ownerUserId = ownerUserId;

  final DatabaseRepository _repository;
  final String? _ownerUserId;

  Future<void> ensureDefaultProgramSeeded() {
    return _repository.ensureDefaultProgramSeeded();
  }

  Future<List<StoredTemplateRecord>> fetchTemplates() {
    return _repository.fetchTemplates(ownerUserId: _ownerUserId);
  }

  Future<StoredTemplateRecord?> fetchStoredTemplate(String templateId) {
    return _repository.fetchStoredTemplate(
      templateId,
      ownerUserId: _ownerUserId,
    );
  }

  Future<void> saveTemplate(
    PlanTemplate template, {
    bool isBuiltIn = false,
    String? sourceTemplateId,
  }) {
    return _repository.saveTemplate(
      template,
      isBuiltIn: isBuiltIn,
      sourceTemplateId: sourceTemplateId,
      ownerUserId: _ownerUserId,
    );
  }

  Future<StoredTemplateRecord> saveEditedTemplate({
    required PlanTemplate draft,
    String? originalTemplateId,
  }) {
    return _repository.saveEditedTemplate(
      draft: draft,
      originalTemplateId: originalTemplateId,
    );
  }

  Future<PlanTemplate> importSharedTemplate(PlanTemplate template) {
    return _repository.importSharedTemplate(template);
  }
}

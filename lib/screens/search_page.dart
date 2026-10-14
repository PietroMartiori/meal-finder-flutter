import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_controllers.dart';
import '../models/editorial_metadata.dart';
import '../models/meal_summary.dart';
import '../services/meal_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_states.dart';
import '../widgets/meal_card.dart';
import 'recipe_detail_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final MealService _mealService = MealService();
  final TextEditingController _textController = TextEditingController();
  Timer? _debounce;
  MealSearchRequestController? _requestController;
  int _lastRequestRevision = 0;
  MealFilterType _activeType = MealFilterType.category;
  String? _filterValue;
  Future<List<MealSummary>>? _results;
  bool _settingText = false;

  @override
  void initState() {
    super.initState();
    _textController.addListener(_onTextChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller = context.read<MealSearchRequestController>();
    if (controller == _requestController) return;
    _requestController?.removeListener(_applyExternalRequest);
    _requestController = controller..addListener(_applyExternalRequest);
    _applyExternalRequest();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _requestController?.removeListener(_applyExternalRequest);
    _textController
      ..removeListener(_onTextChanged)
      ..dispose();
    super.dispose();
  }

  void _applyExternalRequest() {
    final request = _requestController;
    if (!mounted ||
        request == null ||
        request.revision == _lastRequestRevision) {
      return;
    }
    _lastRequestRevision = request.revision;
    setState(() {
      _activeType = request.filterType ?? MealFilterType.category;
      _filterValue = request.apiValue;
      _settingText = true;
      _textController.text = request.apiValue == null
          ? ''
          : ApiValueMapper.label(request.apiValue!);
      _settingText = false;
      _results = request.apiValue == null
          ? null
          : _loadFilter(request.filterType!, request.apiValue!);
    });
  }

  void _onTextChanged() {
    if (_settingText) return;
    _debounce?.cancel();
    setState(() => _filterValue = null);
    final value = _textController.text.trim();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      setState(() {
        _results = value.isEmpty
            ? null
            : _mealService.searchMeals(ApiValueMapper.searchTermForApi(value));
      });
    });
  }

  Future<List<MealSummary>> _loadFilter(MealFilterType type, String value) {
    return switch (type) {
      MealFilterType.area => _mealService.filterByArea(value),
      MealFilterType.ingredient => _mealService.filterByIngredient(value),
      MealFilterType.category => _mealService.filterByCategory(value),
    };
  }

  Future<void> _pickFilter(MealFilterType type) async {
    setState(() => _activeType = type);
    try {
      final values = switch (type) {
        MealFilterType.area => await _mealService.listAreas(),
        MealFilterType.ingredient => await _mealService.listIngredients(),
        MealFilterType.category => await _mealService.listCategories(),
      };
      if (!mounted) return;
      final value = await showModalBottomSheet<String>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => _FilterPicker(type: type, values: values),
      );
      if (value == null || !mounted) return;
      _settingText = true;
      _textController.text = ApiValueMapper.label(value);
      _settingText = false;
      setState(() {
        _filterValue = value;
        _results = _loadFilter(type, value);
      });
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Não foi possível carregar as opções de filtro.'),
          ),
        );
      }
    }
  }

  void _clearFilters() {
    _debounce?.cancel();
    _settingText = true;
    _textController.clear();
    _settingText = false;
    setState(() {
      _filterValue = null;
      _results = null;
    });
  }

  void _retryResults() {
    final filter = _filterValue;
    final query = _textController.text.trim();
    setState(() {
      _results = filter != null
          ? _loadFilter(_activeType, filter)
          : query.isEmpty
          ? null
          : _mealService.searchMeals(ApiValueMapper.searchTermForApi(query));
    });
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    bottom: false,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 26, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Encontre sua próxima\nreceita favorita',
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: 8),
          const Text(
            'Uma boa receita começa com curiosidade.',
            style: TextStyle(color: AppTheme.mutedText, fontSize: 16),
          ),
          const SizedBox(height: 27),
          TextField(
            controller: _textController,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) {
              _debounce?.cancel();
              final value = _textController.text.trim();
              setState(() {
                _results = value.isEmpty
                    ? null
                    : _mealService.searchMeals(
                        ApiValueMapper.searchTermForApi(value),
                      );
              });
            },
            decoration: InputDecoration(
              hintText: 'Encontrar pratos',
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: AppTheme.primary,
              ),
              suffixIcon: _textController.text.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: _clearFilters,
                    ),
            ),
          ),
          const SizedBox(height: 20),
          _FilterTabs(activeType: _activeType, onSelected: _pickFilter),
          const SizedBox(height: 16),
          if (_filterValue != null)
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.softSurface,
                    borderRadius: BorderRadius.circular(17),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        ApiValueMapper.label(_filterValue!),
                        style: const TextStyle(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(width: 7),
                      const Icon(
                        Icons.close_rounded,
                        color: AppTheme.primary,
                        size: 17,
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _clearFilters,
                  child: const Text('Limpar filtros'),
                ),
              ],
            ),
          if (_filterValue != null) const SizedBox(height: 10),
          Expanded(child: _buildResults()),
        ],
      ),
    ),
  );

  Widget _buildResults() {
    final future = _results;
    if (future == null) {
      return const EmptyState(
        message: 'Busque pelo nome de um prato ou escolha um filtro.',
        icon: Icons.manage_search_rounded,
      );
    }
    return FutureBuilder<List<MealSummary>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingState(message: 'Encontrando receitas...');
        }
        if (snapshot.hasError) {
          return ErrorState(onRetry: _retryResults);
        }
        final meals = snapshot.data ?? const <MealSummary>[];
        if (meals.isEmpty) {
          return const EmptyState(
            message: 'Nenhuma receita encontrada. Tente outro termo ou filtro.',
          );
        }
        final description = _filterValue ?? _textController.text.trim();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 13),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      description.isEmpty
                          ? 'Receitas'
                          : 'Receitas de ${ApiValueMapper.label(description)}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  Text(
                    '${meals.length} resultados',
                    style: const TextStyle(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.only(bottom: 110),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 14,
                  childAspectRatio: .70,
                ),
                itemCount: meals.length,
                itemBuilder: (context, index) {
                  final meal = meals[index];
                  return MealCard(
                    meal: meal,
                    compact: true,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => RecipeDetailPage(idMeal: meal.idMeal),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _FilterTabs extends StatelessWidget {
  const _FilterTabs({required this.activeType, required this.onSelected});
  final MealFilterType activeType;
  final ValueChanged<MealFilterType> onSelected;

  @override
  Widget build(BuildContext context) {
    const tabs = <(MealFilterType, String)>[
      (MealFilterType.area, 'Por região'),
      (MealFilterType.ingredient, 'Por ingrediente'),
      (MealFilterType.category, 'Por categoria'),
    ];
    return Row(
      children: List.generate(tabs.length, (index) {
        final tab = tabs[index];
        final selected = tab.$1 == activeType;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: index == tabs.length - 1 ? 0 : 8),
            child: ChoiceChip(
              label: FittedBox(child: Text(tab.$2)),
              selected: selected,
              showCheckmark: false,
              selectedColor: AppTheme.primary,
              labelPadding: const EdgeInsets.symmetric(horizontal: 5),
              labelStyle: TextStyle(
                color: selected ? Colors.white : AppTheme.mutedText,
                fontWeight: FontWeight.w700,
              ),
              onSelected: (_) => onSelected(tab.$1),
            ),
          ),
        );
      }),
    );
  }
}

class _FilterPicker extends StatefulWidget {
  const _FilterPicker({required this.type, required this.values});
  final MealFilterType type;
  final List<String> values;

  @override
  State<_FilterPicker> createState() => _FilterPickerState();
}

class _FilterPickerState extends State<_FilterPicker> {
  String _term = '';

  @override
  Widget build(BuildContext context) {
    final visible = widget.values
        .where(
          (item) =>
              ApiValueMapper.label(
                item,
              ).toLowerCase().contains(_term.toLowerCase()) ||
              item.toLowerCase().contains(_term.toLowerCase()),
        )
        .toList();
    final title = switch (widget.type) {
      MealFilterType.area => 'Escolha uma região',
      MealFilterType.ingredient => 'Escolha um ingrediente',
      MealFilterType.category => 'Escolha uma categoria',
    };
    return DraggableScrollableSheet(
      initialChildSize: .72,
      minChildSize: .45,
      maxChildSize: .92,
      builder: (context, scrollController) => Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.line,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(height: 18),
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 14),
            TextField(
              onChanged: (value) => setState(() => _term = value),
              decoration: const InputDecoration(
                hintText: 'Filtrar opções',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.separated(
                controller: scrollController,
                itemCount: visible.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) => ListTile(
                  title: Text(ApiValueMapper.label(visible[index])),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => Navigator.of(context).pop(visible[index]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

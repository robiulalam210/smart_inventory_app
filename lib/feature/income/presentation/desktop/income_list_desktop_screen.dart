import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/app_alert_dialog.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../desktop/widgets/desk_kit.dart';
import '../../../products/product/presentation/widget/pagination.dart';
import '../../income_expense/data/model/income_head_model.dart';
import '../../income_expense/presentation/income_expense_bloc/income_expense_head_bloc.dart';
import '../IncomeBloc/income_bloc.dart';
import '../shared/income_create_screen/income_create_screen.dart';
import '../shared/widget/income_table_card.dart';

/// Income List — desktop রূপ। আগে mobile screen (AppBar + FAB + bottom-sheet filter)
/// desktop এ বসানো ছিল। এখন: পেজ-হেডার, এক লাইনের filter bar, কার্ডে table।
/// bloc, API, table, pagination — সব আগেরটাই; শুধু বাইরের চেহারা নতুন।
class DesktopIncomeListScreen extends StatefulWidget {
  const DesktopIncomeListScreen({super.key});

  @override
  State<DesktopIncomeListScreen> createState() =>
      _DesktopIncomeListScreenState();
}

class _DesktopIncomeListScreenState extends State<DesktopIncomeListScreen> {
  DateTimeRange? _range;
  IncomeHeadModel? _head;
  late IncomeBloc _bloc;
  int _pageSize = 10;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _range = DateTimeRange(
      start: DateTime(now.year, now.month - 1, now.day),
      end: DateTime(now.year, now.month, now.day),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<IncomeHeadBloc>().add(FetchIncomeHeadList(context: context));
      _fetch();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _bloc = context.read<IncomeBloc>();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  /// সব filter ধরে রেখে আনে — page বদলালে filter হারায় না
  void _fetch({String? text, int page = 1, int? pageSize}) {
    if (!mounted) return;
    if (pageSize != null) _pageSize = pageSize;
    context.read<IncomeBloc>().add(
          FetchIncomeList(
            context: context,
            filterText: (text ?? _bloc.filterTextController.text).trim(),
            startDate: _range?.start,
            endDate: _range?.end,
            pageNumber: page,
            pageSize: _pageSize,
            headId: _head?.id?.toString(),
          ),
        );
  }

  void _onState(IncomeState state) {
    if (state is IncomeAddLoading) {
      appLoader(context, 'Creating Income, please wait...');
    } else if (state is IncomeAddSuccess) {
      Navigator.pop(context);
      _fetch();
    } else if (state is IncomeAddFailed) {
      if (context.mounted) {
        Navigator.pop(context);
        Navigator.pop(context);
        _alert(state.title, state.content);
      }
    } else if (state is IncomeDeleteLoading) {
      appLoader(context, 'Deleting Income, please wait...');
    } else if (state is IncomeDeleteSuccess) {
      Navigator.pop(context);
      _fetch();
    } else if (state is IncomeDeleteFailed) {
      if (context.mounted) {
        Navigator.pop(context);
        _alert(state.title, state.content);
      }
    }
  }

  void _alert(String title, String content) {
    appAlertDialog(
      context,
      content,
      title: title,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Dismiss'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return DeskPage(
      child: BlocConsumer<IncomeBloc, IncomeState>(
        listener: (context, state) => _onState(state),
        builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DeskPageHeader(
                title: 'Income List',
                subtitle: state is IncomeListSuccess
                    ? '${state.count} ${state.count == 1 ? 'record' : 'records'}'
                    : 'Money received other than sales',
                actions: [
                  DeskButton(
                    label: 'Refresh',
                    icon: Icons.refresh_rounded,
                    outlined: true,
                    onPressed: () => _fetch(),
                  ),
                  DeskButton(
                    label: 'New income',
                    icon: Icons.add_rounded,
                    onPressed: _openCreate,
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _toolbar(),
              const SizedBox(height: 16),
              _body(state),
            ],
          );
        },
      ),
    );
  }

  Widget _toolbar() {
    return DeskCard(
      padding: const EdgeInsets.all(12),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          DeskSearchField(
            controller: _bloc.filterTextController,
            hint: 'Search incomes…',
            onChanged: (v) {
              // প্রতি অক্ষরে API না ডেকে একটু থেমে ডাকা
              _debounce?.cancel();
              _debounce =
                  Timer(const Duration(milliseconds: 400), () => _fetch(text: v));
            },
            onClear: () => _fetch(text: ''),
          ),
          BlocBuilder<IncomeHeadBloc, IncomeHeadState>(
            builder: (context, _) => DeskFilterDropdown<IncomeHeadModel>(
              label: 'heads',
              value: _head,
              items: context.read<IncomeHeadBloc>().list,
              itemLabel: (h) => h.name ?? 'Head',
              onChanged: (h) {
                setState(() => _head = h);
                _fetch();
              },
            ),
          ),
          DeskDateRangeButton(
            value: _range,
            onChanged: (r) {
              setState(() => _range = r);
              _fetch();
            },
          ),
        ],
      ),
    );
  }

  Widget _body(IncomeState state) {
    if (state is IncomeListLoading) return DeskState.loading();
    if (state is IncomeListFailed) {
      return DeskState(
        icon: Icons.error_outline_rounded,
        color: Theme.of(context).colorScheme.error,
        title: 'Failed to load incomes',
        message: state.content,
        action: DeskButton(label: 'Retry', onPressed: () => _fetch()),
      );
    }
    if (state is IncomeListSuccess) {
      if (state.list.isEmpty) {
        return DeskState(
          icon: Icons.inbox_outlined,
          title: 'No incomes found',
          message: 'Try a wider date range, or add a new income.',
          action: DeskButton(
              label: 'New income', icon: Icons.add_rounded, onPressed: _openCreate),
        );
      }
      return Column(children: [
        IncomeTableCard(incomes: state.list, onIncomeTap: () {}),
        const SizedBox(height: 16),
        PaginationBar(
          count: state.count,
          totalPages: state.totalPages,
          currentPage: state.currentPage,
          pageSize: state.pageSize,
          from: state.from,
          to: state.to,
          onPageChanged: (p) => _fetch(page: p),
          onPageSizeChanged: (s) => _fetch(pageSize: s),
        ),
      ]);
    }
    return DeskState.loading();
  }

  void _openCreate() => showDeskDialog(context, const MobileIncomeCreate());
}

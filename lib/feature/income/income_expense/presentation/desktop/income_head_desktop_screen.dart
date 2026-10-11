import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/widgets/app_alert_dialog.dart';
import '../../../../../core/widgets/app_loader.dart';
import '../../../../../desktop/widgets/desk_kit.dart';
import '../income_expense_bloc/income_expense_head_bloc.dart';
import '../shared/income_expense_head_create.dart';
import '../shared/widget/income_head_widget.dart';

/// Income Head — desktop রূপ (পেজ-হেডার + সার্চ কার্ড + table)।
/// bloc ও table আগেরটাই; mobile AppBar / FAB সরানো হয়েছে।
class DesktopIncomeHeadScreen extends StatefulWidget {
  const DesktopIncomeHeadScreen({super.key});

  @override
  State<DesktopIncomeHeadScreen> createState() =>
      _DesktopIncomeHeadScreenState();
}

class _DesktopIncomeHeadScreenState extends State<DesktopIncomeHeadScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetch());
  }

  void _fetch({String filterText = '', int pageNumber = 0}) {
    if (!mounted) return;
    context.read<IncomeHeadBloc>().add(FetchIncomeHeadList(
          context: context,
          filterText: filterText,
          pageNumber: pageNumber,
        ));
  }

  void _onState(IncomeHeadState state) {
    if (state is IncomeHeadAddLoading) {
      appLoader(context, 'Creating Income Head, please wait...');
    } else if (state is IncomeHeadAddSuccess) {
      Navigator.pop(context);
      Navigator.pop(context);
      _fetch();
    } else if (state is IncomeHeadAddFailed) {
      if (context.mounted) {
        Navigator.pop(context);
        appAlertDialog(
          context,
          state.content,
          title: state.title,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Dismiss'),
            ),
          ],
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<IncomeHeadBloc>();
    return DeskPage(
      child: BlocConsumer<IncomeHeadBloc, IncomeHeadState>(
        listener: (context, state) => _onState(state),
        builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DeskPageHeader(
                title: 'Income Head',
                subtitle: state is IncomeHeadListSuccess
                    ? '${state.list.length} ${state.list.length == 1 ? 'head' : 'heads'}'
                    : 'Categories for the money you receive',
                actions: [
                  DeskButton(
                    label: 'New head',
                    icon: Icons.add_rounded,
                    onPressed: () =>
                        showDeskDialog(context, const IncomeHeadCreate()),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              DeskCard(
                padding: const EdgeInsets.all(12),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: DeskSearchField(
                    controller: bloc.filterTextController,
                    hint: 'Search income heads…',
                    onChanged: (v) => _fetch(filterText: v),
                    onClear: () => _fetch(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _body(state),
            ],
          );
        },
      ),
    );
  }

  Widget _body(IncomeHeadState state) {
    if (state is IncomeHeadListLoading) return DeskState.loading();
    if (state is IncomeHeadListFailed) {
      return DeskState(
        icon: Icons.error_outline_rounded,
        color: Theme.of(context).colorScheme.error,
        title: 'Failed to load income heads',
        message: state.content,
        action: DeskButton(label: 'Retry', onPressed: () => _fetch()),
      );
    }
    if (state is IncomeHeadListSuccess) {
      if (state.list.isEmpty) {
        return DeskState(
          icon: Icons.inbox_outlined,
          title: 'No income heads yet',
          message: 'Add one, then use it when you record an income.',
          action: DeskButton(
            label: 'New head',
            icon: Icons.add_rounded,
            onPressed: () => showDeskDialog(context, const IncomeHeadCreate()),
          ),
        );
      }
      return IncomeHeadTableCard(
        incomeHeads: state.list,
        onIncomeHeadTap: () {},
      );
    }
    return DeskState.loading();
  }
}

import 'core/core.dart';
import 'feature/feature.dart';
import 'feature/splash/presentation/bloc/connectivity_bloc/connectivity_state.dart';

class AppWrapper extends StatelessWidget {
  final Widget child;

  const AppWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocListener<ConnectivityBloc, ConnectivityState>(
      listenWhen: (previous, current) =>
          previous.runtimeType != current.runtimeType &&
          current is ConnectivityOnline,
      listener: (context, state) {
        // ✅ Internet connected

        showCustomToast(
          context: context,
          title: 'Success!',
          description: "Internet connected. Syncing data...",
          type: ToastificationType.success,
          icon: Icons.check_circle,
          primaryColor: Colors.green,
        );

        context
            .read<InvoiceUnSyncBloc>()
            .add(LoadUnSyncInvoice(isSingleSync: true));
      },
      child: child,
    );
  }
}

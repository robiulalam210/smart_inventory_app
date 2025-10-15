import '../../../configs/configs.dart';
import 'create_source/create_unit_setup.dart';
import 'widget/widget.dart';

class SourceScreen extends StatefulWidget {
  const SourceScreen({super.key});

  @override
  State<SourceScreen> createState() => _SourceScreenState();
}

class _SourceScreenState extends State<SourceScreen> {
   late var sourceBloc=context.read<SourceBloc>();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize sourceBloc here

    // Now, you can safely access the SourceBloc and initialize the filterTextController
    sourceBloc.filterTextController = TextEditingController();
    _fetchApiData();
  }

  @override
  void dispose() {
    // Dispose of the filterTextController when the widget is disposed
    sourceBloc.filterTextController.dispose();
    super.dispose();
  }


  void _fetchApiData({String filterText = '',  int pageNumber = 0}) {
    context.read< SourceBloc>().add(
      FetchSourceList(context,
        filterText: filterText,

        pageNumber: pageNumber,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar:appBar(title: "Source List", context: context),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          sourceBloc.nameController.clear();
          setupSource(context, "Source Create", "Create",id: "");
        },
        backgroundColor: AppColors.whiteColor,
        child: const Icon(
          Icons.add,
          color: AppColors.primaryColor,
        ),
      ),
      body: Container(
        padding:AppTextStyle.getResponsivePaddingBody(context),
        child: BlocListener<SourceBloc, SourceState>(
          listener: (context, state) {
            if (state is SourceAddLoading) {
              appLoader(context, "Creating Source, please wait...");
            }  if (state is SourceUpdateLoading) {
              appLoader(context, "Update Source, please wait...");
            }else if (state is SourceDeleteLoading) {
              appLoader(context, "Deleted Source, please wait...");
            } else if (state is SourceAddSuccess) {
              Navigator.pop(context); // Close loader dialog
              Navigator.pop(context); // Close loader dialog
              _fetchApiData(); // Reload warehouse list
            }else if (state is SourceUpdateSuccess) {
              Navigator.pop(context); // Close loader dialog
              Navigator.pop(context); // Close loader dialog
              _fetchApiData(); // Reload warehouse list
            } else if (state is SourceDeleteSuccess) {
              Navigator.pop(context); // Close loader dialog
              _fetchApiData(); // Reload warehouse list
            } else if (state is SourceAddFailed) {
              Navigator.pop(context); // Close loader dialog
              Navigator.pop(context); // Close loader dialog
              _fetchApiData();
              appAlertDialog(context, state.content,
                  title: state.title,
                  actions: [
                    TextButton(
                        onPressed: () => AppRoutes.pop(context),
                        child: const Text("Dismiss"))
                  ]);
            } else if (state is SourceUpdateFailed) {
              Navigator.pop(context); // Close loader dialog
              Navigator.pop(context); // Close loader dialog
              _fetchApiData();
              appAlertDialog(context, state.content,
                  title: state.title,
                  actions: [
                    TextButton(
                        onPressed: () => AppRoutes.pop(context),
                        child: const Text("Dismiss"))
                  ]);
            }
          },
          child: Column(
            children: [

              CustomSearchTextFormField(
                controller: context.read<SourceBloc>().filterTextController, onClear: (){
                context.read<SourceBloc>().filterTextController.clear();
                _fetchApiData();

              },
                onChanged: (value) {
                  _fetchApiData(
                    filterText: value,

                  );
                },
                hintText: "Search Name", // Pass dynamic hintText if needed
              ),


              Expanded(
                child: BlocBuilder<SourceBloc,SourceState>(
                  builder: (context, state) {
                    if (state is SourceListLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is SourceListSuccess) {
                      if (state.list.isEmpty) {
                        return Center(
                          child: Lottie.asset(AppImages.noData),
                        );
                      } else {
                        return Column(
                          children: [
                            Expanded(
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: state.list.length,
                                itemBuilder: (_, index) {
                                  final warehouse = state.list[index];
                                  return SourceCard(
                                      source: warehouse, index: index+1);
                                },
                              ),
                            ),
                            PaginationBar(
                              totalPages: state.totalPages,
                              currentPage: state.currentPage,
                              onPageSelected: (page) {
                                _fetchApiData(
                                  filterText:context.read<UnitBloc>(). filterTextController.text,

                                  pageNumber: page,
                                );
                              },
                              activeColor: AppColors.primaryColor,
                              inactiveColor: AppColors.grey,
                            ),
                          ],
                        );
                      }

                    } else if (state is SourceListFailed) {
                      return Center(
                          child: Text('Failed to load : ${state.content}'));
                    } else {
                      return Container();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


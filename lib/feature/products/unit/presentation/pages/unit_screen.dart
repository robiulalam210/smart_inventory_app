import '../../../configs/configs.dart';
import 'create_unit/create_unit_setup.dart';
import 'widget/widget.dart';


class UnitScreen extends StatefulWidget {
  const UnitScreen({super.key});

  @override
  State<UnitScreen> createState() => _UnitScreenState();
}

class _UnitScreenState extends State<UnitScreen> {
  late var dataBloc=context.read<UnitBloc>();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize sourceBloc here

    // Now, you can safely access the SourceBloc and initialize the filterTextController
    dataBloc.filterTextController = TextEditingController();
    _fetchApiData();
  }

  @override
  void dispose() {
    // Dispose of the filterTextController when the widget is disposed
    dataBloc.filterTextController.dispose();
    super.dispose();
  }



  void _fetchApiData({String filterText = '', int pageNumber = 0}) {
    context.read< UnitBloc>().add(
      FetchUnitList(context,
        filterText: filterText,

        pageNumber: pageNumber,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar:appBar(title: "Unit List", context: context),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          dataBloc.nameController.clear();
          dataBloc.shortNameController.clear();
          setupUnit(context, "Create Unit", "Create",id: "");
        },
        backgroundColor: AppColors.whiteColor,
        child: const Icon(
          Icons.add,
          color: AppColors.primaryColor,
        ),
      ),
      body: Container(
        padding:AppTextStyle.getResponsivePaddingBody(context),
        child: BlocListener<UnitBloc, UnitState>(
          listener: (context, state) {
            if (state is UnitAddLoading) {
              appLoader(context, "Creating unit, please wait...");
            }if (state is UnitUpdateLoading) {
              appLoader(context, "Update unit, please wait...");
            }else if (state is UnitDeleteLoading) {
              appLoader(context, "Deleted unit, please wait...");
            } else if (state is UnitAddSuccess) {
              Navigator.pop(context); // Close loader dialog
              Navigator.pop(context); // Close loader dialog
              _fetchApiData(); // Reload warehouse list
            } else if (state is UnitUpdateSuccess) {
              Navigator.pop(context); // Close loader dialog
              Navigator.pop(context); // Close loader dialog
              _fetchApiData(); // Reload warehouse list
            } else if (state is UnitDeleteSuccess) {
              Navigator.pop(context); // Close loader dialog
              _fetchApiData(); // Reload warehouse list
            } else if (state is UnitAddFailed) {
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
            }else if (state is UnitUpdateFailed) {
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
                controller: context.read<UnitBloc>().filterTextController,
                onChanged: (value) {
                  _fetchApiData(
                    filterText: value,

                  );
                },
                onClear: (){
                  context.read<UnitBloc>().filterTextController.clear();
                  _fetchApiData();

                },
                hintText: "Search Name", // Pass dynamic hintText if needed
              ),


              Expanded(
                child: BlocBuilder<UnitBloc,UnitState>(
                  builder: (context, state) {
                    if (state is UnitListLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is UnitListSuccess) {
                      if (state.list.isEmpty) {
                        return Center(
                          child: Lottie.asset(AppImages.noData),
                        );
                      } else {
                        return Column(
                          children: [
                            const SizedBox(height: 5),
                            Expanded(
                              child: ListView.builder(
                                itemCount: state.list.length,
                                itemBuilder: (_, index) {
                                  final warehouse = state.list[index];
                                  return UnitCard(
                                      units: warehouse, index: index+1);
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

                    } else if (state is UnitListFailed) {
                      return Center(
                          child: Text('Failed to load unit screen: ${state.content}'));
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


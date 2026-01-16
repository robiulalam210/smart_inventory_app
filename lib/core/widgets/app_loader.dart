
import '../core.dart';



Future<void> appLoader(BuildContext context,String msg) async{
  final alert= AlertDialog(
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Lottie.asset('assets/jsons/loader.json',height: 100,width: 100,),
        Text("$msg\n",style: AppTextStyle.body(context),),
      ],),
  );
  await showDialog(
    barrierDismissible: false,
    context:context,
    builder:(BuildContext context){
      return alert;
    },
  );
}
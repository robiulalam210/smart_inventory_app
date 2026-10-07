// ⚠️ Legacy path — আসল RootScreen এখন lib/desktop/root.dart এ আছে।
// পুরনো `pages/` ফোল্ডারের কিছু ফাইল এখনও 'root.dart' import করে,
// তাই সেগুলো যাতে না ভাঙে সেজন্য এখান থেকে নতুন ফাইলটি re-export করা হলো।
// (আগে এখানে পুরো পুরনো RootScreen ছিল যেটা bloc.myScreens ব্যবহার করত — যা আর নেই।)
export 'desktop/root.dart';

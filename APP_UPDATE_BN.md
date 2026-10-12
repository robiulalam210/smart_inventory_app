# মোবাইল ও ডেস্কটপ অ্যাপ — নতুন ফিচার

ব্যাকএন্ডে (Django zip v3) এই API গুলো আগে থেকেই আছে — **আগে সার্ভার আপডেট করে `python manage.py migrate` চালান**, তারপর অ্যাপ বিল্ড করুন।

## কী যোগ হয়েছে
| ফিচার | কোথায় (মেনু) | ফাইল |
|---|---|---|
| Stock Adjustment | Products → Stock Adjustment | `feature/stock_tools/presentation/stock_adjust_screen.dart` |
| Stocktake (গণনা ও মিলানো) | Products → Stocktake | `stocktake_list_screen.dart`, `stocktake_count_screen.dart` |
| Expiry Alerts + write-off | Products → Expiry Alerts | `expiry_screen.dart` |
| Barcode Labels (A4 PDF, একসাথে অনেক পণ্য) | Products → Barcode Labels | `label_print_screen.dart` |
| ড্যাশবোর্ডে অতিরিক্ত চার্ট (মাসভিত্তিক লাভ, লাভ-ক্ষতির ট্রেন্ড, স্টক মূল্য, account balance ভাগ, মেয়াদ সতর্কতা) | মোবাইল ও ডেস্কটপ ড্যাশবোর্ড | `lab_dashboard/presentation/widgets/dash_more_charts.dart` |
| Purchase এ ব্যাচ নম্বর ও মেয়াদ | Create Purchase এর প্রতিটি পণ্য-সারির নিচে | `stock_tools/presentation/batch_expiry_fields.dart` |

## যেসব পুরনো ফাইল বদলেছে
- `core/configs/app_urls.dart` — নতুন URL
- `desktop/desktop_screens.dart` — index 52–55 (Stock Adjustment, Stocktake, Expiry Alerts, Barcode Labels)
- `desktop/widgets/sidebar.dart`, `desktop/widgets/tab_sidebar.dart` — Products গ্রুপে ৪টা মেনু
- `mobile/widgets/mobile_tab_sidebar.dart` — মেনু + navigation (case 52–55)
- `feature/lab_dashboard/.../desktop/lab_dashboard_screen.dart`, `.../mobile/mobile_dashboard_screen.dart`
- `feature/purchase/.../desktop/create_purchase_screen.dart`, `.../mobile/mobile_create_purchase_screen.dart` — `batch_no`, `expiry_date` পাঠায়

## নতুন package লাগেনি
চার্ট `CustomPaint` এ আঁকা; লেবেল PDF `pdf` + `printing` (আগে থেকেই আছে) দিয়ে।

## জেনে রাখুন
- এই পরিবেশে Flutter SDK ছিল না, তাই `flutter analyze` / বিল্ড চালানো যায়নি। শুধু সিনট্যাক্স পার্সার ও import-পাথ যাচাই হয়েছে। বিল্ডের সময় ছোটখাটো type/warning এলে জানাবেন।
- নতুন পেজগুলো ইন্টারনেট ছাড়া (desktop offline mode) কাজ করবে না — স্টক বদলের কাজ সার্ভারে হওয়া দরকার। অফলাইনে "Could not load" দেখাবে।
- লেবেল PDF এ default ফন্ট, তাই দামে `Tk` লেখা হয়; বাংলা পণ্যের নাম PDF এ ভাঙতে পারে (ফন্ট যোগ করলে ঠিক হবে)।
- Permission: দেখতে `products.view`, বদলাতে `products.edit` (সার্ভার নিজেই আটকায়)।

## ডেস্কটপ: Sales ও POS ওয়েবের ডিজাইনে
- **Sale** (`create_pos_sale.dart`), **Pos Sale** (`create_sales_pos.dart`), **Sale List** (`pos_sale_screen.dart`) — রং, কার্ড, বর্ডার, ইনপুট, সামারি ওয়েবের (`W`) টোকেনে; dark mode এও ঠিক।
- POS এর ডানের পণ্য-তালিকা ওয়েবের মতো: সার্চ বক্স, **category chip** (পণ্য-সংখ্যাসহ), পণ্যের tile (অক্ষরের avatar বা ছবি, নাম, SKU, দাম, "N left"/"Out", কার্টে থাকলে নীল বর্ডার ও সংখ্যা)। ঘরের সংখ্যা চওড়া অনুযায়ী বদলায়।
- বিক্রির হিসাব, validation, বাটনের কাজ — কিছুই বদলানো হয়নি, শুধু চেহারা।

## Money Receipt ও Purchase (ডেস্কটপ) — ওয়েব ডিজাইন
- money_receipt_list / monery_receipt_create / widgets/widget.dart এবং purchase_screen / create_purchase_screen: ব্যাকগ্রাউন্ড, সাইডবার, কার্ড ও ইনপুট ফিল W টোকেনে (ডার্ক মোডসহ) বদলানো হয়েছে। লজিক/BLoC অপরিবর্তিত। কম্পাইল করা হয়নি।

## Expense (ডেস্কটপ)
- expense_list, expense_head, expense_sub_head স্ক্রিন ও তাদের widget.dart: ব্যাকগ্রাউন্ড/সাইডবার/কার্ড W টোকেনে। Reports আগে থেকেই নতুন report kit-এ, তাই বদলানো হয়নি।

## বাকি সব ডেস্কটপ পেজ (Customer, Supplier, Product, Brand/Category/Unit/Group/Source, Account, Transfer, Transaction, Users, Profile, Returns, Bad stock)
- ব্যাকগ্রাউন্ড ও সাইডবার W টোকেনে (ডার্ক মোডসহ)। লজিক অপরিবর্তিত, কম্পাইল করা হয়নি।

## ওয়েব-স্টাইল ফর্ম/বাটন/কার্ড (সব ডেস্কটপ)
- AppButton: gradient বাদ, ওয়েবের মতো solid নীল, radius ১০।
- টেবিল/লিস্ট কার্ড (Brand, Category, Unit, Group, Source, Transaction, Transfer, Returns, Bad stock, Income, Supplier payment): সাদা surface + ১px রেখা + ১০ radius।
- ইনপুট, ড্রপডাউন, সার্চ, ডেটা-টেবিল, ডায়ালগ আগে থেকেই ওয়েব-স্টাইলে ছিল।
- কম্পাইল করা হয়নি।

## মোবাইল + লগইন
- মোবাইল লগইন: canvas ব্যাকগ্রাউন্ড, বর্ডারসহ সাদা কার্ড, solid নীল বাটন। ডেস্কটপ লগইন: গ্রেডিয়েন্ট/গ্লাস বাদ, canvas + সাদা কার্ড।
- AppScaffold-এ ঐচ্ছিক backgroundColor প্যারামিটার যোগ।
- মোবাইলের ২৮টি স্ক্রিন/উইজেটে কার্ড ও ব্যাকগ্রাউন্ড W টোকেনে। কম্পাইল করা হয়নি।

## ফর্ম বিন্যাস (ওয়েবের মতো সেকশন)
- Product Create: Basic information / Pricing & stock / Discount & alerts — তিনটি WPanel সেকশন।
- Create Purchase: Purchase details ও Charges & discount প্যানেল (পণ্যের সারি, সামারি, পেমেন্ট আগের মতোই)।

## ডেস্কটপ POS কার্ট + Day Close
- ডেস্কটপ POS (create_sales_pos.dart): বাঁয়ে পণ্য ক্যাটালগ (flex 4), ডানে কার্ট/ফর্ম (flex 6) — ওয়েব POS এর মতো।
- নতুন Day Close (Reports): `feature/day_close/` — সারাংশ, account ভিত্তিক expected/counted/পার্থক্য, Close day, Reopen (Admin)। ডেস্কটপ index 56, মোবাইল menu তে "Day Close"। ব্যাকএন্ড: `/api/day-close/…` (Django `dayclose` app, migrate লাগবে)। অনলাইন-only।
- কম্পাইল করা হয়নি।

## "কীভাবে কাজ করবেন" গাইড (সব পেজ)
- ওয়েবের `web/guides.py` এর বাংলা গাইড অ্যাপেও: `core/widgets/page_guides.dart` (generated) + `page_guide_widgets.dart`।
- ডেস্কটপ: `desktop/root.dart` এ একটাই জায়গা থেকে প্রতিটা পেজের মাথায় ভাঁজ-করা গাইড-কার্ড (index → key: `kDesktopGuideKeys`)।
- মোবাইল: `mobile_tab_sidebar.dart` এর সব push `GuideHost.mobile` এ মোড়ানো — পেজের কোণে "?" বোতাম, চাপলে নিচ থেকে গাইড (`kMobileGuideKeys`)।
- নতুন পেজের গাইড বদলাতে ওয়েবের guides.py বদলে dart ফাইল আবার জেনারেট করতে হবে। কম্পাইল করা হয়নি।

## গাইড — বাদ পড়া জায়গা
- Short Sale (মোবাইল), Bad Stock Report: আলাদা গাইড। Product Create/Update ফর্মে হেডারে "?" আইকন (`GuideIconButton`, key `product_form`)।
- যেকোনো ডায়ালগে গাইড চাইলে `GuideIconButton(guideKey: '…')` বসান; key `page_guides.dart` এ যোগ করুন।

## Filter chip ঠিক (Online Orders)
- `WChip` (web_ui.dart): Wrap এর ভেতরে chip পুরো প্রস্থ নিত — ঠিক করা হয়েছে। সব পেজের chip ফিল্টার এতে ঠিক হবে।
- ব্যাকএন্ড: `core/urls.py` এ `/api/shop/` (shop.api_urls) যুক্ত — আগে অ্যাপের Online Orders এর API route-ই ছিল না।

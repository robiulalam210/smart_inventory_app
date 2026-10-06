# আপডেট গাইড — Sale / Money Receipt fix + Desktop Offline Sync + Audit

## ১. কী ঠিক করা হয়েছে (টাকার হিসাব)

আগের code এ একই টাকা account এ কয়েকবার যোগ হত। পরীক্ষায় দেখা গেছে:

| পরিস্থিতি | আগে | এখন |
|---|---|---|
| ৩৬ টাকার বিক্রি, পুরো টাকা নেওয়া | Account +১০৮, ভুয়া advance ৩৬ | Account +৩৬ |
| Walk-in ৫০ দিল, বিল ৩৬ | Account +১৫০ | Account +৩৬, change ১৪ |
| Receipt টিক ছাড়া ১০ টাকা | Account +৩০, ledger entry নেই | Account +১০, ledger entry আছে |
| Invoice এ পরে ৬ টাকা receipt | Account +২২ | Account +৬ |
| Receipt delete | কাজ করত না (404) | Sale, advance, account সব আগের অবস্থায় |

**নতুন নিয়ম — টাকা ঢোকার একটাই পথ:** বিক্রি/পেমেন্ট → Money Receipt → Transaction → Account balance।
প্রতিটা টাকার একটা receipt নম্বর ও ledger entry থাকে, তাই কোনো টাকা দুইবার যোগ হতে পারে না।

যেসব file বদলেছে (backend): `sales/models.py`, `sales/serializers.py`, `sales/views.py`, `sales/signals.py`,
`money_receipts/models.py`, `money_receipts/serializers.py`, `money_receipts/views.py`,
`transactions/models.py`, `core/urls.py`, `returns/models.py`, `account_transfer/models.py`, `inventory_api/settings.py`।

App (mobile + desktop): ৫টা POS screen + নতুন `sale_payment_rules.dart`, ২টা money receipt screen,
`post_response.dart` (200 status কে আগে error ধরা হত)।

## ২. Server এ deploy (ক্রম মেনে)

```bash
# ১. আগে database backup নিন
# ২. code আপলোড করুন, তারপর:
pip install django-cors-headers mysqlclient
python manage.py migrate
python manage.py check_money                 # শুধু রিপোর্ট, কিছু বদলায় না
python manage.py check_money --fix-accounts  # রিপোর্ট দেখে নিশ্চিত হলে
touch tmp/restart.txt                        # cPanel app restart
```

`check_money` কী দেখায়: account এর stored balance বনাম ledger (transaction) অনুযায়ী balance,
sale এর due ঠিক আছে কিনা, কোন receipt account এ জমা হয়নি। **Customer advance স্বয়ংক্রিয়ভাবে বদলানো হয় না** —
পুরনো bug এ ভুয়া advance তৈরি হয়েছিল, কোনটা আসল সেটা আপনি customer list দেখে ঠিক করবেন।

## ৩. App এ নতুন আচরণ

- "With Money Receipt" টিক না থাকলে বিক্রি পুরো বাকিতে যায় (paid = 0)।
- টিক থাকলে payment method ও account বাধ্যতামূলক।
- Walk-in customer এর কাছে বাকি রাখা যায় না।
- ১.৫ kg এর মতো দশমিক পরিমাণ এখন ঠিক যায়।
- Money receipt এর টাকা/invoice/account edit করা যায় না — বদলাতে হলে delete করে নতুন receipt।
  (Delete করলে সব হিসাব নিজে থেকে উল্টে যায়।)

## ৪. Desktop Offline (Windows/macOS/Linux)

Mobile আগের মতোই সম্পূর্ণ online। Desktop:

- **প্রথমবার login:** "এই কম্পিউটার প্রস্তুত করা হচ্ছে" screen — progress bar সহ সব data নামে। একবারই।
- **এরপর:** সব কিছু নিজে থেকে — internet এলে, প্রতি ২ মিনিটে, নতুন entry হলে। কোনো popup নেই,
  শুধু উপরের ছোট chip: সবুজ (Synced) / নীল (sync হচ্ছে) / হলুদ (Offline · ৫ অপেক্ষায়) / লাল (সমস্যা)।
- **Chip এ click = Sync Center:** "এখনই Sync করুন" বাটন, অপেক্ষমাণ entry, সমস্যা, স্টক সতর্কতা।
- **Offline এ যা করা যায়:** বিক্রি, money receipt, ক্রয়, supplier payment, খরচ, আয়, নতুন customer।
  Edit/delete ও report শুধু online এ (report offline এ শেষ দেখা অবস্থায় দেখায়)।
- **স্টক:** offline এ server এর শেষ stock থেকে offline বিক্রি বাদ দিয়ে হিসাব। স্টক না থাকলে বিক্রি আটকায়,
  আর হলুদ banner এ "X টি পণ্যের স্টক শেষ" দেখায়।
- **অন্য PC/মোবাইল একই সময়ে শেষ পিস বিক্রি করলে:** server sale টা নেয় না (stock ঋণাত্মক হয় না),
  Sync Center এ "সমস্যা" হিসেবে দেখায় — ক্রয় এন্ট্রি দিয়ে "আবার পাঠান" অথবা "বাতিল"।
- **Invoice নম্বর:** offline এ `SL-D1-00012` (D1 = এই কম্পিউটার)। Server এও এই নম্বরই থাকে।
- **Offline login:** আগে এই কম্পিউটারে online login করা থাকলে internet ছাড়াও login হয়।
- **Logout:** sync না হওয়া entry থাকলে সতর্ক করে; entry গুলো মুছে যায় না।

### Duplicate কেন হবে না
প্রতিটা write এর একটা অনন্য id (`X-Idempotency-Key`)। একই id দ্বিতীয়বার এলে server নতুন কিছু save করে না,
আগের ফলাফল ফেরত দেয়। Mobile এ double-tap এও এটা কাজ করে। একই phone নম্বরের customer offline এ আবার
বানালে নতুন না বানিয়ে আগেরটার সাথে মিলিয়ে দেয়।

## ৫. Audit log
সব গুরুত্বপূর্ণ data র প্রতিটা create/update/delete রেকর্ড হয় — কে, কখন, কোন app (mobile/desktop/
desktop_offline/admin), কোন কম্পিউটার (D1/D2), field-wise আগের → নতুন মান, আর offline কাজের আসল সময়।

- API: `GET /api/sync/audit/?model=sale&object_id=15` (filter: user_id, action, source, device, date_from, date_to, q)
- Admin panel: Offline Sync & Audit → Change logs (কেউ edit/delete করতে পারে না)
- দেখার অনুমতি: Super Admin, Admin, Manager

## ৬. Flutter build
```bash
flutter pub get        # নতুন: sqflite_common_ffi, sqlite3_flutter_libs, path
flutter build windows
```
`.env` আর `key/meherin.jks` এই zip এ রাখা হয়নি (নিরাপত্তার জন্য) — আপনার কাছে থাকা কপি project এ রাখুন।

## ৭. পরীক্ষা (backend)
```bash
python tools/tests/test_money.py   # ১৬টা টাকার হিসাবের পরীক্ষা
python tools/tests/test_sync.py    # offline sync, duplicate, stock conflict, audit
```
এগুলো আসল database এ data যোগ করে — শুধু test/copy database এ চালাবেন।

## ৮. জানা সীমাবদ্ধতা
- Flutter অংশ এই পরিবেশে compile করা যায়নি (Flutter SDK নেই) — `flutter analyze` চালিয়ে কোনো error থাকলে জানাবেন।
- Offline এ account balance / customer due তাৎক্ষণিক বদলায় না, sync এর পরে ঠিক হয়।
- পুরনো (allocation ছাড়া) "overall" receipt delete করা যায় না — কোন invoice এ কত বসেছিল তার রেকর্ড নেই।

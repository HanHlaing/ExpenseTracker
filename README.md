# ExpenseTracker

This is a simple expense tracker app to analyze your income and expense transactions.

## Implementation

1. As soon as the app is launched, you can see the Login screen. You need to create an account if you don't have an account.
2. After login/signup, you can see a Home Screen with Income, Expense, and Total Balance section, and below this section will the transactions carried including income and expense.
3. If you are a new user, it won't have any transactions and it will show a message as **Tap + to add transaction!**
4. Click the button on the bottom right to add a new transaction.
5. Fill in the date, amount spent, and category accordingly. (Notes are optional, and will be displayed instead of category if added)
6. Press save! You can now see your transaction on the home tab with weekly/monthly/year views. In addition, your statistics will be available to see on the "Chart" tab.
7. Profile tag will show your name, email, and Quote for you(for motivation). 
8. https://api.quotable.io/random API was used to get quotes when your device is online. A random quote from the local file will be shown when your device is offline.

## How to build

1. Clone this repo `git clone https://github.com/HanHlaing/ExpenseTracker.git`
2. Open terminal and navigate to project folder `cd ExpenseTracker`
3. Run `pod install`
4. Open `Expense Tracker.xcworkspace` and run the project on selected device or simulator

## Requirements

- iOS 13+
- Xcode 13
- Swift 5

## Built With 🛠

- [Firebase Auth](https://firebase.google.com/docs/auth) - Firebase Authentication aims to make building secure authentication systems easy, while improving the sign-in and onboarding experience for end users. It provides an end-to-end identity solution, supporting email and password accounts.

- [Firebase Database](https://firebase.google.com/docs/database) - The Firebase Realtime Database is a cloud-hosted NoSQL database that lets you store and sync data between your users in realtime. When your users go offline, the Realtime Database SDKs use local cache on the device to serve and store changes. When the device comes online, the local data is automatically synchronized.

- [Firebase Analytics](https://firebase.google.com/docs/analytics) - The SDK automatically captures certain key events and user properties, and you can define your own custom events to measure the things that uniquely matter to your business. (Optional)

- [Charts](https://github.com/danielgindi/Charts) - To show your statistics.

## UI/UX
Login | Sing up | Forget Password | Home  | Add Transaction 
--- | --- | --- |--- |--- 
![](https://github.com/HanHlaing/ExpenseTracker/blob/main/images/login.png) | ![](https://github.com/HanHlaing/ExpenseTracker/blob/main/images/signup.png) | ![](https://github.com/HanHlaing/ExpenseTracker/blob/main/images/forget_password.png) | ![](https://github.com/HanHlaing/ExpenseTracker/blob/main/images/home.png) | ![](https://github.com/HanHlaing/ExpenseTracker/blob/main/images/add_transaction.png) 

<br />

Update Transaction | Delete Transaction | Expense Chart | Income Chart | Profile
--- | --- | --- |--- |--- 
![](https://github.com/HanHlaing/ExpenseTracker/blob/main/images/update_transaction.png) | ![](https://github.com/HanHlaing/ExpenseTracker/blob/main/images/transaction_delete.png) | ![](https://github.com/HanHlaing/ExpenseTracker/blob/main/images/chart_expense.png) | ![](https://github.com/HanHlaing/ExpenseTracker/blob/main/images/chart_income.png) | ![](https://github.com/HanHlaing/ExpenseTracker/blob/main/images/profile.png) 

<br />

## Nice-to-have features
- Self define new category addition and sorting
- Profile edit with image
- Reminder
- Export CSV


# License
```
MIT License

Copyright (c) 2021 Han Hlaing Moe

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

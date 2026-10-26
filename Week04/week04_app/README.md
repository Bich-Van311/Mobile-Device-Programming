# Week 04 — Navigation & OOP

One Flutter application containing three exercises.

## Project

[Open week04_app](./week04_app/)

## BT1 — UTH Todo

- Splash screen and three onboarding pages.
- Continue, Skip and Start navigation.
- Sample task checklist.
- Object-based data: TodoAppInfo, OnboardingItem and TodoTask.
- Illustrations are built with Flutter widgets.
- System notifications are not implemented.

## BT2 — Library Management

- Sample books and students.
- Forms to add books and students.
- Select a student, borrow books and return books.
- Display book information and borrowing status.
- Prevent borrowing an unavailable book.
- Data is stored in memory and resets when the exercise is reopened.

### Four OOP principles

| Principle | Implementation |
|-----------|----------------|
| Encapsulation | Private fields, getters and repository methods |
| Abstraction | Abstract LibraryItem class |
| Inheritance | Book extends LibraryItem; Textbook extends Book |
| Polymorphism | describe() called through LibraryItem references |

## BT3 — Data Flow Navigation

Email → Verify Code → Create Password → Confirm → Email.

- Pass ResetData through screen constructors.
- Create updated objects with copyWith().
- Return results using Navigator.pop().
- Receive results using await Navigator.push().
- Demo OTP: 123456.
- No real email delivery or account password reset.
- Passwords are masked on screen.

## Run

From the repository root:

```bash
cd Week04/week04_app
flutter pub get
flutter analyze
flutter run
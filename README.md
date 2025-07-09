# 📚 Prolog Library Management System

An intelligent rule-based Library Management System built using **Prolog**, designed to simulate real-world library operations including book borrowing, fine calculation, user management, reservations, popularity tracking, feedback handling, inventory synchronization, and administrative features.

---

## 🧠 Core Features

### 📦 Book & Inventory Management

* 📖 Add, delete, or manage books with details like title, author, genre, price, year, and edition.
* 📊 Real-time inventory tracking of available and borrowed copies.
* 🔄 Sync internal inventory with external sources via `external_inventory/2`.

### 👩‍💼 User & Membership Management

* Supports multiple user roles: `student`, `faculty`, `guest`, and `librarian`.
* Role-based borrowing limits via `borrowing_limit/2`.
* Tracks user borrowing count, outstanding fines, and borrowing history.

### 🔁 Borrowing, Returning & Reservation

* 🏷️ Check availability and borrow books if within limit and under fine threshold.
* 🔁 Return books and automatically trigger reservation fulfillment.
* 📌 Reserve unavailable books using `reservation/2`.
* ⏳ Smart reservation queue processing and due date-based book returns.

### 💰 Fine Calculation & Overdue Notifications

* ⚖️ Automatically compute fines using overdue days.
* 🧾 Maintains a `user_fine/2` fact for outstanding user fines.
* ⏰ Notifies users about overdue books with the fine amount.

### ⭐ Book Ratings & User Feedback

* 📝 Users can rate and review borrowed books.
* 📊 Tracks average rating per book.
* 🏆 Generate top-rated book lists using `top_rated_books/1`.

### 📈 Popularity & Usage Analytics

* 🔥 Tracks borrowing frequency using `book_popularity/2` and `book_borrow_count/2`.
* 👥 Maintains per-user borrow count with `user_borrow_count/2`.
* 📉 Query most borrowed books and frequent users.

### 📢 Notifications & Alerts

* ⛔ Warn users when borrowing limits are reached.
* 📩 Request book reviews after borrow.
* ⚠️ Alert users about overdue books and generated fines.

### 🧑‍🏫 Librarian Tools

* 🛠 Add or remove books.
* 📋 View and modify system-wide inventory and book records.

---

## 🧾 Sample Prolog Queries

```prolog
% Borrow a book
borrow_book(101, '1984', 15, 20).

% Return a book
return_book(101, '1984').

% Reserve a book
reserve_book(103, 'Harry Potter and the Philosopher\'s Stone').

% Calculate fine for overdue books
calculate_fine(101, '1984', Fine).

% Recommend books to a user
recommend_books(103, SuggestedBook).

% View top rated books
top_rated_books(TopBooks).

% Sync external inventory
update_external_inventory('1984', 2),
sync_inventory_with_external_system('1984').
```

---

## ⚙️ Technologies Used

* 🧠 **Prolog** – Logic programming language
* 📝 SWI-Prolog (recommended environment)
* 📦 Modular design using `:- dynamic` predicates

---

## 📂 How to Run

1. Install [SWI-Prolog](https://www.swi-prolog.org/Download.html)
2. Load the file:

   ```prolog
   ?- consult('library.pl').
   ```
3. Run queries based on use cases.

---

## 💡 Future Enhancements

* 📱 Web UI integration using Prolog backend via APIs
* 📚 ISBN-based book tracking
* 🧠 Machine learning recommendations
* 🔐 User authentication system

---

## 📄 License

This project is licensed under the [MIT License](LICENSE).

---

> 🔍 Perfect for academic simulations, AI rule-based projects, and exploring logic-based decision systems.

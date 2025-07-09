:- dynamic borrow/4, reservation/2, book_popularity/2, user_fine/2, borrowing_history/2, book_request/2, reservation_date/3, book_condition/2, loan_extension/2, reservation_queue/2, book_review/3, book_borrow_count/2, user_borrow_count/2, external_inventory/2.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Book Facts and Inventory
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
book('The Great Gatsby', 'F. Scott Fitzgerald', 'Novel', 15, 1925, 3).
book('1984', 'George Orwell', 'Dystopian', 20, 1949, 2).
book('To Kill a Mockingbird', 'Harper Lee', 'Classic', 18, 1960, 4).
book('The Catcher in the Rye', 'J.D. Salinger', 'Fiction', 12, 1951, 3).
book('Harry Potter and the Philosopher\'s Stone', 'J.K. Rowling', 'Fantasy', 25, 1997, 1).
book('The Lord of the Rings', 'J.R.R. Tolkien', 'Fantasy', 30, 1954, 2).

inventory('The Great Gatsby', 5).
inventory('1984', 4).
inventory('To Kill a Mockingbird', 6).
inventory('The Catcher in the Rye', 3).
inventory('Harry Potter and the Philosopher\'s Stone', 7).
inventory('The Lord of the Rings', 2).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% User and Membership Management
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
user(101, 'Alice Smith', student, 'alice@example.com').
user(102, 'Bob Johnson', faculty, 'bob@example.com').
user(103, 'Charlie Brown', student, 'charlie@example.com').
user(104, 'Diana Ross', guest, 'diana@example.com').
user(200, 'Librarian', librarian, 'librarian@example.com').

borrowing_limit(student, 2).
borrowing_limit(faculty, 4).
borrowing_limit(guest, 1).

borrowed_count(UserID, Count) :-
    findall(1, borrow(UserID, _, _, _), L),
    length(L, Count).

can_borrow(UserID) :-
    user(UserID, _, Membership, _),
    borrowing_limit(Membership, Limit),
    borrowed_count(UserID, Count),
    (user_fine(UserID, Fine) -> Fine = Fine ; Fine = 0),  % Default fine to 0 if not found
    Fine =< 50,
    Count < Limit.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Borrowing, Returning, and Reservation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
available_count(Book, AvailableCount) :-
    inventory(Book, TotalCopies),
    findall(1, borrow(_, Book, _, _), BorrowedList),
    length(BorrowedList, BorrowedCount),
    AvailableCount is TotalCopies - BorrowedCount.

borrow_book(UserID, Book, BorrowDate, DueDate) :-
    can_borrow(UserID),
    available_count(Book, Count),
    Count > 0,
    assertz(borrow(UserID, Book, BorrowDate, DueDate)),
    assertz(borrowing_history(UserID, Book)),
    update_book_popularity(Book),
    update_book_borrow_count(Book),
    update_user_borrow_count(UserID).

return_book(UserID, Book) :-
    retract(borrow(UserID, Book, _, _)),
    process_reservations(Book).

reserve_book(UserID, Book) :-
    available_count(Book, Count), Count =< 0,
    \+ reservation(UserID, Book),
    assertz(reservation(UserID, Book)).

process_reservations(Book) :-
    reservation(UserID, Book),
    borrow_book(UserID, Book, 25, 30),
    retract(reservation(UserID, Book)).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fine Calculation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
current_date(25).

calculate_fine(UserID, Book, Fine) :-
    borrow(UserID, Book, _, DueDate),
    current_date(CurrentDate),
    CurrentDate > DueDate,
    DaysOverdue is CurrentDate - DueDate,
    Rate = 1,
    Fine is DaysOverdue * Rate,
    update_fine(UserID, Fine).

update_fine(UserID, Fine) :-
    (user_fine(UserID, CurrentFine) ->
        NewFine is CurrentFine + Fine,
        retract(user_fine(UserID, CurrentFine)),
        assertz(user_fine(UserID, NewFine)) ;
        assertz(user_fine(UserID, Fine))
    ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Book Popularity and Recommendations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
update_book_popularity(Book) :-
    (book_popularity(Book, Count) ->
        NewCount is Count + 1,
        retract(book_popularity(Book, Count)),
        assertz(book_popularity(Book, NewCount)) ;
        assertz(book_popularity(Book, 1))
    ).

top_books(TopBooks) :-
    findall(Count-Book, book_popularity(Book, Count), List),
    sort(1, @>=, List, Sorted),
    first_n_elements(3, Sorted, TopBooks).

first_n_elements(0, _, []).
first_n_elements(N, [X|Xs], [X|Ys]) :-
    N > 0,
    N1 is N - 1,
    first_n_elements(N1, Xs, Ys).

recommend_books(UserID, SuggestedBook) :-
    borrowing_history(UserID, BorrowedBook),
    book(BorrowedBook, _, Genre, _, _, _),
    book(SuggestedBook, _, Genre, _, _, _),
    BorrowedBook \= SuggestedBook.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% User Feedback and Ratings
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
:- dynamic book_review/3.  % book_review(Book, Rating, Comment).

add_book_review(UserID, Book, Rating, Comment) :-
    borrow(UserID, Book, _, _),
    Rating >= 1, Rating =< 5,  % Rating between 1 and 5
    assertz(book_review(Book, Rating, Comment)).

average_rating(Book, AvgRating) :-
    findall(Rating, book_review(Book, Rating, _), Ratings),
    length(Ratings, Count),
    sum_list(Ratings, TotalRating),
    AvgRating is TotalRating / Count.

top_rated_books(TopBooks) :-
    findall(AvgRating-Book, (book_review(Book, Rating, _), average_rating(Book, AvgRating)), RatedBooks),
    sort(1, @>=, RatedBooks, Sorted),
    first_n_elements(3, Sorted, TopBooks).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Reporting Features
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
:- dynamic book_borrow_count/2.  % book_borrow_count(Book, Count)
:- dynamic user_borrow_count/2.  % user_borrow_count(UserID, Count)

update_book_borrow_count(Book) :-
    (book_borrow_count(Book, Count) ->
        NewCount is Count + 1,
        retract(book_borrow_count(Book, Count)),
        assertz(book_borrow_count(Book, NewCount)) ;
        assertz(book_borrow_count(Book, 1))
    ).

most_borrowed_books(TopBooks) :-
    findall(Count-Book, book_borrow_count(Book, Count), BorrowedBooks),
    sort(1, @>=, BorrowedBooks, Sorted),
    first_n_elements(5, Sorted, TopBooks).

update_user_borrow_count(UserID) :-
    (user_borrow_count(UserID, Count) ->
        NewCount is Count + 1,
        retract(user_borrow_count(UserID, Count)),
        assertz(user_borrow_count(UserID, NewCount)) ;
        assertz(user_borrow_count(UserID, 1))
    ).

most_frequent_borrowers(TopUsers) :-
    findall(Count-UserID, user_borrow_count(UserID, Count), Borrowers),
    sort(1, @>=, Borrowers, Sorted),
    first_n_elements(5, Sorted, TopUsers).

outstanding_fines(UsersWithFines) :-
    findall(Fine-UserID, (user_fine(UserID, Fine), Fine > 0), UsersWithFines).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% External Inventory Synchronization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
:- dynamic external_inventory/2.  % external_inventory(Book, ExternalCount)

sync_inventory_with_external_system(Book) :-
    external_inventory(Book, ExternalCount),
    inventory(Book, CurrentCount),
    NewCount is CurrentCount + ExternalCount,
    retract(inventory(Book, CurrentCount)),
    assertz(inventory(Book, NewCount)),
    writeln('Inventory for ', Book, ' updated. New inventory: ', NewCount).

update_external_inventory(Book, Count) :-
    assertz(external_inventory(Book, Count)).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Librarian Features
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
add_book(UserID, Title, Writer, Genre, Price, Year, Edition, Copies) :-
    user(UserID, _, librarian, _),
    \+ book(Title, _, _, _, _, _),
    assertz(book(Title, Writer, Genre, Price, Year, Edition)),
    assertz(inventory(Title, Copies)).

remove_book(UserID, Title) :-
    user(UserID, _, librarian, _),
    retractall(book(Title, _, _, _, _, _)),
    retractall(inventory(Title, _)).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% User Notifications and Alerts
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
send_feedback_request(UserID, Book) :-
    borrow(UserID, Book, _, _),
    writeln('Please provide feedback for the book: ', Book).

notify_borrowing_limit(UserID) :-
    user(UserID, _, Membership, _),
    borrowing_limit(Membership, Limit),
    borrowed_count(UserID, Count),
    (Count >= Limit ->
        writeln('You have reached your borrowing limit. Return books to borrow more.') ;
        true
    ).

notify_overdue_books(UserID) :-
    borrow(UserID, Book, _, DueDate),
    current_date(CurrentDate),
    CurrentDate > DueDate,
    calculate_fine(UserID, Book, Fine),
    writeln('Your book ', Book, ' is overdue. Please return it. Fine: ', Fine).

-- DQL (Data Query Language)

CREATE DATABASE IF NOT EXISTS movieplatform;
USE movieplartform;

-- USER QUERIES

-- Total number of users
SELECT COUNT(*) AS TotalUsers
FROM User;

-- Total number of Premium users
SELECT COUNT(*) AS PremiumUsers
FROM User
WHERE IsPremium = TRUE;

-- Top 5 most active users (based on number of reviews)
SELECT U.Username, COUNT(R.ReviewID) AS ReviewCount
FROM User U
         JOIN Review R ON U.UserID = R.UserID
GROUP BY U.UserID
ORDER BY ReviewCount DESC
LIMIT 5;

-- Top 3 users with the highest average ratings
SELECT U.Username, AVG(R.Rating) AS AvgRating
FROM User U
         JOIN Review R ON U.UserID = R.UserID
GROUP BY U.UserID
ORDER BY AvgRating DESC
LIMIT 3;

-- Users who wrote only one review
SELECT U.Username
FROM User U
         JOIN Review R ON U.UserID = R.UserID
GROUP BY U.UserID
HAVING COUNT(R.ReviewID) = 1;

-- Users who gave only high ratings (>=8)
SELECT U.Username
FROM User U
         JOIN Review R ON U.UserID = R.UserID
GROUP BY U.UserID
HAVING MIN(R.Rating) >= 8;

-- Total number of reviews by Premium users
SELECT COUNT(R.ReviewID) AS TotalPremiumReviews
FROM Review R
         JOIN User U ON R.UserID = U.UserID
WHERE U.IsPremium = TRUE;

-- Users who have never written a review
SELECT Username
FROM User
WHERE UserID NOT IN (SELECT DISTINCT UserID FROM Review);

-- Average number of reviews per user
SELECT AVG(ReviewCount) AS AvgReviewsPerUser
FROM (SELECT COUNT(*) AS ReviewCount
      FROM Review
      GROUP BY UserID) AS UserReviewCounts;

-- Number of users who gave a rating lower than 5
SELECT COUNT(DISTINCT UserID) AS LowRatingUsers
FROM Review
WHERE Rating < 5;

-- Average number of different genres reviewed per user
SELECT AVG(GenreCount) AS AvgGenresPerUser
FROM (SELECT COUNT(DISTINCT MG.GenreID) AS GenreCount
      FROM Review R
               JOIN MovieGenre MG ON R.MovieID = MG.MovieID
      GROUP BY R.UserID) AS GenreCounts;

-- Movies reviewed by the most active user, along with their average rating and view count
WITH MostActiveUser AS (SELECT UserID
                        FROM Review
                        GROUP BY UserID
                        ORDER BY COUNT(*) DESC
                        LIMIT 1)
SELECT M.Title, M.ViewCount, AVG(R.Rating) AS AvgRating
FROM Review R
         JOIN Movie M ON R.MovieID = M.MovieID
WHERE R.UserID = (SELECT UserID FROM MostActiveUser)
GROUP BY M.MovieID;

-- MOVIE QUERIES

-- Movie titles and view counts sorted by view count
SELECT Title, ViewCount
FROM Movie
ORDER BY ViewCount;

-- Last 10 uploaded movies
SELECT *
FROM Movie
ORDER BY MovieID DESC
LIMIT 10;

-- Top 5 longest movies
SELECT Title, Duration
FROM Movie
ORDER BY Duration DESC
LIMIT 5;

-- Top 5 shortest movies
SELECT Title, Duration
FROM Movie
ORDER BY Duration ASC
LIMIT 5;

-- Movies with rating higher than 9
SELECT Title, Rating
FROM Movie
WHERE Rating > 9;

-- View counts of high-rated movies
SELECT Title, Rating, ViewCount
FROM Movie
WHERE Rating > 6
ORDER BY Rating DESC;

-- Number of movies per year
SELECT ReleaseYear, COUNT(*) AS MovieCount
FROM Movie
GROUP BY ReleaseYear;

-- Average movie duration per year
SELECT ReleaseYear, AVG(Duration) AS AvgDuration
FROM Movie
GROUP BY ReleaseYear;

-- Total views per year
SELECT ReleaseYear, SUM(ViewCount) AS TotalViews
FROM Movie
GROUP BY ReleaseYear;

-- High-rated but low-viewed movies
SELECT Title, Rating, ViewCount
FROM Movie
WHERE Rating > 6
  AND ViewCount < 700000
ORDER BY Rating DESC;

-- Highest rated movie each year
SELECT ReleaseYear, Title, Rating
FROM (SELECT *,
             RANK() OVER (PARTITION BY ReleaseYear ORDER BY Rating DESC) AS rnk
      FROM Movie) ranked
WHERE rnk = 1;

-- Movies with rating below 7.5
SELECT Title, Rating
FROM Movie
WHERE Rating < 7.5;

-- Most reviewed movie in a single year
SELECT M.ReleaseYear, M.Title, COUNT(R.ReviewID) AS ReviewCount
FROM Movie M
         JOIN Review R ON M.MovieID = R.MovieID
GROUP BY M.MovieID
ORDER BY ReviewCount DESC
LIMIT 1;

-- CAST QUERIES

-- Top 5 actors with the most movies
SELECT CM.Name, COUNT(*) AS FilmCount
FROM MovieCast MC
         JOIN CastMember CM ON MC.CastID = CM.CastID
WHERE CM.Role = 'Actor'
GROUP BY CM.CastID
ORDER BY FilmCount DESC
LIMIT 5;

-- Directors with the most movies
SELECT CM.Name, COUNT(*) AS FilmCount
FROM MovieCast MC
         JOIN CastMember CM ON MC.CastID = CM.CastID
WHERE CM.Role = 'Director'
GROUP BY CM.CastID
ORDER BY FilmCount DESC;

-- Actors with only one movie
SELECT CM.Name
FROM MovieCast MC
         JOIN CastMember CM ON MC.CastID = CM.CastID
WHERE CM.Role = 'Actor'
GROUP BY CM.CastID
HAVING COUNT(*) = 1;

-- Number of movies each actor has acted in
SELECT CM.Name, COUNT(*) AS FilmCount
FROM MovieCast MC
         JOIN CastMember CM ON MC.CastID = CM.CastID
WHERE CM.Role = 'Actor'
GROUP BY CM.CastID;

-- Average rating of movies an actor has appeared in
SELECT CM.Name, AVG(M.Rating) AS AvgRating
FROM MovieCast MC
         JOIN CastMember CM ON MC.CastID = CM.CastID
         JOIN Movie M ON MC.MovieID = M.MovieID
WHERE CM.Role = 'Actor'
GROUP BY CM.CastID;

-- Highest rated movie each actor has acted in
SELECT CM.Name, GROUP_CONCAT(M.Title) AS MovieTitles, MAX(M.Rating) AS MaxRating
FROM MovieCast MC
         JOIN CastMember CM ON MC.CastID = CM.CastID
         JOIN Movie M ON MC.MovieID = M.MovieID
WHERE CM.Role = 'Actor'
GROUP BY CM.CastID;

-- REVIEW QUERIES

-- Top 3 most reviewed movies with view count and rating
SELECT M.Title, COUNT(R.ReviewID) AS ReviewCount, M.ViewCount, M.Rating
FROM Review R
         JOIN Movie M ON R.MovieID = M.MovieID
GROUP BY M.MovieID
ORDER BY ReviewCount DESC
LIMIT 3;

-- Movies with no reviews
SELECT Title
FROM Movie
WHERE MovieID NOT IN (SELECT DISTINCT MovieID FROM Review);

-- Review count and average rating per movie
SELECT M.Title, COUNT(R.ReviewID) AS ReviewCount, AVG(R.Rating) AS AvgRating
FROM Movie M
         LEFT JOIN Review R ON M.MovieID = R.MovieID
GROUP BY M.MovieID;

-- Top 5 movies with highest average ratings
SELECT M.Title, AVG(R.Rating) AS AvgRating
FROM Review R
         JOIN Movie M ON R.MovieID = M.MovieID
GROUP BY M.MovieID
ORDER BY AvgRating DESC
LIMIT 5;

-- Movies and ratings reviewed by each user
SELECT U.Username, M.Title, R.Rating
FROM Review R
         JOIN User U ON R.UserID = U.UserID
         JOIN Movie M ON R.MovieID = M.MovieID;

-- All reviews for a movie
SELECT M.Title, U.Username, R.Rating, R.Comment
FROM Review R
         JOIN Movie M ON R.MovieID = M.MovieID
         JOIN User U ON R.UserID = U.UserID;

-- Bottom 5 movies by average rating
SELECT M.Title, AVG(R.Rating) AS AvgRating
FROM Review R
         JOIN Movie M ON R.MovieID = M.MovieID
GROUP BY M.MovieID
ORDER BY AvgRating ASC
LIMIT 5;

-- Movies with average rating below 5
SELECT M.Title, AVG(R.Rating) AS AvgRating
FROM Review R
         JOIN Movie M ON R.MovieID = M.MovieID
GROUP BY M.MovieID
HAVING AvgRating < 5;

-- WATCHLIST QUERIES

-- Top 5 most added movies to watchlists
SELECT M.Title, COUNT(*) AS WatchlistCount
FROM Watchlist W
         JOIN Movie M ON W.MovieID = M.MovieID
GROUP BY W.MovieID
ORDER BY WatchlistCount DESC
LIMIT 5;

-- Movies never added to watchlists
SELECT Title
FROM Movie
WHERE MovieID NOT IN (SELECT DISTINCT MovieID FROM Watchlist);

-- Movies in a user's watchlist
SELECT  U.Username, M.Title
FROM Watchlist W
         JOIN User U ON W.UserID = U.UserID
         JOIN Movie M ON W.MovieID = M.MovieID
WHERE U.UserID = 1;

-- Users who have a movie in their watchlist
SELECT W.WatchlistID, M.Title, U.Username
FROM Watchlist W
         JOIN User U ON W.UserID = U.UserID
         JOIN Movie M ON W.MovieID = M.MovieID
WHERE M.MovieID = 1;

-- Most added genre to watchlists
SELECT G.GenreName, COUNT(*) AS AddCount
FROM Watchlist W
         JOIN MovieGenre MG ON W.MovieID = MG.MovieID
         JOIN Genre G ON MG.GenreID = G.GenreID
GROUP BY G.GenreID
ORDER BY AddCount DESC
LIMIT 3;

-- Average rating of movies in watchlists
SELECT AVG(M.Rating) AS AvgRating
FROM Watchlist W
         JOIN Movie M ON W.MovieID = M.MovieID;

-- Users who have watched 3 or more movies of the same genre
SELECT U.Username, W.UserID, G.GenreName, COUNT(*) AS GenreCount
FROM Watchlist W
         JOIN MovieGenre MG ON W.MovieID = MG.MovieID
         JOIN Genre G ON MG.GenreID = G.GenreID
         JOIN User U ON W.UserID = U.UserID
GROUP BY W.UserID, G.GenreID, U.Username
HAVING COUNT(*) >= 3;

-- GENRE QUERIES

-- Number of movies per genre
SELECT G.GenreName, COUNT(*) AS MovieCount
FROM MovieGenre MG
         JOIN Genre G ON MG.GenreID = G.GenreID
GROUP BY G.GenreID;

-- Average movie duration per genre
SELECT G.GenreName, AVG(M.Duration) AS AvgDuration
FROM MovieGenre MG
         JOIN Genre G ON MG.GenreID = G.GenreID
         JOIN Movie M ON MG.MovieID = M.MovieID
GROUP BY G.GenreID;

-- Average movie rating per genre
SELECT G.GenreName, AVG(M.Rating) AS AvgRating
FROM MovieGenre MG
         JOIN Genre G ON MG.GenreID = G.GenreID
         JOIN Movie M ON MG.MovieID = M.MovieID
GROUP BY G.GenreID;

-- Most viewed genre
SELECT G.GenreName, SUM(M.ViewCount) AS TotalViews
FROM MovieGenre MG
         JOIN Genre G ON MG.GenreID = G.GenreID
         JOIN Movie M ON MG.MovieID = M.MovieID
GROUP BY G.GenreID
ORDER BY TotalViews DESC
LIMIT 3;

-- Maximum rating per genre
SELECT G.GenreName, MAX(M.Rating) AS MaxRating
FROM MovieGenre MG
         JOIN Genre G ON MG.GenreID = G.GenreID
         JOIN Movie M ON MG.MovieID = M.MovieID
GROUP BY G.GenreID
ORDER BY MaxRating DESC;

-- Average rating per genre
SELECT G.GenreName, AVG(M.Rating) AS AvgRating
FROM MovieGenre MG
         JOIN Genre G ON MG.GenreID = G.GenreID
         JOIN Movie M ON MG.MovieID = M.MovieID
GROUP BY G.GenreID
ORDER BY AvgRating DESC;

-- Total view count per genre
SELECT G.GenreName, SUM(M.ViewCount) AS TotalViews
FROM MovieGenre MG
         JOIN Genre G ON MG.GenreID = G.GenreID
         JOIN Movie M ON MG.MovieID = M.MovieID
GROUP BY G.GenreID;

-- Top rated movies in a specific genre (e.g., 'Drama')
SELECT G.GenreName, M.Title, M.Rating
FROM MovieGenre MG
         JOIN Genre G ON MG.GenreID = G.GenreID
         JOIN Movie M ON MG.MovieID = M.MovieID
WHERE G.GenreName = 'Drama'
ORDER BY M.Rating DESC
LIMIT 3;

-- Genre popularity over the years
SELECT G.GenreName,
       M.ReleaseYear,
       COUNT(*)         AS FilmCount,
       SUM(M.ViewCount) AS TotalViews,
       AVG(M.Rating)    AS AvgRating
FROM MovieGenre MG
         JOIN Genre G ON MG.GenreID = G.GenreID
         JOIN Movie M ON MG.MovieID = M.MovieID
WHERE G.GenreName = 'Action'
GROUP BY G.GenreName, M.ReleaseYear
ORDER BY G.GenreName, M.ReleaseYear;

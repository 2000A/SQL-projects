CREATE TABLE users(
	user_id SERIAL PRIMARY KEY,
	name VARCHAR(50) NOT NULL,
	email VARCHAR(50) UNIQUE NOT NULL,
	phone_number VARCHAR(50) UNIQUE
);

CREATE TABLE posts (
	post_id SERIAL PRIMARY KEY,
	user_id INTEGER NOT NULL,
	caption TEXT,
	image_url VARCHAR(200),
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	FOREIGN KEY (user_id) REFERENCES users(user_id)
);

CREATE TABLE comments (
	comment_id SERIAL PRIMARY KEY,
	post_id INTEGER NOT NULL,
	user_id INTEGER NOT NULL,
	comment_text TEXT NOT NULL,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	FOREIGN KEY (post_id) REFERENCES posts(post_id),
	FOREIGN KEY (user_id) REFERENCES users(user_id)
	
);


CREATE TABLE likes (
	like_id SERIAL PRIMARY KEY,
	post_id INTEGER NOT NULL,
	user_id INTEGER NOT NULL,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	FOREIGN KEY (post_id) REFERENCES posts(post_id),
	FOREIGN KEY (user_id) REFERENCES users(user_id)
);


CREATE TABLE followers (
	follower_id SERIAL PRIMARY KEY,
	user_id INTEGER NOT NULL,
	follower_user_id INTEGER NOT NULL,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	FOREIGN KEY (user_id) REFERENCES posts(post_id),
	FOREIGN KEY (follower_user_id) REFERENCES users(user_id)
);

-- Inserting into Users table
INSERT INTO Users (name, email, phone_number)
VALUES
    ('John Smith', 'johnsmith@gmail.com', '1234567890'),
    ('Jane Doe', 'janedoe@yahoo.com', '0987654321'),
    ('Bob Johnson', 'bjohnson@gmail.com', '1112223333'),
    ('Alice Brown', 'abrown@yahoo.com', NULL),
    ('Mike Davis', 'mdavis@gmail.com', '5556667777');

-- Inserting into Posts table
INSERT INTO Posts (user_id, caption, image_url)
VALUES
    (1, 'Beautiful sunset', '<https://www.example.com/sunset.jpg>'),
    (2, 'My new puppy', '<https://www.example.com/puppy.jpg>'),
    (3, 'Delicious pizza', '<https://www.example.com/pizza.jpg>'),
    (4, 'Throwback to my vacation', '<https://www.example.com/vacation.jpg>'),
    (5, 'Amazing concert', '<https://www.example.com/concert.jpg>');

-- Inserting into Comments table
INSERT INTO Comments (post_id, user_id, comment_text)
VALUES
    (1, 2, 'Wow! Stunning.'),
    (1, 3, 'Beautiful colors.'),
    (2, 1, 'What a cutie!'),
    (2, 4, 'Aww, I want one.'),
    (3, 5, 'Yum!'),
    (4, 1, 'Looks like an awesome trip.'),
    (5, 3, 'Wish I was there!');

-- Inserting into Likes table
INSERT INTO Likes (post_id, user_id)
VALUES
    (1, 2),
    (1, 4),
    (2, 1),
    (2, 3),
    (3, 5),
    (4, 1),
    (4, 2),
    (4, 3),
    (5, 4),
    (5, 5);

-- Inserting into Followers table
INSERT INTO Followers (user_id, follower_user_id)
VALUES
    (1, 2),
    (2, 1),
    (1, 3),
    (3, 1),
    (1, 4),
    (4, 1),
    (1, 5),
    (5, 1);


--Applying queries , analysing task

--Updating the caption of post_id 3

SELECT * FROM posts;

UPDATE posts
SET caption = 'Best Pizza Ever'
WHERE post_id = 3;

--Selecting all the posts where user_id is 1
SELECT * FROM posts WHERE user_id = 1;

--Selecting all the posts and ordering them by created_at in descending order
SELECT * FROM posts
ORDER BY created_at DESC;

--Counting the number of likes for each post and 
--showing only the posts with more than 2 likes.

SELECT p.post_id, count(like_id) number_likes FROM posts as p
JOIN likes as l ON p.post_id = l.post_id
GROUP BY p.post_id
HAVING count(like_id) >= 2;

--Finding the total number of likes for all posts

SELECT sum(number_likes) FROM (
SELECT p.post_id, count(like_id) number_likes FROM posts as p
JOIN likes as l ON p.post_id = l.post_id
GROUP BY p.post_id) AS likes_by_post
;

--Finding all the users who have commented on post_id 1
SELECT name FROM users WHERE user_id IN(
SELECT user_id FROM comments
WHERE post_id = 1);


--Ranking the posts based on the number of likes

WITH cte AS(
SELECT p.post_id,count( l.like_id) as number_likes FROM posts as p
JOIN likes as l ON p.post_id = l.post_id
GROUP BY p.post_id
)

SELECT
post_id,
number_likes,
DENSE_RANK() OVER(ORDER BY number_likes DESC) as rank_by_likes
FROM cte;


--Finding all the posts and their comments
--using a CTE.

WITH cte AS(
SELECT p.post_id, p.caption, c.comment_text FROM posts p
LEFT JOIN comments c ON p.post_id = c.post_id)

SELECT * FROM cte;


--Categorizing the posts based on the number of likes
WITH cte AS (
SELECT p.post_id, count(l.like_id) number_likes FROM posts as p
JOIN likes as l ON p.post_id = l.post_id
GROUP BY p.post_id
)

SELECT 
post_id,
number_likes,
CASE WHEN number_likes <= 2 THEN 'low likes'
WHEN number_likes = 2 THEN 'moderate likes'
WHEN number_likes > 2 THEN 'lots of likes'
ELSE 'no-data'
END like_category
FROM cte



-- JOINS
-- 1. Which users have liked post_id 2?


SELECT users.name
FROM users
JOIN likes ON users.user_id = likes.user_id
WHERE likes.post_id = 2;

-- 2. Which posts have no comments?

SELECT 
posts.post_id 
FROM posts
LEFT JOIN comments ON posts.post_id = comments.post_id
WHERE comments.comment_text IS NULL;


--3. Which posts were created by users who have no followers?

SELECT posts.caption
FROM posts
JOIN users ON posts.user_id = users.user_id
LEFT JOIN followers ON users.user_id = followers.user_id
WHERE followers.follower_id IS NULL;

--AGGREGATION

--How many likes does each post have?
SELECT p.post_id, COUNT(l.like_id) as num_likes FROM posts as p
LEFT JOIN likes as l ON p.post_id = l.post_id
GROUP BY p.post_id

--What is the average number of likes per post?


SELECT AVG(num_likes) AS avg_likes
FROM (
    SELECT COUNT(likes.like_id) AS num_likes
    FROM posts
    LEFT JOIN Likes ON posts.post_id = likes.post_id
    GROUP BY posts.post_id
) AS likes_by_post;


--Which user has the most followers?


SELECT * FROM users;

SELECT * FROM followers;

SELECT users.name, COUNT(followers.follower_id) FROM users
LEFT JOIN followers ON users.user_id = followers.user_id
GROUP BY users.user_id


--Window Function
--Rank the users by the number of posts they have created









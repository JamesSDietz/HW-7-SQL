-- James Dietz
-- SQL Homework
-- Data Analytics Cohort #3

USE sakila;
-- 1a. first and last name displayed
SELECT first_name, last_name FROM actor;
-- 1b. concatenate name columns (they are already in upper case letters but code below anyway)
UPDATE actor SET `first_name` = UPPER( `first_name` ) WHERE actor_id > 0;
UPDATE actor SET `last_name` = UPPER( `last_name` ) WHERE actor_id > 0;
SELECT CONCAT(first_name, " ", last_name) AS 'Actor Name' FROM actor;
-- 2a. Find actor with name starting with Joe.
SELECT actor_id, first_name, last_name FROM actor WHERE first_name LIKE 'Joe%';
-- 2b. All actors whose last name contain the letters GEN
SELECT actor_id, first_name, last_name FROM actor WHERE last_name LIKE '%GEN%';
-- 2c. Find all actors whose last names contain the letters LI, order the rows by last name and first name, in that order
SELECT  first_name, last_name, actor_id
	FROM actor 
	WHERE last_name LIKE '%LI%'
    ORDER BY last_name, first_name;
    
-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT country_id, country
FROM country 
WHERE (country IN ('Afghanistan','Bangladesh', 'China'));

-- 3a. create a column in the table actor named description and use the data type BLOB 
ALTER TABLE actor
	ADD COLUMN description BLOB AFTER actor_id;
    
-- 3b. Delete the description column.
ALTER TABLE actor
	DROP description; 
    
-- 4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name,COUNT(*) as count FROM actor GROUP BY last_name ORDER BY last_name ASC;

-- 4b. List last names of actors and the number of actors who have that last name, shared by at least two actors    
SELECT last_name,COUNT(*) as count FROM actor GROUP BY last_name having COUNT(*) > 1 ORDER BY last_name ASC;  
    
-- 4c. Fix HARPO WILLIAMS entered wrongly as GROUCHO WILLIAMS. First, I check if I have multiple Grouchos. 

SELECT * FROM actor WHERE first_name = 'GROUCHO';

UPDATE actor
	SET first_name = 'HARPO'
	WHERE first_name = 'GROUCHO'
	AND last_name = 'WILLIAMS';
    
SELECT * FROM actor WHERE last_name = 'WILLIAMS';

-- 4d.  In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.

UPDATE actor
	SET first_name = 'GROUCHO'
	WHERE first_name = 'HARPO' AND actor_id > 0;

-- 5a. Query to locate how to recreate the schema of the address table.  
SHOW CREATE TABLE address;
-- 'address', 'CREATE TABLE `address` (\n  `address_id` smallint(5) unsigned NOT NULL AUTO_INCREMENT,\n  `address` varchar(50) NOT NULL,\n  `address2` varchar(50) DEFAULT NULL,\n  `district` varchar(20) NOT NULL,\n  `city_id` smallint(5) unsigned NOT NULL,\n  `postal_code` varchar(10) DEFAULT NULL,\n  `phone` varchar(20) NOT NULL,\n  `location` geometry NOT NULL,\n  `last_update` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,\n  PRIMARY KEY (`address_id`),\n  KEY `idx_fk_city_id` (`city_id`),\n  SPATIAL KEY `idx_location` (`location`),\n  CONSTRAINT `fk_address_city` FOREIGN KEY (`city_id`) REFERENCES `city` (`city_id`) ON UPDATE CASCADE\n) ENGINE=InnoDB AUTO_INCREMENT=606 DEFAULT CHARSET=utf8'

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:

SELECT * FROM address;
SELECT * FROM staff;

    
SELECT staff.first_name, staff.last_name, address.address, address.district, address.postal_code
	FROM staff
	JOIN address ON staff.address_id = address.address_id;

-- 6b. JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.

SELECT * FROM payment;

SELECT staff.first_name, staff.last_name, SUM(payment.amount)
	FROM payment 
    JOIN staff ON payment.staff_id = staff.staff_id
    WHERE payment.payment_date LIKE '2005-08%'
	GROUP BY staff.first_name, staff.last_name;

-- to verify, I run a simpler query to see if amounts roughly correspond (which they seem to)   
SELECT SUM(payment.amount) FROM payment WHERE payment.payment_date LIKE '2005-08%';


-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.

SELECT * FROM film_actor; 

SELECT film.title AS 'Film Title', COUNT(film_actor.actor_id) AS 'Number of Actors'
	FROM film_actor
    JOIN film 
    ON film_actor.film_id = film.film_id
    GROUP BY film.title;
    
-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
-- 	first I look at the two tables
SELECT * FROM film;
SELECT * FROM inventory;
-- Then I do a chunk of the query to see if I can do the query first (and not entangle it with the join)
SELECT film.film_id, film.title FROM film WHERE film.title = 'Hunchback Impossible';

-- then i do the whole query involving the join 
SELECT COUNT(film.film_id), film.title
	FROM film
    JOIN inventory
    ON film.film_id = inventory.film_id
    WHERE film.title = 'Hunchback Impossible'
    GROUP BY film.film_id;
    
-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:

SELECT customer.first_name, customer.last_name, SUM(payment.amount) AS 'Total Amt. Paid'
	FROM customer
    JOIN payment
    ON customer.customer_id = payment.customer_id
    GROUP BY customer.first_name, customer.last_name
    ORDER BY customer.last_name;
    
    
-- 7s. Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.    

SELECT * from language;

-- I could have done a join here with language table but in examining the language table, I see id for english was 1, it became unnecessry to do a join.

SELECT title FROM film WHERE title LIKE 'K%' OR title LIKE 'Q%' AND language_id = 1;
-- but what the heck ill do it as a join and a subquery anyway, and on the join I chose to display the language:
SELECT film.title, language.name
	FROM film 
    JOIN language
    ON film.language_id = language.language_id
    WHERE title LIKE 'K%' OR title LIKE 'Q%';

-- a finally...here is a subquery doing the same thing:
    
SELECT title
	FROM film
    WHERE language_id IN 
	(SELECT language_id
		FROM language
        WHERE name = 'English')
	AND title LIKE 'K%' OR title LIKE 'Q%';
        
    
-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.

SELECT first_name, last_name
	FROM actor
    WHERE actor_id IN
	(SELECT actor_id
		FROM film_actor
        WHERE film_id IN
        (SELECT film_id
			FROM film
            WHERE title = 'Alone Trip'))
	ORDER BY last_name;
            
        
-- 7c. names and email addresses of all Canadian customers. Use joins to retrieve this information.	
		   
SELECT * FROM customer ORDER BY last_name;
SELECT * FROM address;
SELECT * FROM city;
SELECT * FROM country;

SELECT customer.first_name, customer.last_name, customer.email
	FROM customer
    JOIN address
    ON customer.address_id = address.address_id
    JOIN city
    ON address.city_id = city.city_id
    JOIN country
    ON city.country_id = country.country_id
		WHERE country = 'Canada';
        
-- 7d. Identify all movies categorized as family films.

SELECT * FROM film;
SELECT * FROM film_category;
SELECT * FROM category;

-- as a subquery:
SELECT title
	FROM film
    WHERE film_id IN 
    (SELECT film_id
		FROM film_category
		WHERE category_id IN
        (SELECT category_id
			FROM category
            WHERE name = 'Family'));
            
    -- as a join:
SELECT film.title
	FROM film
    JOIN film_category
    ON film.film_id = film_category.film_id
    JOIN category
    ON film_category.category_id = category.category_id
    WHERE name = 'Family';
    
--  7e. Display the most frequently rented movies in descending order.  

SELECT * FROM payment;
SELECT * FROM rental;
-- SELECT * FROM customer;
SELECT * FROM inventory;
SELECT * FROM film;


            
SELECT film.title AS 'Film Title', COUNT(rental_id) AS 'Number of Times Rented'
	FROM rental
	JOIN inventory
	ON rental.inventory_id = inventory.inventory_id
	JOIN film
	ON inventory.film_id = film.film_id
	GROUP BY film.title
	ORDER BY `Number of Times Rented` DESC;          
            
            
-- 7f. Write a query to display how much business, in dollars, each store brought in.  

SELECT * FROM store;
SELECT store_id FROM store;
SELECT * FROM payment;
SELECT payment_id FROM payment;
SELECT * FROM staff;

SELECT store.store_id, SUM(payment.amount) AS 'Total Revenue'
	FROM payment
	JOIN staff
	ON payment.staff_id = staff.staff_id
	JOIN store
	ON staff.store_id = store.store_id
	GROUP BY store.store_id;
    
    
 -- 7g. Write a query to display for each store its store ID, city, and country.  
    
SELECT * FROM store;
SELECT * FROM address;
SELECT * FROM city;
SELECT * FROM country;

SELECT store.store_id, city.city, country.country
	FROM store
	JOIN address
	ON store.address_id = address.address_id
	JOIN city
	ON address.city_id = city.city_id
	JOIN country
	ON city.country_id = country.country_id;
 
 
-- 7h. List the top five genres in gross revenue in descending order. 
--   (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)

SELECT category.name AS 'Top Genres', SUM(payment.amount) AS 'Revenue'
FROM category
JOIN film_category
ON category.category_id = film_category.category_id
JOIN inventory
ON film_category.film_id = inventory.film_id
JOIN rental
ON inventory.inventory_id = rental.inventory_id
JOIN payment
ON rental.rental_id = payment.rental_id
GROUP BY category.name 
ORDER BY Revenue DESC LIMIT 5;

-- 8a.  CREATE view for 7h.

CREATE VIEW top_genres AS SELECT category.name AS 'Top Genres', SUM(payment.amount) AS 'Revenue'
FROM category
JOIN film_category
ON category.category_id = film_category.category_id
JOIN inventory
ON film_category.film_id = inventory.film_id
JOIN rental
ON inventory.inventory_id = rental.inventory_id
JOIN payment
ON rental.rental_id = payment.rental_id
GROUP BY category.name 
ORDER BY Revenue DESC LIMIT 5;

-- 8b. Display the VIEW

SELECT * FROM top_genres;

-- 8c. Delete VIEW
DROP VIEW top_genres;
SELECT * FROM top_genres;









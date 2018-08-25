USE sakila;


## 1a. Display the first and last names of all actors from the table `actor`.

SELECT first_name, last_name FROM actor;

## 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`.

SELECT concat(UCASE(first_name), " ", UCASE(last_name)) as 'Actor Name'
FROM actor;
## 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?

SELECT actor_id, first_name, last_name FROM actor
WHERE first_name = "Joe";

## 2b. Find all actors whose last name contain the letters `GEN`:
SELECT first_name, last_name FROM actor
WHERE last_name LIKE "%gen%";

## 2c. Find all actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, in that order:
SELECT last_name, first_name FROM actor
WHERE last_name LIKE "%li%"
ORDER BY last_name, first_name;

## 2d. Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT country_id, country FROM country
WHERE country IN ('Afghanistan', 'Bangladesh', 'China');

## 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table `actor` named `description` and use the data type `BLOB` (Make sure to research the type `BLOB`, as the difference between it and `VARCHAR` are significant).
ALTER TABLE actor
ADD COLUMN Description BLOB;

## 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the `description` column.
ALTER TABLE actor
DROP Description;

## 4a. List the last names of actors, as well as how many actors have that last name.

SELECT last_name, COUNT(last_name) as 'LNCount'
FROM actor GROUP BY last_name;

## 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT last_name, COUNT(last_name) as 'LNCount'
FROM actor GROUP BY last_name
HAVING COUNT(LNCount) >1;

## 4c. The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`. Write a query to fix the record.
UPDATE actor SET first_name = 'HARPO'
WHERE first_name = 'GROUCHO' AND last_name = 'WILLIAMS';

SELECT last_name, first_name FROM actor
WHERE first_name = 'HARPO';

## 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was the correct name after all! In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`.
UPDATE actor SET first_name = 'GROUCHO'
WHERE first_name = 'HARPO' AND last_name = 'WILLIAMS';

SELECT last_name, first_name FROM actor
WHERE first_name = 'GROUCHO';

## 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?
  ## Hint: <https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html>
  ## Hover over Result Grid output and you can see each column's schema
SHOW CREATE TABLE address;

## 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` and `address`:
SELECT s.first_name, s.last_name, a.address FROM staff as s
JOIN address as a 
ON (s.address_id = a.address_id);

## 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`.
SELECT s.staff_id, s.first_name, s.last_name, sum(p.amount) as "Total Amount" FROM staff as s
JOIN payment as p 
ON (s.staff_id = p.staff_id)
GROUP BY s.staff_id;

## 6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.
SELECT f.title, count(fa.actor_id) as "Total Actors" FROM film as f
INNER JOIN film_actor as fa 
ON (f.film_id = fa.film_id)
GROUP BY f.title;

## 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?
SELECT f.title, count(i.inventory_id) as "Copies of Hunchback Impossible" FROM film as f
JOIN inventory as i 
ON (f.film_id = i.film_id)
WHERE f.title = 'Hunchback Impossible'
GROUP BY f.title;

## 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. List the customers alphabetically by last name:
SELECT c.first_name, c.last_name, sum(p.amount) as "Total Amount Paid" FROM customer as c
JOIN payment as p
ON (c.customer_id = p.customer_id)
GROUP BY c.first_name, c.last_name;

## 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters `K` and `Q` have also soared in popularity. Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English.
## need to view languate table
SELECT language_id, name FROM language;

## looks like language id for English = 1

SELECT title FROM film 
WHERE title 
LIKE 'K%' OR title LIKE 'Q%'
AND title IN 
(SELECT title FROM film 
WHERE language_id = 1);

## 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.

SELECT first_name, last_name FROM actor
WHERE actor_id in
(SELECT actor_id FROM film_actor
WHERE film_id IN
(SELECT film_id FROM film
WHERE title = 'Alone Trip'));

## 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
## what is country_id for Canada
SELECT country_id, country FROM country;
## country_id for Canada is 20

SELECT c.first_name, c.last_name, c.email FROM customer c
JOIN address as a
ON (c.address_id = a.address_id)
JOIN city cty
ON (cty.city_id = a.city_id)
JOIN country as cntry
ON(cntry.country_id = cty.country_id)
WHERE cntry.country_id = '20';

## 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
## what is category_id for Family
SELECT category_id, name FROM category;
## category_id for Family 8

SELECT title FROM film 
WHERE film_id IN
(SELECT film_id FROM film_category
WHERE category_id IN
(SELECT category_id FROM category
WHERE category_id = "8"));

## 7e. Display the most frequently rented movies in descending order.
SELECT f.title, COUNT(r.rental_id) AS 'Rental Count' FROM rental as r
JOIN inventory as i
on (r.inventory_id = i.inventory_id)
JOIN film as f
on (i.film_id = f.film_id)
GROUP BY f.title
ORDER BY COUNT(r.rental_id) DESC;

## 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT s.store_id, SUM(amount) AS 'Total Revenue' FROM payment as p
JOIN staff AS st
ON(p.staff_id = st.staff_id)
JOIN store as s
ON (st.staff_id = s.manager_staff_id)
GROUP by s.store_id;

## 7g. Write a query to display for each store its store ID, city, and country.
SELECT s.store_id, cty.city, cntry.country FROM store s
JOIN address as a 
ON (s.address_id = a.address_id)
JOIN city as cty
ON (cty.city_id = a.city_id)
JOIN country as cntry
ON (cntry.country_id = cty.country_id);

## 7h. List the top five genres in gross revenue in descending order. (####Hint####: you may need to use the following tables: category, film_category, inventory, payment, and rental.)


SELECT c.name AS 'Film Genre', sum(p.amount) AS 'Gross Revenue'
FROM category AS c
JOIN film_category AS fc
ON(c.category_id = fc.category_id)
JOIN inventory as i
ON(fc.film_id = i.film_id)
JOIN rental as r
ON(i.inventory_id = r.inventory_id)
JOIN payment as p
ON(r.rental_id = p.rental_id)
GROUP BY c.name ORDER BY sum(p.amount) DESC
LIMIT 5;

## 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
CREATE VIEW TOP5byGenre AS
SELECT c.name AS 'Film Genre', sum(p.amount) AS 'Gross Revenue'
FROM category AS c
JOIN film_category AS fc
ON(c.category_id = fc.category_id)
JOIN inventory as i
ON(fc.film_id = i.film_id)
JOIN rental as r
ON(i.inventory_id = r.inventory_id)
JOIN payment as p
ON(r.rental_id = p.rental_id)
GROUP BY c.name ORDER BY sum(p.amount) DESC
LIMIT 5;

## 8b. How would you display the view that you created in 8a?
SELECT * FROM TOP5byGenre;

## 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.
DROP VIEW Top5byGenre;
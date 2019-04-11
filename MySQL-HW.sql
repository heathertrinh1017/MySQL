-- 1a. Display the first and last names of all actors from the table actor.
use sakila;
select first_name,last_name from actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
select concat(upper(mid(first_name,1,1)),lower(mid(first_name,2)),' ', upper(mid(last_name,1,1)),lower(mid(last_name,2))) as 'Actor Name' from actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
select * from actor where first_name = 'Joe';

-- 2b. Find all actors whose last name contain the letters GEN:
create view gen_actors as
select first_name as "First Name",last_name as 'Last Name' from actor where last_name rlike 'gen';

-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
create view li_actors as
select last_name as 'Last Name',first_name as 'First Name' from actor where last_name rlike 'li' order by last_name asc;

-- 2d. Using IN, display the country_id and country columns of the following countries: 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China
select country_id as 'Country ID',country as 'Country'from country where country in ('Afghanistan','Bangladesh','China');

-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table actor named description and use the data type BLOB (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant).
alter table actor add column description blob;
select * from actor;

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.
alter table actor
drop column description;
select * from actor;

-- 4a. List the last names of actors, as well as how many actors have that last name. 
create view last_name_count as
select last_name as "Last Name", count(last_name) as 'Count' from actor
group by last_name;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
create view lastname_2plus as
select last_name as 'Actor Last Name',count(last_name) as 'Count' from actor
group by last_name having count(last_name) >=2;

-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.
update actor set first_name = 'HARPO' where first_name = 'GROUCHO' and last_name = 'williams';
select first_name,last_name from actor where last_name = 'williams';

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.
update actor set first_name = 'groucho' where first_name = 'harpo' and last_name = 'williams';

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
show create table address;

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
-- create view staff_info as
select staff.first_name as 'First Name',staff.last_name as 'Last Name', address.address as 'Address'
from staff 
join address
on address.address_id=staff.address_id;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
-- create view total_sales_perstaff as
-- SET sql_mode=(SELECT REPLACE(@@sql_mode, 'ONLY_FULL_GROUP_BY', ''));
select staff.first_name as 'First Name',staff.last_name as 'Last Name',payment.payment_date as 'Date',sum(payment.amount) as "Total Sales $$"
from payment
left join staff
on payment.staff_id=staff.staff_id
where payment.payment_date like '2005-08%'
group by staff.first_name;

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
-- create view actors_perfilm as
select film.title as 'Film Title',count(film_actor.actor_id) as '# of actors'
from film 
inner join film_actor on film_actor.film_id=film.film_id
group by film.title;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
-- create view inventory_copies as
select title as 'Film Title',
(select count(*) from inventory where film.film_id = inventory.film_id) as 'Inventory Count'
from film where title = 'hunchback impossible';

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:
-- create view total_percustomer as
select customer.first_name as 'First Name',customer.last_name as 'Last Name',sum(payment.amount) as 'Total $$$ Paid'
from payment
join customer
on customer.customer_id=payment.customer_id
group by customer.customer_id
order by customer.last_name asc;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters K and Q have also soared in popularity. Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
-- create view KQ_movies as
select title as 'Film Title',
(select name from language where name = 'english') as 'Language'
from film WHERE title like 'q%' or title like 'k%';

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
-- create view alone_trip_actors as
select first_name as 'First Name',last_name as 'Last Name' from actor where actor_id in
(select actor_id from film_actor where film_id in
(select film_id from film where title = 'Alone Trip'));

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
-- create view canada_emails as
select customer.first_name as 'First Name',customer.last_name as 'Last Name',customer.email as 'Email'
from customer
inner join address on address.address_id=customer.address_id
inner join city on address.city_id=city.city_id
inner join country on city.country_id=country.country_id
where country = 'canada';
select * from canada_emails;

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
-- create view family_films as
select title as 'Family Films' from film where film_id in
(select film_id from film_category where category_id in
(select category_id from category where name = 'family'));
select * from family_films;

-- 7e. Display the most frequently rented movies in descending order.
-- create view frequently_rented_movies as
select inventory.film_id as 'Film ID',film.title as 'Film Title', count(film.film_id) as 'Rental Count'
from payment
inner join rental
on payment.rental_id=rental.rental_id
inner join inventory
on inventory.inventory_id=rental.inventory_id
inner join film
on film.film_id=inventory.film_id
group by film.film_id
order by count(film.film_id) desc;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
-- create view totalsales_perstore as
select store.store_id as 'Store',sum(payment.amount) as 'Total Sales $$$'
from store
inner join staff
on store.store_id=staff.store_id
inner join payment
on payment.staff_id=staff.staff_id
group by store.store_id;

-- 7g. Write a query to display for each store its store ID, city, and country.
-- create view store_city_country as
select store.store_id as 'Store', city.city as 'City', country.country as 'Country'
from store
inner join address on address.address_id=store.address_id
inner join city on address.city_id=city.city_id
inner join country on city.country_id=country.country_id;
select * from store_city_country;

-- 7h. List the top five genres in gross revenue in descending order.
-- create view Top5_Grossing_Genres as
select category.name as 'Movie Category', sum(payment.amount) as 'Gross Revenue'
from category
inner join film_category on film_category.category_id=category.category_id
inner join inventory on inventory.film_id=film_category.film_id
inner join rental on rental.inventory_id=inventory.inventory_id
inner join payment on payment.rental_id=rental.rental_id
group by category.name 
order by sum(payment.amount) desc limit 5;

-- 8b. How would you display the view that you created in 8a?
select * from top5_grossing_genres;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
drop view top5_grossing_genres;

drop view nicer_but_slower_film_list;
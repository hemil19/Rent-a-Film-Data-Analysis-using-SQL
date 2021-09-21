use rentafilm;

/*We want to run an Email Campaigns for customers of Store 2 (First, Last name, and Email address of customers from Store 2)*/
select first_name,last_name,email from customer where store_id=2;

/*List of the movies with a rental rate of 0.99$*/
select title from film where rental_rate=0.99;

/*Your objective is to show the rental rate and how many movies are in each rental rate categories*/
select rental_rate,count(*) as 'total' from film 
group by rental_rate;

/*Which rating do we have the most films in?*/
select rating,count(*) as 'total_rating_count' from film 
group by rating 
order by total_rating_count desc;

/*Which rating is most prevalent in each store?*/
select s.store_id,f.rating,count(*) as 'total' from film f 
join inventory i on f.film_id=i.film_id 
join store s on i.store_id=s.store_id 
group by s.store_id,f.rating;

/*We want to mail the customers about the upcoming promotion*/
select c.customer_id,c.first_name,c.last_name,a.address from customer c 
join address a on c.address_id=a.address_id;

/*List of films by Film Name, Category, Language*/
select f.title as film_name,c.name as 'category',l.name as 'language' from film f 
join language l on f.language_id=l.language_id 
join film_category fc on f.film_id=fc.film_id 
join category c on fc.category_id=c.category_id;

/*How many times each movie has been rented out?*/
select i.film_id,f.title,count(i.film_id) from film f 
join inventory i on f.film_id=i.film_id 
join rental r on i.inventory_id=r.inventory_id 
group by i.film_id 
order by 3 desc;

/*What is the Revenue per Movie?*/
SELECT i.film_id, f.title, COUNT(i.film_id) AS "total_number_of_rental_times", f.rental_rate, COUNT(i.film_id)*f.rental_rate AS "revenue_per_movie" FROM rental r
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f ON f.film_id = i.film_id
GROUP BY i.film_id
ORDER BY 5 DESC;

/*Most Spending Customer so that we can send him/her rewards or debate points*/
select c.customer_id,sum(p.amount) as "total_spend_amount" from customer c 
join payment p 
on c.customer_id=p.payment_id 
group by 1 
order by 2 desc;

/*What Store has historically brought the most revenue?*/
select s.store_id, SUM(p.amount) AS "total_spent"
FROM store s
JOIN inventory i ON i.store_id = s.store_id
JOIN rental r ON r.inventory_id = i.inventory_id
JOIN payment p ON p.rental_id = r.rental_id
GROUP BY 1
ORDER BY 2 DESC;

/*How many rentals do we have for each month?*/
select left(r.rental_date,7) as month,count(*) as "total"  
from rental r 
group by 1;

/*Rentals per Month (such Jan => How much, etc)*/
select date_format(rental_date,"%M") as 'month',count(*) as 'total_count' from rental 
group by 1 
order by 2 desc;

/*Which date the first movie was rented out?*/
select min(rental_date) from rental;

/*Which date last movie was rented out ?*/
select max(rental_date) from rental;

/*For each movie, when was the first time and last time it was rented out?*/
SELECT f.title AS "Film_Title", MIN(r.rental_date) AS "First_Rented_Date", MAX(r.rental_date) AS "Last_Rented_Date"
FROM film f
JOIN inventory i ON f.film_id = i.film_id
JOIN rental r ON r.inventory_id = i.inventory_id
GROUP BY 1;

/*What is the Last Rental Date of every customer?*/
select c.customer_id,c.first_name,c.last_name,max(r.rental_date) as last_rantal_date from rental r 
join customer c 
on r.customer_id=c.customer_id 
group by 1;

/*What is our Revenue Per Month?*/
select left(payment_date,7) as 'month',sum(amount) as revenue_per_month from payment 
group by 1;

/*How many distinct Renters do we have per month?*/
select left(rental_date,7) as 'month',count(distinct(rental_id)) as "total_rentals",count(distinct(customer_id)) as "unique_renter" 
from rental 
group by 1;

/*Show the Number of Distinct Film Rented Each Month*/
SELECT i.film_id, f.title, LEFT(r.rental_date,7) AS "month", COUNT(i.film_id) AS "total_number_of_rental_times"
FROM rental r
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f ON f.film_id = i.film_id
GROUP BY i.film_id, LEFT(r.rental_date,7)
ORDER BY 1, 2, 3;

/*Number of Rentals in Comedy, Sports, and Family*/
SELECT c.name, COUNT(c.name) AS "number_of_rentals"
FROM film f
JOIN film_category fc ON fc.film_id = f.film_id
JOIN category c ON c.category_id = fc.category_id
JOIN inventory i ON f.film_id = i.film_id
JOIN rental r ON r.inventory_id = i.inventory_id
WHERE c.name IN ("Comedy", "Sports", "Family")
GROUP BY 1;

/*Users who have been rented at least 3 times*/
SELECT c.customer_id, CONCAT(c.first_name, " ", c.last_name) AS "customer_name", COUNT(c.customer_id) AS "Total Rentals"
FROM customer c
JOIN rental r ON c.customer_id = r.customer_id
GROUP BY 1
HAVING COUNT(c.customer_id) >= 3
ORDER BY 1;

/*How much revenue has one single store made over PG13 and R rated films*/
SELECT s.store_id, f.rating, SUM(p.amount) AS "total_revenue"
FROM store s 
JOIN inventory i ON i.store_id = s.store_id
JOIN rental r ON r.inventory_id = i.inventory_id
JOIN payment p ON p.rental_id = r.rental_id
JOIN film f ON f.film_id = i.film_id
WHERE f.rating IN ("PG-13", "R")
GROUP BY 1,2;

/* Active User  where active = 1*/
DROP TEMPORARY TABLE IF EXISTS tbl_active_users;
CREATE TEMPORARY TABLE tbl_active_users(
SELECT c.*, a.phone
FROM customer c
JOIN address a ON a.address_id = c.address_id
WHERE c.active = 1);

/* Reward Users : who has rented at least 30 times*/
DROP TEMPORARY TABLE IF EXISTS tbl_rewards_user;
CREATE TEMPORARY TABLE tbl_rewards_user(
SELECT r.customer_id, COUNT(r.customer_id) AS total_rents, max(r.rental_date) AS last_rental_date
FROM rental r
GROUP BY 1
HAVING COUNT(r.customer_id) >= 30);

/* Reward Users who are also active */
SELECT au.customer_id, au.first_name, au.last_name, au.email
FROM tbl_rewards_user ru
JOIN tbl_active_users au ON au.customer_id = ru.customer_id;

/* All Rewards Users with Phone */
SELECT ru.customer_id, c.email, au.phone
FROM tbl_rewards_user ru
LEFT JOIN tbl_active_users au ON au.customer_id = ru.customer_id
JOIN customer c ON c.customer_id = ru.customer_id;
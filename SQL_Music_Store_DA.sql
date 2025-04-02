# Music Store Data Analysis

create database Music_Store_DA;

# Q1:Who is seniormost employee based on job title ? 

select * from employee
order by levels desc
limit 1 ;

# Q2 : which countries have the most invoices?

select billing_country , count(invoice_id) as Total_invoices
from  invoice 
group by billing_country
order by Total_invoices desc;

# Q3 : What are the top 3 values of total invioce?

select total from invoice
group by total
order by total desc
limit 3 ;

select total from invoice
order by total desc
limit 3 ;

# Q4 : Which city has the best customer ? We would like to through a promotional Music Festivel in the city we made the most money.
# Write a query that return one city that has the highest sum of invoice totals. Return both the city name and sum of all invoices totals.

select billing_city , Sum(total) as Sum_Of_Invoices
from invoice
group by billing_city
order by Sum_Of_Invoices desc;

# Q5 : Write a query to identify the customer who has spent the most ?

Select c.customer_id , Concat( c.first_name," " ,c.last_name) as full_name, sum(i.total) as Total_Spending
from customer as c
join invoice as i
on c.customer_id=i.customer_id
group by c.customer_id , full_name
order by Total_Spending desc ;

Select  c.customer_id , Concat( c.first_name," " ,c.last_name) as full_name, i.total,sum(i.total) over(partition by c.customer_id) as Total_Spending
from customer as c
join invoice as i
on c.customer_id=i.customer_id;


# Q6 : Write a query to return email , firstname , lastname ,& genere of all rock music listeners.order list based on email

Select distinct c.email , c.first_name , c.last_name 
from customer as c
join invoice as i on c.customer_id=i.customer_id
join invoice_line as i_l on i.invoice_id=i_l.invoice_id
join track as t on i_l.track_id=t.track_id
where genre_id=(select  genre_id from genre where name = "Rock")
order by c.email; 

Select count(distinct c.customer_id) as Total_Rock_Music_Listeners from
 customer as c
left join invoice as i on c.customer_id=i.customer_id
left join invoice_line as i_l on i.invoice_id=i_l.invoice_id
left join track as t on i_l.track_id=t.track_id
where genre_id=(select  genre_id from genre where name = "Rock");

select * from genre;
select distinct genre_id from genre where name="Rock";

## Q7 : Artist who have written the most rock music in our dataset.
## Write a query that return the artist name and total track count of the top 10 rock bands.

Select a.artist_id,a.name,count(t.track_id) as Total_tracks
from track as t
join album2 as al on t.album_id=al.album_id
join artist as a on al.artist_id=a.artist_id
join genre as g on t.genre_id=g.genre_id
where g.name like "Rock"
group by a.artist_id,a.name
order by Total_tracks desc ;

 Select a.artist_id , a.name , t.track_id,t.name , row_number() over(partition by a.artist_id order by a.artist_id ) as Total_tracks
from track as t
join album2 as al on t.album_id=al.album_id
join artist as a on al.artist_id=a.artist_id
join genre as g on t.genre_id=g.genre_id
where g.name like "Rock" ;

 # Q8 : Return all the track names that have a song length longer that the average song lenth.
 # Return the name and millisecond for each track.
 # Order by the song length with the longest song listed first
 
 select avg(milliseconds) from track;
 
 select name , milliseconds from track 
 where milliseconds>(select avg(milliseconds) from track)
 order by milliseconds desc;
 
 # Q9 : Find how much amount spend by each customer on artists?
 # Write a query to return customer name , artist name and total spent.
 
 select  concat(c.first_name , " ",c.last_name) as full_name ,a.name as artist_name,sum(il.unit_price * il.quantity) as Total_Spending
 from customer as c
 join invoice as i on c.customer_id=i.customer_id
 join invoice_line as il on i.invoice_id=il.invoice_id
 join track as t on il.track_id=t.track_id
 join album2 as al on t.album_id=al.album_id
 join artist as a on al.artist_id=a.artist_id
 group by full_name , artist_name
 order by full_name, artist_name;
 
 with cte as (select  concat(c.first_name , " ",c.last_name) as full_name ,a.name as artist_name,sum(il.unit_price * il.quantity) as Total_Spending
 from customer as c
 join invoice as i on c.customer_id=i.customer_id
 join invoice_line as il on i.invoice_id=il.invoice_id
 join track as t on il.track_id=t.track_id
 join album2 as al on t.album_id=al.album_id
 join artist as a on al.artist_id=a.artist_id
 group by full_name , artist_name
 order by full_name, artist_name)
 select full_name , artist_name , Total_Spending , Sum(Total_Spending) over(partition by full_name ) as Customer_Spending
 from cte;
 
 
 # Crosscheck
 
 select q.full_name , q.artist_name , q.Total_Spending , @running_total:=@running_total + q.Total_Spending AS cumulative_sum from
 (select  concat(c.first_name , " ",c.last_name) as full_name ,a.name as artist_name,sum(il.unit_price * il.quantity) as Total_Spending
 from customer as c
 join invoice as i on c.customer_id=i.customer_id
 join invoice_line as il on i.invoice_id=il.invoice_id
 join track as t on il.track_id=t.track_id
 join album2 as al on t.album_id=al.album_id
 join artist as a on al.artist_id=a.artist_id
 where a.artist_id=1
 group by full_name , a.name
 order by full_name , a.name) as q
 JOIN (SELECT @running_total:=0) as r;
 
 select  a.artist_id,a.name,sum(il.unit_price*il.quantity) as Total_Spent
 from artist as a 
 join album2 as al on a.artist_id=al.artist_id
 join track as t on al.album_id=t.album_id
 join invoice_line il on t.track_id=il.track_id
 where a.artist_id=7
 group by  a.artist_id,a.name
 order by a.artist_id;
 
 # Q10. We want to find out the most popular music genre for each country. 
 # The most popular genre is the genre with the highest amount of purchases.
# write a query that return each coutry along with top genre. 
# For the country where the maximum number of purchases is shared return all genres.

# genrewise purchase
with cte as (with cte as (select i.billing_country as country , g.name, sum(i.total) as Sum 
from invoice as i
join invoice_line as il on i.invoice_id=il.invoice_id
join track as t on il.track_id=t.track_id
join genre as g on t.genre_id=g.genre_id
group by i.billing_country , g.name
order by i.billing_country , g.name)
Select * , dense_rank() over(partition by country order by sum desc) as rnk from cte)
select * from cte
where rnk=1 ;

# Q11. Write a query that determines the customer that has spent the most on music for each country. 
# Write a query that returns the country along with the top customer and how much they spent. 
# For countries where the top amount spent is shared , provide all customers who spent this amount

with cte as (with  abc as   (select c.country, concat(c.first_name," ",c.last_name) as full_name ,Sum(i.total) as total_Spending
from customer as c
join invoice as i on c.customer_id=i.customer_id
group by c.country , full_name
order by c.country , full_name)
select * , dense_rank() over (partition by country order by total_spending) as rnk 
from abc) 
select * from cte
where rnk=1;

select c.country, concat(c.first_name," ",c.last_name) as full_name ,Sum(i.total) as total_Spending
from customer as c
join invoice as i on c.customer_id=i.customer_id
group by c.country , full_name
order by c.country , full_name;
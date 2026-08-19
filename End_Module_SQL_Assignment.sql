create database elearning_db;
use elearning_db;
create table learners(
learner_id int primary key,
full_name varchar(100),
country varchar(100)
);
create table courses(
course_id int primary key,
course_name varchar(100),
category varchar(100),
unit_price decimal(10,2)
);
create table purchases(
purchase_id int primary key,
learner_id int,
course_id int,
quantity int,
purchase_date date,
foreign key (learner_id) references learners(learner_id),
foreign key (course_id) references courses(course_id)
);

insert into learners(learner_id,full_name,country)
values
(1,"Abinaya","India"),
(2,"Banupriya","India"),
(3,"Jessica","USA"),
(4,"John","USA"),
(5,"Veronica","UK");
select * from learners;

insert into courses(course_id,course_name,category,unit_price)
values
(101,"SQL for Beginners","Beginner",5000.00),
(102,"Advanced SQL","Advanced",9000.00),
(103,"Power BI Essentials","BI",8000.00),
(104,"Python for Data Analysis","Programming",11000.00),
(105,"Excel Fundamentals", "Beginner",4000.00);
select * from courses;

insert into purchases(purchase_id,learner_id,course_id,quantity,purchase_date)
values
(1, 1, 101, 1, '2026-01-10'),
(2, 1, 103, 1, '2026-01-15'),
(3, 2, 102, 1, '2026-01-20'),
(4, 2, 104, 1, '2026-02-05'),
(5, 3, 103, 2, '2026-02-10'),
(6, 4, 101, 1, '2026-02-15'),
(7, 5, 104, 1, '2026-03-01'),
(8, 5, 102, 1, '2026-03-10');
select * from purchases;

-- JOIN
select 
l.full_name as Learner,
c.course_name as Course,
c.category as Category,
p.quantity as Quantity,
format(p.quantity*c.unit_price,2) as Total_amount,
p.purchase_date as Purchase_on
from purchases p 
inner join learners l 
on l.learner_id=p.learner_id
inner join courses c
on c.course_id=p.course_id
order by Total_amount desc;

-- Q1. Display each learner’s total spending with their country.
select l.full_name as Learner,l.country,format(sum(c.unit_price*p.quantity),2) as Total_Spending
from learners l
inner join purchases p
on l.learner_id=p.learner_id
inner join courses c
on p.course_id=c.course_id
group by l.learner_id,
l.full_name,
l.country
order by sum(c.unit_price*p.quantity) desc;

-- Q2. Find the top 3 most purchased courses by quantity.
select c.course_name as course,sum(p.quantity) as total_quantity  from
purchases p
inner join courses c
on c.course_id=p.course_id
group by c.course_name,c.course_id
order by sum(p.quantity) desc
limit 3;

-- Q3. Show each category’s: Total revenue, Number of unique learners
select c.category, sum(c.unit_Price*p.quantity) as Total_revenue, count(distinct l.learner_id) as unique_learners
from learners l
inner join purchases p
on p.learner_id=l.learner_id
inner join courses c
on c.course_id=p.course_id
group by c.category
order by sum(c.unit_Price*p.quantity) desc;

-- Q4. List learners who purchased from more than one category.
select l.full_name as learner, count(distinct c.category) as category_count
from learners l
inner join purchases p
on p.learner_id=l.learner_id
inner join courses c
on c.course_id=p.course_id
group by l.learner_id,l.full_name
having count(distinct c.category)>1;

-- Q5. Identify courses never purchased.
select c.course_id,c.course_name,c.category
from courses c
left join purchases p
on c.course_id=p.course_id
where p.purchase_id is null;

-- Sub query
-- Q6. Find learners whose total spending is above the average learner spending.
select l.learner_id,l.full_name,sum(c.unit_price*p.quantity) as total_spending
from learners l
inner join purchases p
on p.learner_id=l.learner_id
inner join courses c
on c.course_id=p.course_id
group by l.learner_id,l.full_name
having sum(c.unit_price*p.quantity)>
(
select avg(learner_spending) from
(
select p2.learner_id,
sum(c2.unit_price*p2.quantity) as learner_spending
from purchases p2
join courses c2
on c2.course_id=p2.course_id
group by p2.learner_id) as spending_table);

-- Q7. Display courses whose price is higher than any course in the ‘Beginner’ category.
select c.course_id,c.course_name,c.category,c.unit_price
from courses c
where c.unit_price>any
(
select unit_price from courses
where category="Beginner");

-- Q8 . Find learners who spent more than the average spending in their country.
select l.learner_id,l.full_name,l.country,sum(c.unit_price * p.quantity) as total_spending
from learners l
join purchases p
on l.learner_id=p.learner_id
join courses c
on p.course_id=c.course_id
group by l.learner_id,l.full_name,l.country
having sum(c.unit_price*p.quantity) >
(
select avg(learner_spending)
from(
select l2.learner_id,l2.country,sum(p2.quantity*c2.unit_price) as learner_spending
from learners l2
join purchases p2
on l2.learner_id=p2.learner_id
join courses c2
on p2.course_id=c2.course_id
where l2.country=l.country
group by l2.learner_id,l2.country
) as country_spending
);

-- Q9. Use a CTE to calculate total spending per learner, then:
-- Display learners with spending above 10,000.
with learner_spending as
(
select l.learner_id,l.full_name,sum(c.unit_price*p.quantity) as total_spending
from learners l
join purchases p
on l.learner_id=p.learner_id
join courses c
on p.course_id=c.course_id
group by l.learner_id,l.full_name
)
select learner_id,full_name,total_spending
from learner_spending
where total_spending>10000;

/*Q10. CASE Expression
Classify learners based on spending:
● Above 15,000 → “High Value”,
● 8,000–15,000 → “Medium Value”,
● Below 8,000 → “Low Value”.*/
with learner_spending as
(
select l.learner_id,l.full_name,sum(c.unit_price*p.quantity) as total_spending
from learners l
join purchases p
on l.learner_id=p.learner_id
join courses c
on p.course_id=c.course_id
group by l.learner_id,l.full_name
)
select learner_id,full_name,total_spending,
case
when total_spending>15000 then 'High Value'
when total_spending>=8000 then 'Medium Value'
else 'Low Value'
end as spending_category
from learner_spending;

-- Q11 . NULL Handling......Display all courses and replace NULL purchase counts with 0 using: IFNULL() or COALESCE()
select c.course_id,c.course_name,ifnull(sum(p.quantity),0) as purchase_count
from courses c
left join purchases p
on p.course_id=c.course_id
group by c.course_id,c.course_name;

/* Q12 . View
Create a view: category_performance_view
● Showing:
● Category
● Total revenue
● Number of purchases
● Average revenue per purchase*/
create or replace view  category_performance_view as
select c.category,sum(c.unit_price*p.quantity) as Total_revenue,count(p.purchase_id) as Number_of_purchases,
round(sum(c.unit_price*p.quantity) / count(p.purchase_id),2) as Average_revenue_per_purchase
from courses c
join purchases p
on p.course_id=c.course_id
group by c.category;

select * from category_performance_view;









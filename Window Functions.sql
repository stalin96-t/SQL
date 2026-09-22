-- Window Functions

-- windows functions allow us to look at a partition or a group, but they each keep their own unique rows in the output
-- windows functions like Row Numbers(), rank(), dense rank(), LEAD(), LAG()
use parks_and_recreation;

SELECT * 
FROM employee_demographics;

select * from employee_salary;
-- first let's look at group by
SELECT gender, ROUND(AVG(salary),2)
FROM employee_demographics dem
JOIN employee_salary sal
	ON dem.employee_id = sal.employee_id
GROUP BY gender
;

SELECT dem.employee_id, dem.first_name, gender, salary,
LAG(salary,1,0) over(order by salary) as Pre_Salary_Lag,
LEAD(salary,1,0) over(order by salary) as Next_Salary_lead,
avg(salary) OVER(Partition by gender) as avg_Gender,
sum(salary) OVER(Partition by gender) as SUM_Gender,
sum(salary) OVER(Partition by gender order by salary) as SUM_roll,
ROW_NUMBER() OVER(Partition by gender order by salary) as Row_Num,
Rank() OVER(Partition by gender order by salary) as Rnk,
DENSE_Rank() OVER(Partition by gender order by salary) as DENSE_Rnk
FROM employee_demographics dem
JOIN employee_salary sal
	ON dem.employee_id = sal.employee_id
;


SELECT 
    dem.employee_id,
    dem.first_name,
    dem.gender,
    sal.salary,

    -- Previous salary
    LAG(sal.salary, 1, 0) OVER(
        ORDER BY sal.salary
    ) AS Pre_Salary_Lag,

    -- Next salary
    LEAD(sal.salary, 1, 0) OVER(
        ORDER BY sal.salary
    ) AS Next_Salary_Lead,

-- "Find the previous salary of each employee based on employee ID."
LAG(sal.salary) OVER(
    ORDER BY dem.employee_id
) as pre_sal_empid,

-- "Find the previous salary within each gender."
LAG(sal.salary) OVER(
    PARTITION BY dem.gender
    ORDER BY sal.salary
)prev_sal_gen,

    -- Average salary by gender
    AVG(sal.salary) OVER(
        PARTITION BY dem.gender
    ) AS avg_Gender,

    -- Total salary by gender
    SUM(sal.salary) OVER(
        PARTITION BY dem.gender
    ) AS SUM_Gender,

    -- Running salary total by gender
    SUM(sal.salary) OVER(
        PARTITION BY dem.gender
        ORDER BY sal.salary
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS SUM_roll,

    -- Unique row number
    ROW_NUMBER() OVER(
        PARTITION BY dem.gender
        ORDER BY sal.salary
    ) AS Row_Num,

    -- Ranking with gaps
    RANK() OVER(
        PARTITION BY dem.gender
        ORDER BY sal.salary
    ) AS Rnk,

    -- Ranking without gaps
    DENSE_RANK() OVER(
        PARTITION BY dem.gender
        ORDER BY sal.salary
    ) AS DENSE_Rnk

FROM employee_demographics dem
JOIN employee_salary sal
    ON dem.employee_id = sal.employee_id;
    
-- ------------------------------------------------
/*
Q10: Highest-paid employee in each gender
Q11: Second-highest salary in each gender
Q13: Employees earning above their gender average
Q15: Salary difference from previous employee
Q25: Top 2 salaries in each gender */

-- Q10: Highest-paid employee in each gender ---> CTE 
with rank_emp as (
select dem.first_name, dem.gender,sal.salary,
rank() over(partition by gender order by salary DESC) as rnk
from employee_demographics dem
JOIN
employee_salary sal
ON dem.employee_id = sal.employee_id)
select * from rank_emp where rnk=1
;

-- sub query
select * from (
select dem.first_name, dem.gender,sal.salary,
rank() over(partition by gender order by salary DESC) as rnk
from employee_demographics dem
JOIN
employee_salary sal
ON dem.employee_id = sal.employee_id) as ranked_emp 
where rnk=1
;


-- Q11: Second-highest salary in each gender 
-- (This same technique works for 2nd, 3rd.... highest)

with rank_emp as (
select dem.first_name, dem.gender,sal.salary,
rank() over(partition by gender order by salary DESC) as rnk
from employee_demographics dem
JOIN
employee_salary sal
ON dem.employee_id = sal.employee_id)
select * from rank_emp where rnk=2
;

-- Q13: Employees earning above their gender average
with emp_sal as(
select dem.first_name, dem.gender,sal.salary, 
avg(salary) over(partition by gender) as avg_sal_gen,
rank() over(partition by gender order by salary DESC) as rnk
from employee_demographics dem
JOIN
employee_salary sal
ON dem.employee_id = sal.employee_id)
select * from emp_sal
where salary > avg_sal_gen
;
-- Q15: Salary difference from previous employee

select dem.first_name, dem.gender,sal.salary, 
avg(salary) over(partition by gender) as avg_sal_gen,
rank() over(partition by gender order by salary DESC) as rnk,
LAG(sal.salary,1,0) over(order by salary DESC) as Pre_sal, 
sal.salary - LAG(sal.salary,1,0) over(order by salary DESC) as diff_pre_sal
from employee_demographics dem
JOIN
employee_salary sal
ON dem.employee_id = sal.employee_id
;

-- Q 25. Find the Top 2 Salaries in Each Gender ⭐⭐⭐
with emp_rnk as(
select dem.first_name, dem.gender,sal.salary, 
dense_rank() over(partition by gender order by salary DESC) as rnk
from employee_demographics dem
JOIN
employee_salary sal
ON dem.employee_id = sal.employee_id)
select * from emp_rnk
where rnk in (1,2)
;

-- =============================================================
-- now let's try doing something similar with a window function

SELECT dem.employee_id, dem.first_name, gender, salary,
AVG(salary) OVER()
FROM employee_demographics dem
JOIN employee_salary sal
	ON dem.employee_id = sal.employee_id
   ;

-- now we can add any columns and it works. We could get this exact same output with a subquery in the select statement, 
-- but window functions have a lot more functionality, let's take a look

-- if we use partition it's kind of like the group by except it doesn't roll up - it just partitions or breaks based on a column when doing the calculation

SELECT dem.employee_id, dem.first_name, gender, salary,
AVG(salary) OVER(PARTITION BY gender)
FROM employee_demographics dem
JOIN employee_salary sal
	ON dem.employee_id = sal.employee_id
;


-- now if we wanted to see what the salaries were for genders we could do that by using sum, but also we could use order by to get a rolling total

SELECT dem.employee_id, dem.first_name, gender, salary,
SUM(salary) OVER(PARTITION BY gender ORDER BY employee_id)
FROM employee_demographics dem
JOIN employee_salary sal
	ON dem.employee_id = sal.employee_id
;


-- Let's look at row_number rank and dense rank now


SELECT dem.employee_id, dem.first_name, gender, salary,
ROW_NUMBER() OVER(PARTITION BY gender)
FROM employee_demographics dem
JOIN employee_salary sal
	ON dem.employee_id = sal.employee_id
;

-- let's  try ordering by salary so we can see the order of highest paid employees by gender
SELECT dem.employee_id, dem.first_name, gender, salary,
ROW_NUMBER() OVER(PARTITION BY gender ORDER BY salary desc)
FROM employee_demographics dem
JOIN employee_salary sal
	ON dem.employee_id = sal.employee_id
;

-- let's compare this to rank
SELECT dem.employee_id, dem.first_name, gender, salary,
ROW_NUMBER() OVER(PARTITION BY gender ORDER BY salary desc) row_num,
Rank() OVER(PARTITION BY gender ORDER BY salary desc) rank_1 
FROM employee_demographics dem
JOIN employee_salary sal
	ON dem.employee_id = sal.employee_id
;

-- notice rank repeats on tom ad jerry at 5, but then skips 6 to go to 7 -- this goes based off positional rank


-- let's compare this to dense rank
SELECT dem.employee_id, dem.first_name, gender, salary,
ROW_NUMBER() OVER(PARTITION BY gender ORDER BY salary desc) row_num,
Rank() OVER(PARTITION BY gender ORDER BY salary desc) rank_1,
dense_rank() OVER(PARTITION BY gender ORDER BY salary desc) dense_rank_2 -- this is numerically ordered instead of positional like rank
FROM employee_demographics dem
JOIN employee_salary sal
	ON dem.employee_id = sal.employee_id
;
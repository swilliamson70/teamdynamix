--select * from dept_xwalk where tdx_dept is null order by 1 ;

update dept_xwalk set tdx_dept = E'Martin Regional' where department = 'SE Region';
--select * from dept_xwalk where department = '' ;

select * from dept_xwalk where tdx_dept is null order by 1 ;

select people.* 
from dept_xwalk 
    join people on dept_xwalk.department = people.department
where dept_xwalk.tdx_dept is null
order by people.department;
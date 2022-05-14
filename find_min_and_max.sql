CREATE or replace FUNCTION find_min_and_max_func(
    state point,
    next  integer
) RETURNS point
LANGUAGE plpgsql
STRICT
AS $$
declare
min_val integer;  
max_val integer;                   
begin    
if state[0] <= next then min_val := state[0];  
elsif next < state[0] then min_val := next;  
end if;
if state[1] >= next then max_val := state[1];  
elsif next > state[1] then max_val := next;  
end if;               
return point(min_val, max_val) ;                     
END;
$$;

CREATE or replace FUNCTION find_min_and_max_final_func(
    state point
) RETURNS varchar
LANGUAGE plpgsql
STRICT
AS $$                 
begin              
return cast(state[0] as varchar) || '->' || cast(state[1] as varchar) ;                     
END;
$$;

--In this example I am using integer. That is why 
--the boundaries of integer data type are selected
--as my initial condition states.CREATE or replace AGGREGATE find_min_and_max(integer)
(
    SFUNC    = find_min_and_max_func, -- State function
    STYPE    = point,       -- State type
	FINALFUNC = find_min_and_max_final_func,
	initcond = '(2147483647,-2147483648)'
);

CREATE or replace FUNCTION find_min_and_max_funcs(
    state point,
    next  varchar
) RETURNS point
LANGUAGE plpgsql
STRICT
AS $$
declare
min_val integer;  
max_val integer;                   
begin    
if cast(state[0] as int) <= cast(next as int) then min_val := cast(state[0] as int);  
elsif cast(next as int) < cast(state[0] as int) then min_val := cast(next as int);  
end if;
if cast(state[1] as int) >= cast(next as int) then max_val := cast(state[1] as int);  
elsif cast(next as int) > cast(state[1] as int) then max_val := cast(next as int);  
end if;               
return point(min_val, max_val) ;                     
END;
$$;

CREATE or replace FUNCTION find_min_and_max_final_funcs(
    state point
) RETURNS varchar
LANGUAGE plpgsql
STRICT
AS $$                 
begin              
return cast(state[0] as varchar) || '->' || cast(state[1] as varchar) ;                     
END;
$$;


CREATE or replace AGGREGATE find_min_and_max(varchar)
(
    SFUNC    = find_min_and_max_funcs, -- State function
    STYPE    = point,       -- State type
	FINALFUNC = find_min_and_max_final_funcs,
	initcond = '(2147483647,-2147483648)'
);

--For integer data type
SELECT find_min_and_max(value) FROM UNNEST(ARRAY [1, 2, 3]) as value;
SELECT find_min_and_max(val) FROM (VALUES(5),(3),(6),(7),(9),(10),(7)) t(val);

--For varchar data type
SELECT find_min_and_max(value) FROM UNNEST(ARRAY ['1', '2', '3']) as value;
SELECT find_min_and_max(val) FROM (VALUES('5'),('3'),('6'),('7'),('9'),('10'),('7')) t(val);

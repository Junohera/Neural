select pid,
       client_addr,
       usename,
       case when waiting then 'W' else '' end as wait,
       case when state_change < now() + '-30sec' then 'L' end as Long,
       state,
       to_char(state_change, 'YYYY-MM-DD HH24:MI:SS') as state_change,
       to_char(now() - query_start, 'HH24:MI:SS:MS') as elapse,
       left(replace(regexp_replace(regexp_replace(query, '\t|\r|\n', ' ', 'g'), '\s\s*', ' ', 'g'), '  ', ' '), 70) as query
  from pg_stat_activity
 where state <> 'idle'
 order by state_change asc;
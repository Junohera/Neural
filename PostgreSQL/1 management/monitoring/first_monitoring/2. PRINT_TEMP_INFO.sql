select pg_stat_activity.pid,
       pg_stat_activity.datname,
       pg_stat_activity.client_addr,
       extract(epoch from (now() - pg_stat_activity.query_start)) as duration,
       -- case when pg_stat_activity.waiting then 'W' else '' end as wait_status, 
       case when pg_stat_activity.wait_event is not null then 'W' else '' end as wait_status, -- when 9.6.24 pg_stat_activity.waiting -> pg_stat_activity.wait_event
       pg_stat_activity.usename as user,
       pg_stat_activity.state,
       pg_size_pretty(pg_temp_files.sum) as temp_file_size,
       pg_temp_files.count as temp_file_num
  from pg_stat_activity as pg_stat_activity
 inner join (select unnest(regexp_matches(agg.tmpfile, 'pgsql_tmp([0-9]*)')) as pid,
                    sum((pg_stat_file(agg.dir||'/'||agg.tmpfile)).size),
                    count(*)
               from (select ls.oid,
                            ls.spcname,
                            ls.dir||'/'||ls.sub as dir,
                            case gs.i when 1 then '' else pg_ls_dir(dir||'/'||ls.sub) end as tmpfile
                       from (select sr.oid,
                                    sr.spcname,
                                    'pg_tblspc/'||sr.oid||'/'||sr.spc_root as dir,
                                    pg_ls_dir('pg_tblspc/'||sr.oid||sr.spc_root) as sub
                               from (select spc.oid,
                                            spc.spcname,
                                            pg_ls_dir('pb_tblspc/'||spc.oid) as spc_root,
                                            trim(trailing E'\n ' from pg_read_file('PG_VERSION')) as v
                                       from (select oid,
                                                    spcname
                                               from pg_tablespace
                                              where spcname !~ '^pg_') as spc) sr
                              where sr.spc_root ~ ('^PG_'||sr.v)
                          union all
                             select 0,
                                    'pg_default',
                                    'base' as dir,
                                    'pgsql_tmp' as sub
                               from pg_ls_dir('base') as l
                              where l = 'pgsql_tmp') as ls,
                             (select generate_series(1, 2) as i) as gs
                               where ls.sub = 'pgsql_tmp') agg
              group by 1) as pg_temp_files on pg_stat_activity.pid = pg_temp_files.pid::int
 where pg_stat_activity.pid <> pg_backend_pid()
 order by extract(epoch from (now() - pg_stat_activity.query_start)) desc;
select (select count(*) from pg_stat_activity where state <> 'idle') as active_session,
       count(*) as connection_session,
       current_setting('max_connections') as max_session,
       (count(*)*100/current_setting('max_connections')::float)||'%' as usage_ratio
  from pg_stat_activity;
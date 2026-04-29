-- Create an RPC to broadcast a system notification to all users
create or replace function public.broadcast_system_notification(p_title text, p_body text)
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.notifications (user_id, type, title, body)
  select id, 'system', p_title, p_body
  from public.user_profiles;
end;
$$;

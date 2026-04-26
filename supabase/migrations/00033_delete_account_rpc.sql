-- Delete current user's account and all associated data.
-- Called via RPC from the client side.
-- SECURITY: Uses auth.uid() to ensure users can only delete their own account.
CREATE OR REPLACE FUNCTION delete_own_account()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  -- Delete user profile (cascades handled by foreign keys)
  DELETE FROM user_profiles WHERE id = auth.uid();
  
  -- Delete the auth user
  DELETE FROM auth.users WHERE id = auth.uid();
END;
$$;

-- Only authenticated users can call this
GRANT EXECUTE ON FUNCTION delete_own_account() TO authenticated;

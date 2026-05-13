-- Add DELETE policy for notifications table to allow users to clear their notifications
CREATE POLICY "Users delete their own notifications"
ON notifications
FOR DELETE
TO authenticated
USING (user_id = auth.uid());

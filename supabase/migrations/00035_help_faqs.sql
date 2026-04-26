create table public.faqs (
  id uuid primary key default gen_random_uuid(),
  category text not null,
  question text not null,
  answer text not null,
  display_order integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.faqs enable row level security;

create policy "FAQs are viewable by everyone." on public.faqs
  for select using (true);

-- Insert initial data
insert into public.faqs (category, question, answer, display_order) values
('Account & Registration', 'Why do I need a .edu email to sign up?', 'To maintain a trusted and secure campus-only community, Smivo requires all users to verify a valid university .edu email address. This ensures that everyone you trade with is a verified student or faculty member at your school.', 1),
('Account & Registration', 'Can I browse listings without logging in?', 'Yes! You can browse the home feed and view item details as a guest. However, to message a seller, make an offer, or save an item, you must log in with a verified account.', 2),
('Account & Registration', 'How do I change my school or email address?', 'Your account is securely tied to the .edu domain you registered with. Currently, changing your email or transferring your account to a different university is not supported. If you transfer schools, you will need to create a new account using your new .edu email.', 3),
('Account & Registration', 'How do I permanently delete my account?', 'You can delete your account by navigating to Settings > Delete Account. Please note that this action is irreversible and will permanently wipe your profile, listings, and chat history from our servers.', 4),
('Buying & Renting', 'How do I buy an item?', 'Once you find an item you like, tap Request to Buy. This sends a pending order to the seller. You can also tap Message to ask questions before submitting a request. When the seller accepts your offer, the order moves to "Awaiting Delivery," and you can coordinate a pickup location in the chat.', 5),
('Buying & Renting', 'How does renting an item work?', 'For rental listings, you can choose a rental rate (Daily, Weekly, or Monthly) and specify your rental period dates. The seller may require a deposit. Once the seller approves your application: 1. Coordinate pickup and confirm delivery in the app. 2. The item status becomes "Active" for the duration of the rental. 3. At the end of the rental period, request a return. 4. Once the seller confirms receiving the item, they will refund your deposit.', 6),
('Buying & Renting', 'What does the "Missed" status mean?', 'When a seller receives multiple offers for the same item and accepts one from another buyer, all other pending offers are automatically marked as "Missed."', 7),
('Buying & Renting', 'Can I extend my rental period?', 'Yes! If you need the item longer, go to your Buyer Center > Active Transactions, open the order details, and request a Rental Extension. You can select the number of additional days/weeks/months. The seller will be notified to approve or reject your extension request.', 8),
('Selling & Listing', 'How do I post an item for sale or rent?', 'Tap the Post icon in the bottom navigation bar. Add clear photos, an accurate title and description, category, and condition. You can choose to list the item for Sale, Rent, or both.', 9),
('Selling & Listing', 'Where do I manage offers from buyers?', 'Go to your Seller Center or tap Manage Transactions on your listing. From the Offers tab, you can view all pending requests. Once you tap Accept on a buyer''s offer, all competing offers will automatically be declined.', 10),
('Selling & Listing', 'Do I have to charge a deposit for rentals?', 'Deposits are optional but highly recommended for high-value items (like electronics or instruments) to protect against damage or failure to return the item.', 11),
('Selling & Listing', 'How do I refund a rental deposit?', 'When a rental period ends and the buyer returns the item, inspect it carefully. If it is in its original condition, tap Refund Deposit on the order detail page to complete the transaction lifecycle.', 12),
('Transaction Safety & Payments', 'Does Smivo process payments directly?', 'No. In this phase, Smivo does not process in-app payments. Buyers and sellers should arrange payment securely in person using Venmo, Zelle, or cash. Never send money before physically inspecting and receiving the item.', 13),
('Transaction Safety & Payments', 'Where is the safest place to meet for an exchange?', 'We strongly recommend coordinating meetups during daylight hours in well-lit, public campus areas. Great locations include the student union building, campus libraries, or designated safe exchange zones provided by campus security.', 14),
('Transaction Safety & Payments', 'What are "Evidence Photos"?', 'Evidence Photos protect both buyers and sellers. When handing over an item (or returning a rental), both parties can upload up to 5 photos of the item''s condition to the order detail page before tapping "Confirm Pickup" or "Confirm Return." This acts as a digital receipt of the item''s condition at the time of exchange.', 15),
('Troubleshooting & Support', 'What should I do if a buyer/seller stops responding?', 'If a transaction is pending and the other party is unresponsive, you can cancel the request from the Order Details page. We recommend communicating clearly via the in-app chat before taking action.', 16),
('Troubleshooting & Support', 'The item I rented got damaged. What happens next?', 'If a rental item is damaged, the seller has the right to withhold part or all of the rental deposit. We recommend discussing the situation in the chat. Using the Evidence Photos feature during pickup and return helps resolve these disputes fairly.', 17),
('Troubleshooting & Support', 'How do I turn off push notifications?', 'Go to Settings > Notifications to toggle system alerts, order updates, and chat notifications on or off. You will still see red dot badges within the app even if push notifications are disabled.', 18);

-- Secure Database Policies
-- Run this in Supabase SQL Editor to lock down your app

-- 1. Enable RLS on all tables (if not already)
ALTER TABLE public.menu_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.order_items ENABLE ROW LEVEL SECURITY;

-- 2. Drop existing insecure policies (cleaning up dev policies)
DROP POLICY IF EXISTS "Enable all access for all users" ON public.menu_items;
DROP POLICY IF EXISTS "Enable all access for all users" ON public.orders;
DROP POLICY IF EXISTS "Enable all access for all users" ON public.order_items;
-- Drop any other loose policies you might have created
DROP POLICY IF EXISTS "Public Access" ON public.menu_items;

-- 3. Create SECURE policies

-- MENU ITEMS: 
-- Public can READ (so the login screen or public menu works if you want)
-- Staff (Authenticated) can ALL (Create, Update, Delete)
CREATE POLICY "Public Read Menu" 
ON public.menu_items FOR SELECT 
USING (true);

CREATE POLICY "Staff Manage Menu" 
ON public.menu_items FOR ALL 
USING (auth.role() = 'authenticated') 
WITH CHECK (auth.role() = 'authenticated');

-- ORDERS:
-- Staff (Authenticated) can ALL
-- If you want public to create orders (e.g. self-service kiosk), change INSERT to public
CREATE POLICY "Staff Manage Orders" 
ON public.orders FOR ALL 
USING (auth.role() = 'authenticated') 
WITH CHECK (auth.role() = 'authenticated');

-- ORDER ITEMS:
-- Staff (Authenticated) can ALL
CREATE POLICY "Staff Manage Order Items" 
ON public.order_items FOR ALL 
USING (auth.role() = 'authenticated') 
WITH CHECK (auth.role() = 'authenticated');

-- 4. STORAGE Policies (for Images)
-- Ensure only staff can upload, but public can view
-- (These might already match what we set up, but good to double check)
-- DROP POLICY IF EXISTS "Public Upload" ON storage.objects; -- Remove public upload if it exists

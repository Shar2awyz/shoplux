-- Run this in your Supabase SQL Editor (Dashboard → SQL Editor → New query)

create table public.payment_methods (
  id            uuid        primary key default gen_random_uuid(),
  user_id       uuid        not null references auth.users(id) on delete cascade,
  card_type     text        not null check (card_type in ('visa', 'mastercard')),
  cardholder_name text      not null,
  last_four     text        not null check (length(last_four) = 4),
  encrypted_number text     not null,
  expiry_month  smallint    not null check (expiry_month between 1 and 12),
  expiry_year   smallint    not null,
  is_default    boolean     not null default false,
  created_at    timestamptz not null default now()
);

-- Enable Row Level Security so users can only access their own cards
alter table public.payment_methods enable row level security;

create policy "Users manage their own payment methods"
  on public.payment_methods
  for all
  using  (auth.uid() = user_id)
  with check (auth.uid() = user_id);

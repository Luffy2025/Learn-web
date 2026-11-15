# Setting up Sunrise's online accounts

Sunrise keeps accounts, drawings, friends and chats in **Supabase**, a free
online database. Supabase also hosts the logins. The website itself is put
online with **GitHub Pages**, so it opens on any computer, phone or tablet.

You only need to do this once. It takes about 15 minutes.

---

## 1. Make a Supabase project

1. Go to <https://supabase.com> and press **Start your project**. Signing in
   with your GitHub account is easiest.
2. Press **New project**.
   - **Name:** `drawlab`
   - **Database password:** press **Generate a password**, then save it
     somewhere safe, like a password manager. Sunrise doesn't need it, but
     you might later.
   - **Region:** the one nearest to you.
   - Plan: **Free**.
3. Wait a minute or two while it gets ready.

## 2. Make the tables and safety rules

1. In the left menu, open **SQL Editor**, then press **New query**.
2. Open [supabase-setup.sql](supabase-setup.sql), copy **all** of it and
   paste it in.
3. Press **Run**. It should say *Success. No rows returned*.

This also makes a private storage area called `chat-files` for chat photos
and videos (you can see it under **Storage**).

> ⚠ Running it again later deletes every drawing, friend and message.
> Only do that if you want to start completely fresh, or when a new Sunrise
> feature needs it. Afterwards, delete the old accounts too, in
> **Authentication → Users** (their usernames are lost, so they can't log
> in properly any more).

### Updates

Some new Sunrise features need a small database change. Those come as
`supabase-update-N-....sql` files. Run each one once, the same way (SQL
Editor → New query → paste → Run). Unlike the full setup, **updates keep all
your data**. If you set up a brand new project with `supabase-setup.sql`,
you don't need them, because it already includes them.

- `supabase-update-1-auto-delete.sql`: chat messages are deleted after 7 days.
- `supabase-update-2-files.sql`: chat photos and videos are deleted once everyone has them; photos up to 1 MB, videos up to 5 MB, 50 MB a week each.
- `supabase-update-3-drawing-limit.sql`: each person can own up to 20 drawings.
- `supabase-update-4-chat-extras.sql`: Delivered/Read, unread numbers, Mute, editing messages, and "typing…".
- `supabase-update-5-online.sql`: green (online) and grey (offline) dots, only for friends.
- `supabase-update-6-chat-limit.sql`: each person can be in up to 10 chats.

## 3. Connect Sunrise to your project

1. In the left menu, open **Project Settings**, then **Data API**, and copy
   the **Project URL**. It looks like `https://abcdefgh.supabase.co`.
2. Open **API Keys** and copy the **anon public** key. It's a long one
   starting with `eyJ`. (If you see a **publishable** key starting with
   `sb_publishable_`, that works too.)
3. Open `hello.html`, search for `SUPABASE_URL`, and paste both in between
   the quotes:

   ```js
   const SUPABASE_URL = "https://abcdefgh.supabase.co";
   const SUPABASE_KEY = "eyJhbGciOi...";
   ```

> ✅ These two are **meant** to be public. Anyone can see them in the
> page's code, and that's fine. What people can actually see or change is
> decided by the rules from step 2, which the database checks every time.
>
> ⛔ **Never** paste the **service_role** or **secret** key into Sunrise.
> That one skips all the rules.

## 4. Login settings

In the left menu, open **Authentication**.

1. **Sign In / Providers → Email:**
   - Turn **Confirm email** **off**. Sunrise accounts don't need an email,
     so there's nothing to confirm when you sign up. (Behind the scenes, an
     account without an email gets a pretend one like
     `sam@drawlab.invalid`, because Supabase needs one. `.invalid` addresses
     can never receive email.)
   - Turn **Secure email change** **off**. Otherwise adding a real email
     later would also need a "yes" from the pretend email, which can never
     arrive.
   - Keep **Email** itself turned **on**.
2. **Password settings** (on the same page, or under **Policies**): set the
   **minimum password length** to **8**, to match Sunrise.
3. **URL Configuration:**
   - **Site URL:** `https://luffy2025.github.io/Learn-web/hello.html`
   - **Redirect URLs:** add the same address. Then add
     `http://localhost:8000/hello.html` too, for testing on your computer.

   These are where the links in "forgot password" emails go.

## 5. Put the website online (GitHub Pages)

1. Commit and push your changes, including the two keys from step 3.
2. On GitHub, open the **Learn-web** repository, then go to
   **Settings → Pages**.
3. Under **Build and deployment**, set **Source** to *Deploy from a branch*,
   set **Branch** to `main` and `/ (root)`, then press **Save**.
4. After a minute or two, Sunrise is live at
   **https://luffy2025.github.io/Learn-web/**

Every time you push to `main`, the website updates by itself within a
couple of minutes.

---

## Good to know

- **Free plan limits:** 500 MB of database storage. That's roughly a few
  hundred drawings with photos. You can see how much you're using on the
  Supabase dashboard.
- **Paused projects:** free projects are paused after a week with nobody
  using them. If Sunrise says it can't reach the server, log in to
  supabase.com and press **Restore project**.
- **Emails:** Supabase's built-in email sender only sends a few emails an
  hour, for resetting passwords. That's fine for
  you and your friends. For lots of people you'd set up your own email
  sender, under **Authentication → Emails → SMTP Settings**.
- **Seeing your data:** **Table Editor** in Supabase shows every table. You
  can see everyone's data there because you own the project, so treat it
  as private.

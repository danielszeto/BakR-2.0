# BakR 2.0

BakR connects home bakers with people looking for fresh, locally baked goods. This is a Rails rebuild of [the original BakR marketplace](https://github.com/danielszeto/Project-2), using its dietary categories, baker profiles, email contact flow, and photography.

## Run locally

Install Ruby 3.3.13 and Bundler, then run:

```sh
bundle install
bin/rails db:prepare
bin/rails db:seed
bin/rails server
```

Open [localhost:3000](http://localhost:3000). To create or reset local demo accounts, run:

```sh
BAKR_DEMO_ACCOUNTS=1 bin/rails db:seed
```

This prints a newly generated password for each account in your terminal. Sign in as `buyer@bakr.example` to try the contact button on **Saturday cinnamon rolls**, or as `baker@bakr.example` to manage the listing. The contact address is a placeholder.

## Enable Google sign-in

1. [Create a Web application OAuth client in Google Cloud](https://console.cloud.google.com/auth/clients).
2. Add `http://localhost:3000/auth/google_oauth2/callback` as an authorized redirect URI. For a hosted app, add the callback on its exact HTTPS origin.
3. Set `GOOGLE_CLIENT_ID` and `GOOGLE_CLIENT_SECRET` in the Rails server environment. Set `GOOGLE_OAUTH_ORIGIN` to the app origin for production or when using a different local port, then restart Rails.

Choose **Continue with Google** on the sign-in page or **Sign up with Google** on the registration page. To use Google with an existing BakR account, sign in with your password and choose **Connect Google** on your profile. Use the same email address for both accounts.

## What you can do

- Browse available listings and filter by Classic, Vegan, Gluten-free, or Organic.
- Create an account, sign in with a password or Google, and edit your baker profile.
- Post a listing with a USD price, dietary category, description, and optional HTTPS photo link.
- Edit, pause, or delete your own listings.
- Add an optional contact email so signed-in buyers can reach you to arrange pickup and payment.

The MVP uses a fresh SQLite database. Legacy records need a separate migration. Checkout and payments are handled directly between buyer and seller.

## Deploy the preview

Deploy the repository with the [Render Blueprint](https://render.com/deploy?repo=https://github.com/danielszeto/BakR-2.0). It provisions a free Rails service, generates the Rails secret, and registers `bakrhood.com`. Render displays the target for your Cloudflare DNS records. The preview seeds sample listings and uses temporary SQLite storage, so accounts and listings created in the preview can reset when the service restarts. Local demo credentials are only generated in development.

## Verify

```sh
bin/rails test
SECRET_KEY_BASE_DUMMY=1 RAILS_ENV=production bin/rails assets:precompile
```

For an HTTPS deployment, set `RAILS_ENV=production` and `SECRET_KEY_BASE`, and put the SQLite database on a persistent volume using `BAKR_DATABASE_PATH`. Run `bin/rails db:prepare` and `bin/rails assets:precompile` before starting Puma. Production seeds are empty unless the preview mode is enabled.

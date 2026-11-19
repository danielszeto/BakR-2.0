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

Open [localhost:3000](http://localhost:3000). The seed adds four sample listings in development. Create your own two accounts to try listing a bake as a seller and contacting that seller as a buyer.

## What you can do

- Browse available listings and filter by Classic, Vegan, Gluten-free, or Organic.
- Create an account, sign in, and edit your baker profile.
- Post a listing with a USD price, dietary category, description, and optional HTTPS photo link.
- Edit, pause, or delete your own listings.
- Add an optional contact email so signed-in buyers can reach you to arrange pickup and payment.

The MVP uses a fresh SQLite database. Legacy records need a separate migration. Checkout and payments are handled directly between buyer and seller.

## Verify

```sh
bin/rails test
SECRET_KEY_BASE_DUMMY=1 RAILS_ENV=production bin/rails assets:precompile
```

For an HTTPS deployment, set `RAILS_ENV=production` and `SECRET_KEY_BASE`, and put the SQLite database on a persistent volume using `BAKR_DATABASE_PATH`. Run `bin/rails db:prepare` and `bin/rails assets:precompile` before starting Puma. Development demo data is excluded from production seeds.

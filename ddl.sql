CREATE TABLE IF NOT EXISTS accounts (
    id bigserial,
    username varchar(30) NOT NULL UNIQUE,
    email varchar(320) NOT NULL UNIQUE,
    password_hash varchar,
    full_name varchar(100),
    phone_number varchar(14),
    gender varchar(10),
    birth_date date,
    is_seller bool NOT NULL DEFAULT false,
    profile_picture_url varchar,
    pin_hash varchar,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    deleted_at timestamptz,

    PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS wallets (
    id bigserial,
    balance decimal NOT NULL CHECK (balance >= 0),
    is_active bool NOT NULL,
    category varchar NOT NULL,
    account_id bigint NOT NULL,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now(),
    deleted_at timestamptz,

    PRIMARY KEY (id),
    FOREIGN KEY (account_id) REFERENCES accounts (id)
);

CREATE TABLE IF NOT EXISTS provinces (
    id bigserial NOT NULL,
    name varchar NOT NULL,

    PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS districts (
    id bigserial NOT NULL,
    name varchar NOT NULL,
    province_id bigint NOT NULL,

    PRIMARY KEY (id),
    FOREIGN KEY (province_id) REFERENCES provinces (id)
);

CREATE TABLE IF NOT EXISTS account_addresses (
    id bigserial NOT NULL,
    receiver_name varchar(100) NOT NULL,
    receiver_phone_number varchar(14) NOT NULL,
    detail varchar(320) NOT NULL,
    is_shop bool NOT NULL,
    is_default bool NOT NULL,
    province_id bigint NOT NULL,
    district_id bigint NOT NULL,
    postal_code varchar(5) NOT NULL,
    account_id bigint NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    deleted_at timestamptz,

    PRIMARY KEY (id),
    FOREIGN KEY (province_id) REFERENCES provinces (id),
    FOREIGN KEY (district_id) REFERENCES districts (id),
    FOREIGN KEY (account_id) REFERENCES accounts (id)
);

CREATE TABLE IF NOT EXISTS shops (
    id bigserial NOT NULL,
    name varchar UNIQUE NOT NULL,
    account_id bigint UNIQUE NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    deleted_at timestamptz,

    PRIMARY KEY (id),
    FOREIGN KEY (account_id) REFERENCES accounts (id)
);

CREATE TABLE IF NOT EXISTS couriers (
    id bigserial NOT NULL,
    name varchar NOT NULL,
    code varchar NOT NULL,
    service_name varchar NOT NULL,
    description text NOT NULL,
    image_url varchar NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    deleted_at timestamptz,

    PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS shop_couriers (
    id bigserial NOT NULL,
    shop_id bigint NOT NULL,
    courier_id bigint NOT NULL,
    is_available bool NOT NULL DEFAULT false,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    deleted_at timestamptz,

    PRIMARY KEY (id),
    FOREIGN KEY (shop_id) REFERENCES shops (id),
    FOREIGN KEY (courier_id) REFERENCES couriers (id)
);

-- title list
-- 1. Order (user -> temporary)
-- 2. Topup (gaib -> user)
-- 3. Withdraw (sales -> user)
-- 4. Transfer (temporary -> sales)
-- 5. Refund (temporary -> user)

CREATE TABLE IF NOT EXISTS transactions (
    id bigserial NOT NULL,
    amount decimal NOT NULL,
    title varchar NOT NULL DEFAULT '',
    to_wallet_id bigint NOT NULL,
    from_wallet_id bigint,

    created_at timestamptz NOT NULL DEFAULT now(),

    PRIMARY KEY (id),
    FOREIGN KEY (to_wallet_id) REFERENCES wallets (id),
    FOREIGN KEY (from_wallet_id) REFERENCES wallets (id)
);

CREATE TABLE IF NOT EXISTS orders (
    id bigserial NOT NULL,
    status varchar NOT NULL,
    estimated_time_arrival timestamptz,
    courier_id bigint NOT NULL,
    seller_id bigint NOT NULL,
    buyer_id bigint NOT NULL,
    delivery_cost decimal NOT NULL,
    transaction_id bigint NOT NULL,
    promotion_name varchar,
    promotion_amount numeric,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    deleted_at timestamptz,

    PRIMARY KEY (id),
    FOREIGN KEY (courier_id) REFERENCES couriers (id),
    FOREIGN KEY (seller_id) REFERENCES accounts (id),
    FOREIGN KEY (buyer_id) REFERENCES accounts (id),
    FOREIGN KEY (transaction_id) REFERENCES transactions (id)
);

CREATE TABLE IF NOT EXISTS products (
    id bigserial NOT NULL,
    name varchar NOT NULL,
    product_code varchar NOT NULL,
    description text NOT NULL,
    thumbnail_url varchar NOT NULL,
    seller_id bigint NOT NULL,
    weight int NOT NULL CHECK (weight > 0),
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    deleted_at timestamptz,

    PRIMARY KEY (id),
    FOREIGN KEY (seller_id) REFERENCES accounts (id)
);

CREATE TABLE IF NOT EXISTS product_medias (
    id bigserial NOT NULL,
    media_url varchar NOT NULL,
    media_type varchar NOT NULL,
    product_id bigint NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    deleted_at timestamptz,

    PRIMARY KEY (id),
    FOREIGN KEY (product_id) REFERENCES products (id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS variant_groups (
    id bigserial NOT NULL,
    name varchar NOT NULL,
    product_id bigint NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    deleted_at timestamptz,

    PRIMARY KEY (id),
    FOREIGN KEY (product_id) REFERENCES products (id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS variant_types (
    id bigserial NOT NULL,
    name varchar NOT NULL,
    variant_group_id bigint NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    deleted_at timestamptz,

    PRIMARY KEY (id),
    FOREIGN KEY (variant_group_id) REFERENCES variant_groups (id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS product_variants (
    id bigserial NOT NULL,
    price numeric NOT NULL CHECK (price > 0),
    stock int NOT NULL CHECK (stock >= 0),
    discount float NOT NULL CHECK (discount >= 0),
    product_id bigint NOT NULL,
    variant_type1_id bigint NOT NULL,
    variant_type2_id bigint NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    deleted_at timestamptz,

    PRIMARY KEY (id),
    FOREIGN KEY (product_id) REFERENCES products (id) ON DELETE CASCADE,
    FOREIGN KEY (variant_type1_id) REFERENCES variant_types (id),
    FOREIGN KEY (variant_type2_id) REFERENCES variant_types (id)
);

CREATE TABLE IF NOT EXISTS order_details (
    id bigserial NOT NULL,
    order_id bigint NOT NULL,
    product_code varchar NOT NULL,
    product_name varchar NOT NULL,
    thumbnail_url varchar NOT NULL,
    variant_name varchar NOT NULL,
    sub_total_price numeric NOT NULL CHECK (sub_total_price > 0),
    quantity int NOT NULL CHECK (quantity >= 1),
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    deleted_at timestamptz,

    PRIMARY KEY (id),
    FOREIGN KEY (order_id) REFERENCES orders (id)
);

CREATE TABLE IF NOT EXISTS carts (
    id bigserial NOT NULL,
    quantity int NOT NULL CHECK (quantity >= 1),
    is_checked bool NOT NULL DEFAULT false,
    product_variant_id bigint NOT NULL,
    account_id bigint NOT NULL,
    seller_id bigint NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    deleted_at timestamptz,

    PRIMARY KEY (id),
    FOREIGN KEY (product_variant_id) REFERENCES product_variants (id) ON DELETE CASCADE,
    FOREIGN KEY (account_id) REFERENCES accounts (id),
    FOREIGN KEY (seller_id) REFERENCES accounts (id)
);

CREATE TABLE IF NOT EXISTS categories (
    id bigserial NOT NULL,
    name varchar NOT NULL,
    level smallint NOT NULL,
    image_url varchar NOT NULL,
    parent_category bigint,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    deleted_at timestamptz,

    PRIMARY KEY (id),
    FOREIGN KEY (parent_category) REFERENCES categories (id)
);

CREATE TABLE IF NOT EXISTS product_categories (
    id bigserial NOT NULL,
    product_id bigint NOT NULL,
    category_id bigint NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    deleted_at timestamptz,

    PRIMARY KEY (id),
    FOREIGN KEY (product_id) REFERENCES products (id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES categories (id)
);

CREATE TABLE IF NOT EXISTS changed_emails (
    id bigserial NOT NULL,
    account_id bigint NOT NULL,
    email varchar(320) NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),

    PRIMARY KEY (id),
    FOREIGN KEY (account_id) REFERENCES accounts (id)
);

CREATE TABLE IF NOT EXISTS wishlists (
    id bigserial NOT NULL,
    account_id bigint NOT NULL,
    product_id bigint NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),

    PRIMARY KEY (id),
    FOREIGN KEY (account_id) REFERENCES accounts (id),
    FOREIGN KEY (product_id) REFERENCES products (id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS reviews (
    id bigserial NOT NULL,
    rating int NOT NULL,
    comment text NOT NULL,
    product_code varchar NOT NULL,
    account_id bigint NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),

    PRIMARY KEY (id),
    FOREIGN KEY (account_id) REFERENCES accounts (id)
);

CREATE TABLE IF NOT EXISTS review_medias (
    id bigserial NOT NULL,
    image_url varchar NOT NULL,
    review_id bigint NOT NULL,

    PRIMARY KEY (id),
    FOREIGN KEY (review_id) REFERENCES reviews (id)
);

CREATE TABLE IF NOT EXISTS promotions (
    id bigserial NOT NULL,
    name varchar NOT NULL,
    exact_price NUMERIC CHECK (exact_price > 0),
    percentage float CHECK (percentage > 0),
    minimum_spend numeric NOT NULL CHECK (minimum_spend >= 0),
    quota int NOT NULL CHECK (quota > 0),
    shop_id bigint NOT NULL,
    started_at timestamptz NOT NULL,
    expired_at timestamptz NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    deleted_at timestamptz,

    PRIMARY KEY (id),
    FOREIGN KEY (shop_id) REFERENCES shops (id)
);
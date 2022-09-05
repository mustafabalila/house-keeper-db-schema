CREATE TABLE "purchase" (
    "id" UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    "user_id" UUID NOT NULL REFERENCES "user" (id) ON DELETE CASCADE,
    "name" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "total_price" FLOAT NOT NULL,
    "share_price" FLOAT NOT NULL,
    "category" INTEGER NOT NULL,
    "payment_progress" INTEGER DEFAULT 0,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT now(),
    "updated_at" TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TRIGGER update_purchase_updated_at
    BEFORE UPDATE ON "purchase"
    FOR EACH ROW
    EXECUTE PROCEDURE update_updated_at_column ();


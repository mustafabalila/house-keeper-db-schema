CREATE TABLE "purchase_subscription" (
    "id" UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    "user_id" UUID NOT NULL REFERENCES "user" (id) ON DELETE CASCADE,
    "purchase_id" UUID NOT NULL REFERENCES "purchase" (id) ON DELETE CASCADE,
    "status" INTEGER NOT NULL,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT now(),
    "updated_at" TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TRIGGER update_purchase_subscription_updated_at
    BEFORE UPDATE ON "purchase_subscription"
    FOR EACH ROW
    EXECUTE PROCEDURE update_updated_at_column ();


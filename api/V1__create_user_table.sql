CREATE TABLE "user" (
    "id" UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    "full_name" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "firebase_token" TEXT NOT NULL DEFAULT '',
    "password" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT now(),
    "updated_at" TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TRIGGER update_user_updated_at
    BEFORE UPDATE ON "user"
    FOR EACH ROW
    EXECUTE PROCEDURE update_updated_at_column ();

